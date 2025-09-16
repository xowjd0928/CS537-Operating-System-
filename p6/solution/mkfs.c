#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include "wfs.h"
#include <bits/getopt_core.h>
#include <sys/stat.h>
#include <linux/stat.h>
#include <time.h>

// Helper function to calculate rounded-up size
size_t roundup(size_t n, size_t align) {
    size_t remain = n % align;
    return remain == 0 ? n : n + (align - remain);
}

// Writes data to a disk at the specified offset
void write_to_disk(int fd, off_t offset, const void *buffer, size_t size) {
    if (lseek(fd, offset, SEEK_SET) < 0) {
        perror("lseek");
        exit(EXIT_FAILURE);
    }
    if (write(fd, buffer, size) != size) {
        perror("write");
        exit(EXIT_FAILURE);
    }
}

// Initializes the superblock
void initialize_superblock(super_block_t *sb, size_t num_inodes, size_t num_data_blocks, int raid_mode, int num_disks) {
    size_t i_bitmap_size = (num_inodes + 7) / 8; // Exact size in bytes
    size_t d_bitmap_size = (num_data_blocks + 7) / 8; // Exact size in bytes

    sb->num_inodes = num_inodes;
    sb->num_data_blocks = num_data_blocks;

    // Superblock starts at offset 0
    size_t current_offset = sizeof(super_block_t);

    // Inode bitmap packed immediately after the superblock
    sb->i_bitmap_ptr = current_offset;
    current_offset += i_bitmap_size;

    // Data bitmap packed immediately after the inode bitmap
    sb->d_bitmap_ptr = current_offset;
    current_offset += d_bitmap_size;

    // Align the inode blocks to the next block boundary
    sb->i_blocks_ptr = roundup(current_offset, BLOCK_SIZE);

    // Align the data blocks to the next block boundary after the inode blocks
    sb->d_blocks_ptr = roundup(sb->i_blocks_ptr + num_inodes * BLOCK_SIZE, BLOCK_SIZE);

    // Store RAID and disk info
    sb->raid_mode = raid_mode;
    sb->num_disks = num_disks;
}

// Initializes and writes the inode and data block bitmaps
void initialize_bitmaps(int *fds, super_block_t *sb, size_t num_inodes, size_t num_data_blocks) {
    size_t i_bitmap_size = (num_inodes + 7) / 8; // Exact size in bytes
    size_t d_bitmap_size = (num_data_blocks + 7) / 8; // Exact size in bytes

    // Allocate memory for bitmaps
    unsigned char *i_bitmap = calloc(1, i_bitmap_size);
    unsigned char *d_bitmap = calloc(1, d_bitmap_size);

    // Write inode and data bitmaps to all disks (mirrored metadata)
    for (int i = 0; i < sb->num_disks; i++) {
        write_to_disk(fds[i], sb->i_bitmap_ptr, i_bitmap, i_bitmap_size); // Use exact size
        write_to_disk(fds[i], sb->d_bitmap_ptr, d_bitmap, d_bitmap_size); // Use exact size
    }

    // Free allocated memory
    free(i_bitmap);
    free(d_bitmap);
}

// Initializes and writes the inode table
void initialize_inodes(int *fds, super_block_t *sb, size_t num_inodes) {
    time_t current_time = time(NULL);
    if (current_time == ((time_t) -1)) {
        perror("time");
        exit(EXIT_FAILURE);
    }
    for (int i = 0; i < sb->num_disks; i++) {
        off_t offset = sb->i_blocks_ptr;

        for (size_t j = 0; j < num_inodes; j++) {
            inode_t inode = {0}; // Initialize all fields to 0

            if (j == 0) {
                // Root inode initialization
                inode.num = 0; // Root inode number
                inode.mode = __S_IFDIR | 0755; // Directory with 0755 permissions
                inode.uid = getuid(); // Owner UID
                inode.gid = getgid(); // Owner GID
                inode.size = 0; // Initially empty
                inode.nlinks = 2; // Self and parent directory links
                inode.atim = inode.mtim = inode.ctim = current_time; // Timestamps initialized to 0
            } else {
                // Other inodes initialized as unused
                inode.num = -1; // Mark as unused
            }

            // Write the inode to disk
            write_to_disk(fds[i], offset, &inode, sizeof(inode_t));
            offset += BLOCK_SIZE; // Move to the next inode block
        }
    }
}

void initialize_root_inode(int *fds, super_block_t *sb) {
    time_t current_time = time(NULL);
    if (current_time == ((time_t) -1)) {
        perror("time");
        exit(EXIT_FAILURE);
    }
    // Initialize the root inode
    inode_t root_inode = {0};
    root_inode.num = 0; // Root inode number
    root_inode.mode = __S_IFDIR | 0755; // Directory mode (permissions: rwxr-xr-x)
    root_inode.uid = getuid(); // Owner UID
    root_inode.gid = getgid(); // Owner GID
    root_inode.size = 0; // Initially empty
    root_inode.nlinks = 2; // Link count for root (self and parent)
    root_inode.blocks[0] = 0; // First data block for directory entries
    root_inode.atim = root_inode.mtim = root_inode.ctim = current_time; // Timestamps initialized to 0

    // Write the root inode to all disks (mirrored metadata)
    for (int i = 0; i < sb->num_disks; i++) {
        write_to_disk(fds[i], sb->i_blocks_ptr, &root_inode, sizeof(inode_t));

        // Read the inode bitmap from the disk
        size_t i_bitmap_size = sb->d_bitmap_ptr - sb->i_bitmap_ptr;
        unsigned char *i_bitmap = malloc(i_bitmap_size);
        pread(fds[i], i_bitmap, i_bitmap_size, sb->i_bitmap_ptr);

        // Mark the first bit in the inode bitmap (inode #0) as allocated
        i_bitmap[0] |= 0x01;

        // Write the updated inode bitmap back to the disk
        pwrite(fds[i], i_bitmap, i_bitmap_size, sb->i_bitmap_ptr);

        // Free the temporary bitmap
        free(i_bitmap);
    }
}

int main(int argc, char *argv[]) {

    int raid_mode = -1, num_disks = 0, num_inodes = 0, num_data_blocks = 0;
    char *disk_files[MAX_DISKS];

    // Parse command-line arguments
    int opt;
    while ((opt = getopt(argc, argv, "r:d:i:b:")) != -1) {
        switch (opt) {
            case 'r':
                if (strcmp(optarg, "0") == 0) raid_mode = 0;
                else if (strcmp(optarg, "1") == 0) raid_mode = 1;
                else if (strcmp(optarg, "1v") == 0) raid_mode = 2;
                else {
                    fprintf(stderr, "Invalid RAID mode specified.\n");
                    return EXIT_FAILURE;
                }
                break;
            case 'd':
                if (num_disks >= MAX_DISKS) {
                    fprintf(stderr, "Too many disks specified.\n");
                    return EXIT_FAILURE;
                }
                disk_files[num_disks++] = optarg;
                break;
            case 'i':
                num_inodes = atoi(optarg);
                break;
            case 'b':
                num_data_blocks = atoi(optarg);
                break;
            default:
                fprintf(stderr, "Usage: %s -r <raid_mode> -d <disk_file>... -i <num_inodes> -b <num_data_blocks>\n", argv[0]);
                return EXIT_FAILURE;
        }
    }

    // Validate inputs
    if (raid_mode == -1) {
        fprintf(stderr, "No RAID mode specified.\n");
        return EXIT_FAILURE;
    }
    if (num_disks < 2) {
        fprintf(stderr, "At least two disks are required.\n");
        return EXIT_FAILURE;
    }
    if (num_inodes <= 0 || num_data_blocks <= 0) {
        fprintf(stderr, "Invalid number of inodes or data blocks specified.\n");
        return EXIT_FAILURE;
    }

    num_inodes = roundup(num_inodes, 32); // Align inode blocks to a multiple of 32
    num_data_blocks = roundup(num_data_blocks, 32); // Align data blocks to a multiple of 32

       // Open and validate disk files
    int fds[MAX_DISKS];
    off_t actual_disk_size = 0;

    for (int i = 0; i < num_disks; i++) {
        fds[i] = open(disk_files[i], O_RDWR | O_CREAT, 0644);
        if (fds[i] < 0) {
            perror("open");
            return EXIT_FAILURE;
        }

        // Get the current size of the disk
        actual_disk_size = lseek(fds[i], 0, SEEK_END);
        if (actual_disk_size < 0) {
            perror("lseek");
            return EXIT_FAILURE;
        }

        // Calculate the required disk size
        size_t i_bitmap_size = (num_inodes + 7) / 8;
        size_t d_bitmap_size = (num_data_blocks + 7) / 8;
        size_t inode_blocks_size = num_inodes * BLOCK_SIZE;
        size_t data_blocks_size = num_data_blocks * BLOCK_SIZE;

        size_t required_size = sizeof(super_block_t) // Superblock
                               + i_bitmap_size        // Inode bitmap
                               + d_bitmap_size        // Data bitmap
                               + inode_blocks_size    // Inode blocks
                               + data_blocks_size;    // Data blocks

        required_size = roundup(required_size, BLOCK_SIZE); // Ensure total size is block-aligned

        // Validate that the disk is large enough
        if (required_size > actual_disk_size) {
            fprintf(stderr, "Error: Disk %s is too small. Required size: %zu bytes, available size: %zu bytes.\n",
                    disk_files[i], required_size, (size_t)actual_disk_size);
            exit(-1);
        }

        // Ensure disk is truncated to the required size
        if (ftruncate(fds[i], required_size) < 0) {
            perror("ftruncate");
            return EXIT_FAILURE;
        }
    }

    // Initialize the superblock
    super_block_t sb = {0};
    initialize_superblock(&sb, num_inodes, num_data_blocks, raid_mode, num_disks);

    // Write superblock to all disks (mirrored metadata)
    for (int i = 0; i < num_disks; i++) {
        write_to_disk(fds[i], 0, &sb, sizeof(super_block_t));
    }

    // Initialize bitmaps, inodes, and root inode
    initialize_bitmaps(fds, &sb, num_inodes, num_data_blocks);
    initialize_inodes(fds, &sb, num_inodes);
    initialize_root_inode(fds, &sb);

    // Close disk files
    for (int i = 0; i < num_disks; i++) {
        close(fds[i]);
    }

    printf("Filesystem initialized successfully.\n");
    return EXIT_SUCCESS;
}