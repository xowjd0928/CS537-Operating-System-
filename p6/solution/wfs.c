#define FUSE_USE_VERSION 30
#include "wfs.h"
#include <sys/stat.h>
#include <fuse.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdlib.h>

#define MAX_PATH_LEN    1024
#define MIN(a,b) ((a) < (b) ? (a) : (b))

static char* mem = NULL;
static char** mem_array;         // Array of memory mappings for each disk
static struct wfs_sb* root = NULL;
static int raid_mode;      // RAID mode (RAID0, RAID1, RAID1v)
static int num_disks;      // Number of disks

typedef struct {
    const char* list[MAX_PATH_LEN];
    size_t lens[MAX_PATH_LEN];
    size_t list_len;
} path_list_t;

off_t alloc_dblock();
inode_t* alloc_inode();
int free_dblock(off_t);
int free_inode(inode_t*);
inode_t* lookup_path(path_list_t* , size_t , dentry_t**);
dentry_t* find_directory_entry(inode_t*, const char*);

static inline inode_t* get_inode(off_t offset) {
    return (inode_t*)(mem + root->i_blocks_ptr + offset);
}

static inline char* get_dblock(off_t offset){
    return mem + offset;
}

static inline dentry_t* alloc_direntry(inode_t* inode)
{
    dentry_t* curr_entry = NULL;
    dentry_t* bound = NULL;
    size_t block_index = 0;
    size_t block_end = IND_BLOCK;
    int walking_indirect = 0;
    off_t* blocks = inode->blocks;
    while(block_index < block_end){
        if(blocks[block_index] == 0) {
            blocks[block_index] = alloc_dblock();
            if(blocks[block_index] == 0){
                return NULL;
            }
        }

        curr_entry = (dentry_t*)get_dblock(blocks[block_index]);
        bound = (dentry_t*)((char*)curr_entry + BLOCK_SIZE);

        while(curr_entry < bound) {
            if(curr_entry->num == 0){
                return curr_entry;
            }
            curr_entry++;
        }
        block_index++;

        if(block_index == block_end && !walking_indirect){
            walking_indirect = 1;
            block_index = 0;
            if(inode->blocks[IND_BLOCK] == 0){
                inode->blocks[IND_BLOCK] = alloc_dblock();
                if(inode->blocks[IND_BLOCK] == 0)
                {
                    return NULL;
                }
            }
            blocks = (off_t*)get_dblock(inode->blocks[IND_BLOCK]);
            block_end = BLOCK_SIZE/sizeof(off_t);
        }
    }
    return NULL;
}

int free_dblock(off_t offset){
    char* block = get_dblock(offset);
    memset((void*)block, 0, BLOCK_SIZE);
    size_t block_index = (offset - root->d_blocks_ptr)/BLOCK_SIZE;
    size_t bytes = block_index >> 3;
    char* bitmap = mem + root->d_bitmap_ptr + bytes;

    unsigned char actual_bit = 0x1 << (block_index - (bytes << 3));
    *bitmap &= ~actual_bit;
    return 0;
}

int free_inode(inode_t* inode)
{
    size_t bytes = inode->num >> 3;
    char* bitmap = mem + root->i_bitmap_ptr + bytes;
    unsigned char actual_bit = 0x1 << (inode->num - (bytes << 3));
    *bitmap &= ~actual_bit;
    memset((void*)inode, 0, sizeof(inode_t));
    return 0;
}

dentry_t* find_directory_entry(inode_t* inode, const char* name) {
    size_t block_index = 0;
    size_t block_end = IND_BLOCK;
    off_t* blocks = inode->blocks;
    int walking_indirect = 0;
    if(S_ISDIR(inode->mode)){
        while(block_index < block_end)
        {
            if(blocks[block_index]) {
                dentry_t* curr = (dentry_t*)get_dblock(blocks[block_index]);
                dentry_t* end = (dentry_t*)((char*)curr + BLOCK_SIZE);
                while(curr < end){
                    if(!strcmp(name, curr->name) && strlen(name) == strlen(curr->name)){
                        return curr;
                    }
                    curr++;
                }
            }

            block_index++;
            if(block_index == block_end && !walking_indirect && blocks[IND_BLOCK]){
                walking_indirect = 1;
                block_index = 0;
                block_end = BLOCK_SIZE/sizeof(dentry_t);
                blocks = (off_t*)get_dblock(blocks[IND_BLOCK]);
            }
        }
    }

    return NULL;
}

inode_t* alloc_inode() {
    unsigned char* bitmap = (unsigned char*)(mem + root->i_bitmap_ptr);
    size_t max_bytes = root->num_inodes >> 3;
    inode_t* node = NULL;
    size_t bytes = 0;
    size_t inode_index = -1;
    while(bytes < max_bytes){
        unsigned char cur_byte = bitmap[bytes];
        unsigned char byte = cur_byte & 0xFF;
        if(byte != 0xFF) {
            size_t count = 0;
            unsigned char added = 0x1;
            while(added & byte)
            {
                added <<= 1;
                count++;
            }
            inode_index = (bytes << 3) + count;
            bitmap[bytes] |= added; 
            break;
        }   
        bytes++;
    }

    if(inode_index >= 0 && inode_index < root->num_inodes){
        node = get_inode(inode_index*BLOCK_SIZE);
        node->num = inode_index;
    }

    return node;
}

// static int delete_file(inode_t* parent_dir, path_list_t* l)
// {
//     dentry_t* direntry = NULL;
//     inode_t* inode = NULL;

//     char name[MAX_NAME];
//     memset(name, 0, MAX_NAME);

//     strncpy(name, l->list[l->list_len-1], l->lens[l->list_len-1]);

//     direntry = find_directory_entry(parent_dir, name);
//     if(direntry == NULL)
//     {
//         return -1;
//     }

//     inode = get_inode(direntry->num*BLOCK_SIZE);


//     size_t block_index = 0;
//     size_t block_end = IND_BLOCK;
//     int walking_indirect = 0;
//     dentry_t* curr_direntry = NULL;
//     dentry_t* direntry_end = NULL;

//     path_list_t temp_list;
//     memcpy(&temp_list, l, sizeof(temp_list));

//     off_t* blocks = inode->blocks;

//     while(block_index < block_end){
//         if(blocks[block_index]) {
//             char* dblock = get_dblock(blocks[block_index]);
//             if(S_ISDIR(inode->mode)) {
//                 curr_direntry = (dentry_t*)dblock;
//                 direntry_end = (dentry_t*)((char*)curr_direntry + BLOCK_SIZE);

//                 while(curr_direntry < direntry_end) {
//                     if(curr_direntry->num != 0){
//                         temp_list.list[l->list_len] = curr_direntry->name;
//                         temp_list.lens[l->list_len] = strlen(curr_direntry->name);
//                         temp_list.list_len = l->list_len+1;
//                         delete_file(inode, &temp_list);
//                         memset((void*)curr_direntry, 0, sizeof(dentry_t));
//                     }
//                     curr_direntry++;
//                 }
//             }
//             //current data block is now not needed.
//             free_dblock(blocks[block_index]);
//         }

//         block_index++;

//         if(!walking_indirect && block_index == block_end && inode->blocks[IND_BLOCK]){
//             block_index = 0;
//             block_end = BLOCK_SIZE/sizeof(off_t);
//             blocks = (off_t*)get_dblock(inode->blocks[IND_BLOCK]);
//             walking_indirect = 1;
//         }
//     }

//     //clear all blocks
//     memset((void*)inode->blocks, 0, sizeof(inode->blocks));
//     //clear the directory entry
//     memset((void*)direntry, 0, sizeof(direntry));
//     free_inode(inode);

//     // clear directory entry.
//     memset((void*)direntry, 0, sizeof(dentry_t));
//     parent_dir->nlinks--;
//     parent_dir->size -= sizeof(dentry_t);
//     return 0;
// }

static int delete_file(inode_t* parent_dir, path_list_t* l)
{
    dentry_t* direntry = NULL;
    inode_t* inode = NULL;

    char name[MAX_NAME];
    memset(name, 0, MAX_NAME);

    strncpy(name, l->list[l->list_len-1], l->lens[l->list_len-1]);

    direntry = find_directory_entry(parent_dir, name);
    if(direntry == NULL)
    {
        return -1;
    }

    inode = get_inode(direntry->num*BLOCK_SIZE);

    size_t block_index = 0;
    size_t block_end = IND_BLOCK;
    int walking_indirect = 0;
    dentry_t* curr_direntry = NULL;
    dentry_t* direntry_end = NULL;

    path_list_t temp_list;
    memcpy(&temp_list, l, sizeof(temp_list));

    off_t* blocks = inode->blocks;
    off_t indirect_block = 0;

    while(block_index < block_end){
        if(blocks[block_index]) {
            char* dblock = get_dblock(blocks[block_index]);
            if(S_ISDIR(inode->mode)) {
                curr_direntry = (dentry_t*)dblock;
                direntry_end = (dentry_t*)((char*)curr_direntry + BLOCK_SIZE);

                while(curr_direntry < direntry_end) {
                    if(curr_direntry->num != 0){
                        temp_list.list[l->list_len] = curr_direntry->name;
                        temp_list.lens[l->list_len] = strlen(curr_direntry->name);
                        temp_list.list_len = l->list_len+1;
                        delete_file(inode, &temp_list);
                        memset((void*)curr_direntry, 0, sizeof(dentry_t));
                    }
                    curr_direntry++;
                }
            }
            free_dblock(blocks[block_index]);
        }

        block_index++;

        if(!walking_indirect && block_index == block_end && inode->blocks[IND_BLOCK]){
            indirect_block = inode->blocks[IND_BLOCK];  // 저장해둠
            blocks = (off_t*)get_dblock(inode->blocks[IND_BLOCK]);
            block_index = 0;
            block_end = BLOCK_SIZE/sizeof(off_t);
            walking_indirect = 1;
        }
    }

    // indirect 블록 자체도 해제
    if(indirect_block) {
        free_dblock(indirect_block);
    }

    //clear all blocks
    memset((void*)inode->blocks, 0, sizeof(inode->blocks));
    //clear the directory entry
    memset((void*)direntry, 0, sizeof(direntry));
    free_inode(inode);

    memset((void*)direntry, 0, sizeof(dentry_t));
    parent_dir->nlinks--;
    parent_dir->size -= sizeof(dentry_t);
    return 0;
}

off_t alloc_dblock(){
    unsigned char* bitmap = (unsigned char*)(mem + root->d_bitmap_ptr);
    size_t max_bytes = root->num_data_blocks >> 3;
    off_t block = 0;
    size_t bytes = 0;
    size_t dblock_index = -1;
    while(bytes < max_bytes){
        unsigned char cur_byte = bitmap[bytes];
        unsigned char byte = cur_byte & 0xFF;
        if(byte != 0xFF) {
            size_t count = 0;
            unsigned char added = 0x1;
            while(added & byte)
            {
                added <<= 1;
                count++;
            }
            dblock_index = (bytes << 3) + count;
            bitmap[bytes] |= added;
            break;
        } 
        bytes++;  
    }

    if(dblock_index >= 0 && dblock_index < root->num_data_blocks){
        block = root->d_blocks_ptr + dblock_index*BLOCK_SIZE;
    }

    return block;
}

static inline void get_stats(inode_t* inode, struct stat* stats)
{
    memset((void*)stats, 0, sizeof(stats));
    stats->st_atime = inode->atim;
    stats->st_ctime = inode->ctim;
    stats->st_mode = inode->mode;
    stats->st_uid = inode->uid;
    stats->st_gid = inode->gid;
    stats->st_mtime = inode->mtim;
    stats->st_blksize = BLOCK_SIZE;
    stats->st_size = inode->size;
    stats->st_nlink = inode->nlinks;
}

path_list_t get_path_list(const char* path){
    path_list_t l;
    memset((void*)&l, 0, sizeof(l));
    if(*path != '/'){
        return l;
    };
    l.lens[0] = 1;
    l.list[0] = path;
    const char* curr_path = &path[1];
    const char* cursor = curr_path;
    const char* path_end = path + strlen(path);
    size_t list_len = 1;
    while(cursor <= path_end){
        while(curr_path < path_end && *curr_path == '/'){
            curr_path++;
            cursor++;
        }
        if(cursor <= path_end && curr_path < path_end){
            if(*cursor == '/' || cursor == path_end)
            {
                l.list[list_len] = curr_path;
                l.lens[list_len] = cursor - curr_path;
                list_len++;
                curr_path = cursor;
                curr_path++;
            }
        }

        cursor++;
    }

    l.list_len = list_len;

    return l;
}

inode_t* lookup_path(path_list_t* l, size_t lookup_depth, dentry_t** direntry)
{
    if(lookup_depth == 0 || lookup_depth > MAX_PATH_LEN)
    {
        return NULL;
    }
    //get the root node
    inode_t* current_inode = (inode_t*)(mem + root->i_blocks_ptr);
    dentry_t* current_folder = (dentry_t*)(get_dblock(current_inode->blocks[0]));
    char name[MAX_NAME];
    
    size_t list_index = 1;
    while(list_index < lookup_depth) {
        memset(name, 0, MAX_NAME);
        strncpy(name, l->list[list_index], l->lens[list_index]);
        dentry_t* dir_ent = find_directory_entry(current_inode, name);
        if(!dir_ent) {
            return NULL;
        }

        current_inode = get_inode(dir_ent->num*BLOCK_SIZE);
        current_folder = dir_ent;
        list_index++;
    }

    *direntry = current_folder;
    return current_inode;
}

static int wfs_getattr(const char* path, struct stat* res)
{
    path_list_t l = get_path_list(path);
    dentry_t* direntry = NULL;
    inode_t* inode = lookup_path(&l, l.list_len, &direntry);
    if(inode == NULL){
        return -ENOENT;
    }
    get_stats(inode, res);
    return 0;
}

static int wfs_mknod(const char* path, mode_t mode, dev_t dev)
{
    path_list_t l = get_path_list(path);
    dentry_t* dirent = NULL;
    inode_t* parent_inode = lookup_path(&l, l.list_len-1, &dirent);
    inode_t* inode = NULL;

    if(parent_inode == NULL){
        return -ENOENT;
    }
    mode |= __S_IFREG;

    inode = lookup_path(&l, l.list_len, &dirent);
    if(inode != NULL)
    {
        return -EEXIST;
    }

    if(!S_ISDIR(parent_inode->mode))
    {
        return -ENOTDIR;
    }

    char name[MAX_NAME];
    memset((void*)name, 0, MAX_NAME);
    strncpy(name, l.list[l.list_len-1], l.lens[l.list_len-1]);

    dirent = alloc_direntry(parent_inode);
    if(dirent == NULL) {
        return -ENOSPC;
    }
    inode = alloc_inode();
    if(inode == NULL){
        return -ENOSPC;
    }
    dirent->num = inode->num;
    memcpy(dirent->name, name, MAX_NAME);

    inode->mode = mode | __S_IFREG;
    inode->uid = getuid();
    inode->gid = getgid();
    inode->size = 0;
    inode->nlinks = 1;
    inode->atim = time(NULL); // Set access time
    inode->mtim = inode->atim; // Set modification time
    inode->ctim = inode->atim; // Set status change time

    parent_inode->size += sizeof(dentry_t);
    parent_inode->nlinks++;
    parent_inode->mtim = time(NULL); 

    if (raid_mode == 0) {
        for (int i = 0; i < num_disks; i++) {
            memcpy(mem_array[i] + root->i_bitmap_ptr, mem + root->i_bitmap_ptr, root->num_inodes / 8); // Inode bitmap
            memcpy(mem_array[i] + root->i_blocks_ptr, mem + root->i_blocks_ptr, root->num_inodes * BLOCK_SIZE); // Inodes
        }
    }

    // Flush metadata to all disks
    if (raid_mode == RAID_1 || raid_mode == RAID_1V) {
        for (int i = 0; i < num_disks; i++) {
            memcpy(mem_array[i] + root->i_bitmap_ptr, mem + root->i_bitmap_ptr, root->num_inodes / 8); // Inode bitmap
            memcpy(mem_array[i] + root->d_bitmap_ptr, mem + root->d_bitmap_ptr, root->num_data_blocks / 8); // Data block bitmap
            memcpy(mem_array[i] + root->i_blocks_ptr, mem + root->i_blocks_ptr, root->num_inodes * BLOCK_SIZE); // Inodes
            memcpy(mem_array[i] + root->d_blocks_ptr, mem + root->d_blocks_ptr, root->num_data_blocks * BLOCK_SIZE);
        }
    }

    return 0;
}

static int wfs_mkdir(const char* path, mode_t mode) {
    mode |= __S_IFDIR;
    path_list_t l = get_path_list(path);
    dentry_t* direntry = NULL;
    inode_t* parent_inode = lookup_path(&l, l.list_len - 1, &direntry);
    if (parent_inode == NULL || !S_ISDIR(parent_inode->mode)) {
        return -ENOENT;
    }

    direntry = NULL;
    inode_t* inode = lookup_path(&l, l.list_len, &direntry);
    if (inode != NULL) {
        printf("inode: %p dentry:%p\n", (void*)inode, (void*)direntry);
        return -EEXIST;
    }

    dentry_t* dir_entry = alloc_direntry(parent_inode);
    if (dir_entry == NULL) {
        return -ENOSPC;
    }

    strncpy(dir_entry->name, l.list[l.list_len - 1], l.lens[l.list_len - 1]);
    inode = alloc_inode();
    if (inode == NULL) {
        memset((void*)dir_entry, 0, sizeof(dentry_t));
        return -ENOSPC;
    }

    dir_entry->num = inode->num;

    inode->size = sizeof(dentry_t);
    inode->uid = getuid();
    inode->gid = getgid();
    inode->nlinks = 2;
    inode->mode = mode;
    inode->atim = time(NULL); // Set access time
    inode->mtim = inode->atim; // Set modification time
    inode->ctim = inode->atim; // Set status change time

    parent_inode->size += sizeof(dentry_t);
    parent_inode->nlinks++;
    parent_inode->mtim = time(NULL); 
    // Flush metadata to all disks
    if (raid_mode == 0) {
        for (int i = 0; i < num_disks; i++) {
            memcpy(mem_array[i] + root->i_bitmap_ptr, mem + root->i_bitmap_ptr, root->num_inodes / 8); // Inode bitmap
            memcpy(mem_array[i] + root->i_blocks_ptr, mem + root->i_blocks_ptr, root->num_inodes * BLOCK_SIZE); // Inodes
        }
    }

    if (raid_mode == RAID_1 || raid_mode == RAID_1V) {
        for (int i = 0; i < num_disks; i++) {
            memcpy(mem_array[i] + root->i_bitmap_ptr, mem + root->i_bitmap_ptr, root->num_inodes / 8); // Inode bitmap
            memcpy(mem_array[i] + root->d_bitmap_ptr, mem + root->d_bitmap_ptr, root->num_data_blocks / 8); // Data block bitmap
            memcpy(mem_array[i] + root->i_blocks_ptr, mem + root->i_blocks_ptr, root->num_inodes * BLOCK_SIZE); // Inodes
            memcpy(mem_array[i] + root->d_blocks_ptr, mem + root->d_blocks_ptr, root->num_data_blocks * BLOCK_SIZE);
        }
    }
    // printf("Directory '%s' created and metadata flushed to all disks.\n", l.list[l.list_len - 1]);

    return 0;
}

static int wfs_unlink(const char* path)
{
    path_list_t l = get_path_list(path);
    dentry_t* direntry = NULL;
    inode_t* parent_inode = NULL;
    parent_inode = lookup_path(&l, l.list_len-1, &direntry);
    if(parent_inode == NULL){
        return -ENOENT;
    }

    inode_t* inode = NULL;
    inode = lookup_path(&l, l.list_len, &direntry);
    if(inode == NULL)
    {
        return -ENOENT;
    }

    delete_file(parent_inode, &l);

     if (raid_mode == 0) {
        for (int i = 0; i < num_disks; i++) {
            memcpy(mem_array[i] + root->i_bitmap_ptr, mem + root->i_bitmap_ptr, root->num_inodes / 8); // Inode bitmap
            memcpy(mem_array[i] + root->i_blocks_ptr, mem + root->i_blocks_ptr, root->num_inodes * BLOCK_SIZE); // Inodes
        }
    }

    // Flush metadata to all disks
    if (raid_mode == RAID_1 || raid_mode == RAID_1V) {
        for (int i = 0; i < num_disks; i++) {
            memcpy(mem_array[i] + root->i_bitmap_ptr, mem + root->i_bitmap_ptr, root->num_inodes / 8); // Inode bitmap
            memcpy(mem_array[i] + root->d_bitmap_ptr, mem + root->d_bitmap_ptr, root->num_data_blocks / 8); // Data block bitmap
            memcpy(mem_array[i] + root->i_blocks_ptr, mem + root->i_blocks_ptr, root->num_inodes * BLOCK_SIZE); // Inodes
            memcpy(mem_array[i] + root->d_blocks_ptr, mem + root->d_blocks_ptr, root->num_data_blocks * BLOCK_SIZE);
        }
    }

    return 0;
}

static int wfs_rmdir(const char* path)
{
    path_list_t l = get_path_list(path);
    dentry_t* direntry = NULL;
    inode_t* parent_inode = NULL;
    parent_inode = lookup_path(&l, l.list_len-1, &direntry);
    if(parent_inode == NULL){
        return -ENOENT;
    }

    direntry = NULL;
    inode_t* inode = NULL;
    inode = lookup_path(&l, l.list_len, &direntry);
    if(inode == NULL){
        return -ENOENT;
    }

    if(!S_ISDIR(inode->mode)){
        return -EINVAL;
    }

    delete_file(parent_inode, &l);

    if (raid_mode == 0) {
        for (int i = 0; i < num_disks; i++) {
            memcpy(mem_array[i] + root->i_bitmap_ptr, mem + root->i_bitmap_ptr, root->num_inodes / 8); // Inode bitmap
            memcpy(mem_array[i] + root->i_blocks_ptr, mem + root->i_blocks_ptr, root->num_inodes * BLOCK_SIZE); // Inodes
        }
    }

    if (raid_mode == RAID_1 || raid_mode == RAID_1V) {
        for (int i = 0; i < num_disks; i++) {
            memcpy(mem_array[i] + root->i_bitmap_ptr, mem + root->i_bitmap_ptr, root->num_inodes / 8); // Inode bitmap
            memcpy(mem_array[i] + root->d_bitmap_ptr, mem + root->d_bitmap_ptr, root->num_data_blocks / 8); // Data block bitmap
            memcpy(mem_array[i] + root->i_blocks_ptr, mem + root->i_blocks_ptr, root->num_inodes * BLOCK_SIZE); // Inodes
            memcpy(mem_array[i] + root->d_blocks_ptr, mem + root->d_blocks_ptr, root->num_data_blocks * BLOCK_SIZE);
        }
    }

    return 0;
}

// static int wfs_read(const char* path, char *buf, size_t size, off_t offset, struct fuse_file_info* fi)
// {
//     path_list_t l = get_path_list(path);
//     dentry_t* direntry = NULL;
//     inode_t* inode = lookup_path(&l, l.list_len, &direntry);

//     if(inode == NULL){
//         return -ENOENT;
//     }

//     if(!(inode->mode & S_IRUSR)){
//         return -EACCES;
//     }

//     if(offset > inode->size || size == 0){
//         return 0;
//     }


//     off_t start_block = offset/BLOCK_SIZE;
//     off_t start_byte = offset - (start_block*BLOCK_SIZE);
//     size_t block_index = start_block;

//     size_t end_block = ((size + offset + BLOCK_SIZE-1) & ~(BLOCK_SIZE-1))/BLOCK_SIZE;
//     size_t blocks_to_read = end_block - start_block;
//     size_t block_end = IND_BLOCK;

//     off_t* blocks = inode->blocks;
    
//     int walking_indirect = 0;
//     size_t read_bytes = 0;
//     size_t blocks_read = 0;

//     while(blocks_read < blocks_to_read) {
//         if(block_index < block_end) {
//             if(blocks[block_index]) {
//                 char* mem = get_dblock(blocks[block_index]);
//                 char* mem_end = mem+BLOCK_SIZE;
//                 if(start_block == block_index){
//                     mem = &mem[start_byte];
//                 }
//                 while(read_bytes < size && read_bytes < inode->size) {
//                     if(mem == mem_end){
//                         //we are done with this block.
//                         break;
//                     }
//                     buf[read_bytes] = *mem;
//                     mem++;
//                     read_bytes++;
//                 }
//             }else{
//                 break;
//             }

//         }else if(!walking_indirect){
//             if(blocks[IND_BLOCK]){
//                 blocks = (off_t*)get_dblock(blocks[IND_BLOCK]);
//                 block_index = 0;
//                 block_end = BLOCK_SIZE/sizeof(off_t);
//                 walking_indirect = 1;
//                 continue;
//             }else{
//                 break;
//             }
//         }
//         blocks_read++;
//         block_index++;
//     }
//     return read_bytes;
// }

static int wfs_read(const char* path, char *buf, size_t size, off_t offset, struct fuse_file_info* fi)
{
    path_list_t l = get_path_list(path);
    dentry_t* direntry = NULL;
    inode_t* inode = lookup_path(&l, l.list_len, &direntry);

    if(inode == NULL) {
        return -ENOENT;
    }

    if(!(inode->mode & S_IRUSR)) {
        return -EACCES;
    }

    if(offset > inode->size || size == 0) {
        return 0;
    }

    off_t start_block = offset/BLOCK_SIZE;
    off_t start_byte = offset - (start_block*BLOCK_SIZE);
    size_t block_index = start_block;
    size_t end_block = ((size + offset + BLOCK_SIZE-1) & ~(BLOCK_SIZE-1))/BLOCK_SIZE;
    size_t blocks_to_read = end_block - start_block;
    size_t block_end = IND_BLOCK;
    off_t* blocks = inode->blocks;
    int walking_indirect = 0;
    size_t read_bytes = 0;
    size_t blocks_read = 0;

    if (raid_mode == RAID_1V) {
        char* block_buffer = malloc(BLOCK_SIZE);
        if (!block_buffer) {
            return -ENOMEM;
        }

        while(blocks_read < blocks_to_read && read_bytes < size) {
            if(block_index < block_end) {
                if(blocks[block_index]) {
                    char* disk_data[MAX_DISKS];
                    int valid_copies = 0;

                    // 모든 디스크에서 블록 읽기
                    for(int i = 0; i < num_disks; i++) {
                        disk_data[i] = mem_array[i] + blocks[block_index];
                        if (i > 0) {
                            if (memcmp(disk_data[0], disk_data[i], BLOCK_SIZE) == 0) {
                                valid_copies++;
                            }
                        }
                    }

                    // 유효한 데이터 찾기
                    char* valid_block = NULL;
                    if (valid_copies >= 1) {
                        // 최소 두 개의 디스크가 같은 데이터를 가지고 있음
                        valid_block = disk_data[0];
                    } else {
                        // 다른 디스크에서 유효한 데이터 찾기
                        for(int i = 1; i < num_disks; i++) {
                            valid_copies = 0;
                            for(int j = 0; j < num_disks; j++) {
                                if (i != j && memcmp(disk_data[i], disk_data[j], BLOCK_SIZE) == 0) {
                                    valid_copies++;
                                }
                            }
                            if (valid_copies >= 1) {
                                valid_block = disk_data[i];
                                break;
                            }
                        }
                    }

                    if (valid_block) {
                        size_t copy_start = (start_block == block_index) ? start_byte : 0;
                        size_t copy_size = MIN(BLOCK_SIZE - copy_start, size - read_bytes);
                        
                        memcpy(buf + read_bytes, valid_block + copy_start, copy_size);
                        read_bytes += copy_size;

                        // 손상된 디스크 복구
                        for(int i = 0; i < num_disks; i++) {
                            if (memcmp(disk_data[i], valid_block, BLOCK_SIZE) != 0) {
                                memcpy(disk_data[i], valid_block, BLOCK_SIZE);
                            }
                        }
                    }
                }
            } else if(!walking_indirect && blocks[IND_BLOCK]) {
                blocks = (off_t*)get_dblock(blocks[IND_BLOCK]);
                block_index = 0;
                block_end = BLOCK_SIZE/sizeof(off_t);
                walking_indirect = 1;
                continue;
            }
            blocks_read++;
            block_index++;
        }

        free(block_buffer);
    } else {
        // 기존 non-RAID 읽기 로직 유지
        while(blocks_read < blocks_to_read) {
            if(block_index < block_end) {
                if(blocks[block_index]) {
                    char* mem = get_dblock(blocks[block_index]);
                    char* mem_end = mem+BLOCK_SIZE;
                    if(start_block == block_index){
                        mem = &mem[start_byte];
                    }
                    while(read_bytes < size && read_bytes < inode->size) {
                        if(mem == mem_end){
                            break;
                        }
                        buf[read_bytes] = *mem;
                        mem++;
                        read_bytes++;
                    }
                }else{
                    break;
                }
            }else if(!walking_indirect){
                if(blocks[IND_BLOCK]){
                    blocks = (off_t*)get_dblock(blocks[IND_BLOCK]);
                    block_index = 0;
                    block_end = BLOCK_SIZE/sizeof(off_t);
                    walking_indirect = 1;
                    continue;
                }else{
                    break;
                }
            }
            blocks_read++;
            block_index++;
        }
    }

    return read_bytes;
}

static int wfs_write(const char* path, const char *buf, size_t size, off_t offset, struct fuse_file_info* fi) {
    path_list_t l = get_path_list(path);
    dentry_t* direntry = NULL;
    inode_t* inode = lookup_path(&l, l.list_len, &direntry);

    if (inode == NULL) {
        return -ENOENT;
    }

    if (!(inode->mode & S_IWUSR)) {
        return -EACCES;
    }

    off_t start_block = offset / BLOCK_SIZE;
    off_t start_byte = offset % BLOCK_SIZE;
    size_t block_index = start_block;

    size_t end_block = (size + offset + BLOCK_SIZE - 1) / BLOCK_SIZE;
    size_t blocks_to_write = end_block - start_block;
    size_t block_end = IND_BLOCK;

    off_t* blocks = inode->blocks;

    int walking_indirect = 0;
    size_t written_bytes = 0;
    size_t blocks_written = 0;

    while (blocks_written < blocks_to_write) {
        if (block_index < block_end) {
            if (!blocks[block_index]) {
                // Allocate new block if not present
                blocks[block_index] = alloc_dblock();
                if (!blocks[block_index]) {
                    return -ENOSPC;
                }

                // Synchronize the data block bitmap across all disks in RAID 1/1V
                if (raid_mode == RAID_1 || raid_mode == RAID_1V) {
                    for (int i = 1; i < num_disks; i++) {
                        memcpy(mem_array[i] + root->i_bitmap_ptr, mem + root->i_bitmap_ptr, root->num_inodes / 8); // Inode bitmap
                        memcpy(mem_array[i] + root->d_bitmap_ptr, mem + root->d_bitmap_ptr, root->num_data_blocks / 8); // Data block bitmap
                        memcpy(mem_array[i] + root->i_blocks_ptr, mem + root->i_blocks_ptr, root->num_inodes * BLOCK_SIZE); // Inodes
                        memcpy(mem_array[i] + root->d_blocks_ptr, mem + root->d_blocks_ptr, root->num_data_blocks * BLOCK_SIZE);
                    }
                }
            }

            char* mem_block = get_dblock(blocks[block_index]);
            char* block_end = mem_block + BLOCK_SIZE;
            char* write_ptr = mem_block + (blocks_written == 0 ? start_byte : 0);

            while (written_bytes < size) {
                if (write_ptr >= block_end) {
                    // Block is fully written
                    break;
                }
                *write_ptr = buf[written_bytes];
                write_ptr++;
                written_bytes++;
            }

            // Sync data block to all disks in RAID 1 or RAID 1V
            if (raid_mode == RAID_1 || raid_mode == RAID_1V) {
                for (int i = 1; i < num_disks; i++) {
                    memcpy(mem_array[i] + root->i_bitmap_ptr, mem + root->i_bitmap_ptr, root->num_inodes / 8); // Inode bitmap
                    memcpy(mem_array[i] + root->d_bitmap_ptr, mem + root->d_bitmap_ptr, root->num_data_blocks / 8); // Data block bitmap
                    memcpy(mem_array[i] + root->i_blocks_ptr, mem + root->i_blocks_ptr, root->num_inodes * BLOCK_SIZE); // Inodes
                    memcpy(mem_array[i] + root->d_blocks_ptr, mem + root->d_blocks_ptr, root->num_data_blocks * BLOCK_SIZE);
                }
            }
        } else if (!walking_indirect) {
            // Handle indirect blocks
            if (!blocks[IND_BLOCK]) {
                blocks[IND_BLOCK] = alloc_dblock();
                if (!blocks[IND_BLOCK]) {
                    return -ENOSPC;
                }

                // Synchronize the data block bitmap across all disks in RAID 1/1V
                if (raid_mode == RAID_1 || raid_mode == RAID_1V) {
                    for (int i = 1; i < num_disks; i++) {
                        memcpy(mem_array[i] + root->i_bitmap_ptr, mem + root->i_bitmap_ptr, root->num_inodes / 8); // Inode bitmap
                        memcpy(mem_array[i] + root->d_bitmap_ptr, mem + root->d_bitmap_ptr, root->num_data_blocks / 8); // Data block bitmap
                        memcpy(mem_array[i] + root->i_blocks_ptr, mem + root->i_blocks_ptr, root->num_inodes * BLOCK_SIZE); // Inodes
                        memcpy(mem_array[i] + root->d_blocks_ptr, mem + root->d_blocks_ptr, root->num_data_blocks * BLOCK_SIZE);
                    }
                }
            }
            blocks = (off_t*)get_dblock(blocks[IND_BLOCK]);
            block_index = start_block < IND_BLOCK ? 0 : start_block - IND_BLOCK;
            block_end = BLOCK_SIZE / sizeof(off_t);
            walking_indirect = 1;
            continue;
        }
        block_index++;
        blocks_written++;
    }

    // Update inode size and timestamps
    if (offset + written_bytes > inode->size) {
        inode->size = offset + written_bytes;
    }
    inode->mtim = time(NULL);
    inode->atim = inode->mtim;

    // Sync inode changes to all disks in RAID 1/1V
    if (raid_mode == RAID_1 || raid_mode == RAID_1V) {
        for (int i = 1; i < num_disks; i++) {
            memcpy(mem_array[i] + root->i_bitmap_ptr, mem + root->i_bitmap_ptr, root->num_inodes / 8); // Inode bitmap
            memcpy(mem_array[i] + root->d_bitmap_ptr, mem + root->d_bitmap_ptr, root->num_data_blocks / 8); // Data block bitmap
            memcpy(mem_array[i] + root->i_blocks_ptr, mem + root->i_blocks_ptr, root->num_inodes * BLOCK_SIZE); // Inodes
            memcpy(mem_array[i] + root->d_blocks_ptr, mem + root->d_blocks_ptr, root->num_data_blocks * BLOCK_SIZE);
        }
    }

    return written_bytes;
}

static int wfs_readdir(const char* path, void* buf, fuse_fill_dir_t filler, off_t offset, struct fuse_file_info* fi)
{
    filler(buf, ".", NULL, 0);
    filler(buf,"..",NULL, 0);
    path_list_t l = get_path_list(path);
    dentry_t* direntry = NULL;
    inode_t* inode = lookup_path(&l, l.list_len, &direntry);

    printf("Looking\n");
    if(inode == NULL){
        printf("No path: %s\n", path);
        return -ENOENT;
    }

    printf("Inode mode: %s %u\n", path, inode->mode);
    if(!(inode->mode & __S_IFDIR)){
        return -ENOTDIR;
    }
    size_t block_index = 0;
    size_t block_end = IND_BLOCK;
    dentry_t* dirend = NULL;
    off_t* blocks = inode->blocks;
    int walking_indirect = 0;
    struct stat stats;

    while(block_index < block_end) {
        if(blocks[block_index]) {
            direntry = (dentry_t*)get_dblock(blocks[block_index]);
            dirend = (dentry_t*)((char*)direntry + BLOCK_SIZE);
            while(direntry < dirend){
                if(direntry->num != 0){
                    inode = get_inode(direntry->num*BLOCK_SIZE);
                    if(inode == NULL){
                        //fatal!
                        fprintf(stderr, "wfs_readdir(): NULL inode but dir has num\n");
                        break;
                    }
                    get_stats(inode, &stats);
                    filler(buf, direntry->name, &stats, 0);
                }
                direntry++;
            }
        }

        block_index++;
        if(block_index == block_end && !walking_indirect && blocks[block_index]){
            blocks = (off_t*)get_dblock(blocks[block_index]);
            block_index = 0;
            block_end = BLOCK_SIZE/sizeof(off_t);
        }
    }

    return 0;
}


static struct fuse_operations ops = {
  .getattr = wfs_getattr,
  .mknod   = wfs_mknod,
  .mkdir   = wfs_mkdir,
  .unlink  = wfs_unlink,
  .rmdir   = wfs_rmdir,
  .read    = wfs_read,
  .write   = wfs_write,
  .readdir = wfs_readdir,
};

int main(int argc, char **argv) {
    if (argc < 4) {
        fprintf(stderr, "Usage: ./wfs disk1 disk2 [FUSE options] mount_point\n");
        return EXIT_FAILURE;
    }

    // Open the first disk explicitly for mem and root
    int fd = open(argv[1], O_RDWR, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
    if (fd < 0) {
        fprintf(stderr, "Error opening first disk (%s): %s\n", argv[1], strerror(errno));
        return EXIT_FAILURE;
    }

    struct wfs_sb block;
    if (read(fd, (void *)&block, sizeof(struct wfs_sb)) != sizeof(struct wfs_sb)) {
        fprintf(stderr, "Error reading superblock\n");
        fprintf(stderr, "Please initialize the disk image before running wfs\n");
        close(fd);
        return EXIT_FAILURE;
    }

    size_t disk_size = block.num_data_blocks * BLOCK_SIZE +
                       block.num_inodes * BLOCK_SIZE +
                       sizeof(struct wfs_sb) +
                       (block.num_inodes / 8) +
                       (block.num_data_blocks / 8);
    if (disk_size == 0 || disk_size < MIN_DISK_SIZE) {
        fprintf(stderr, "Low disk size, required = %u, given = %lu\n", MIN_DISK_SIZE, disk_size);
        close(fd);
        return EXIT_FAILURE;
    }

    // Map the first disk for mem and root
    void *map = mmap(NULL, disk_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (map == MAP_FAILED) {
        fprintf(stderr, "Unable to map first disk to memory: %s\n", strerror(errno));
        close(fd);
        return EXIT_FAILURE;
    }
    close(fd); // Close the file descriptor after mapping

    // Assign mem and root to the first disk
    mem = (char *)map;
    root = (struct wfs_sb *)map;

    // Debug: Print superblock information
    // printf("Superblock:\n");
    // printf("  num_inodes: %ld\n", root->num_inodes);
    // printf("  num_data_blocks: %ld\n", root->num_data_blocks);
    // printf("  i_bitmap_ptr: %ld\n", root->i_bitmap_ptr);
    // printf("  d_bitmap_ptr: %ld\n", root->d_bitmap_ptr);
    // printf("  i_blocks_ptr: %ld\n", root->i_blocks_ptr);
    // printf("  d_blocks_ptr: %ld\n", root->d_blocks_ptr);

    // Initialize mem_array for other disks
    mem_array = (char **)malloc(MAX_DISKS * sizeof(char *));
    if (mem_array == NULL) {
        fprintf(stderr, "Error: Unable to allocate memory for disk mappings.\n");
        munmap(mem, disk_size);
        return EXIT_FAILURE;
    }

    mem_array[0] = mem; // First disk is already mapped
    num_disks = 1;

    // Map additional disks for RAID
    for (int i = 2; i < argc; i++) {
        if (argv[i][0] == '-') {
            break; // Stop at FUSE options
        }

        if (num_disks >= MAX_DISKS) {
            fprintf(stderr, "Error: Too many disks specified (max: %d).\n", MAX_DISKS);
            for (int j = 0; j < num_disks; j++) {
                munmap(mem_array[j], disk_size);
            }
            free(mem_array);
            return EXIT_FAILURE;
        }

        fd = open(argv[i], O_RDWR, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
        if (fd < 0) {
            fprintf(stderr, "Error opening disk %s: %s\n", argv[i], strerror(errno));
            for (int j = 0; j < num_disks; j++) {
                munmap(mem_array[j], disk_size);
            }
            free(mem_array);
            return EXIT_FAILURE;
        }

        map = mmap(NULL, disk_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
        if (map == MAP_FAILED) {
            fprintf(stderr, "Unable to map disk %s to memory: %s\n", argv[i], strerror(errno));
            close(fd);
            for (int j = 0; j < num_disks; j++) {
                munmap(mem_array[j], disk_size);
            }
            free(mem_array);
            return EXIT_FAILURE;
        }
        close(fd); // Close the file descriptor after mapping

        mem_array[num_disks] = (char *)map;
        num_disks++;
        printf("Successfully mapped disk %d: %s\n", num_disks, argv[i]);
    }

    if (num_disks < 2) {
        fprintf(stderr, "Error: At least two disks are required.\n");
        for (int j = 0; j < num_disks; j++) {
            munmap(mem_array[j], disk_size);
        }
        free(mem_array);
        return EXIT_FAILURE;
    }

    raid_mode = root->raid_mode;

    // Debug: Print RAID mode
    printf("RAID Mode: %d\n", raid_mode);

    // Parse FUSE arguments
    int fuse_start = num_disks + 1;
    int fuse_argc = argc - fuse_start + 1;
    char *fuse_argv[fuse_argc];

    fuse_argv[0] = argv[0];
    for (int i = 1; i < fuse_argc; i++) {
        fuse_argv[i] = argv[fuse_start + i - 1];
    }

    // // Debug: Print FUSE arguments
    // printf("FUSE Arguments:\n");
    // for (int i = 0; i < fuse_argc; i++) {
    //     printf("  argv[%d]: %s\n", i, fuse_argv[i]);
    // }

    // Pass control to FUSE
    int result = fuse_main(fuse_argc, fuse_argv, &ops, NULL);
    if (result != 0) {
        fprintf(stderr, "FUSE failed to initialize or mount.\n");
    }

    // Cleanup
    for (int i = 0; i < num_disks; i++) {
        munmap(mem_array[i], disk_size);
    }
    free(mem_array);

    return result;
}