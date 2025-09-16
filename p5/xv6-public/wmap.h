// Flags for wmap
#define MAP_SHARED 0x0002
#define MAP_ANONYMOUS 0x0004
#define MAP_FIXED 0x0008

// When any system call fails, returns -1
#define FAILED -1
#define SUCCESS 0

struct mmap_region {
    uint start_addr;       // Starting virtual address of the mapping
    int length;            // Length of the mapped region in bytes
    int flags;             // Flags for the mapping (e.g., MAP_SHARED, MAP_ANONYMOUS)
    int fd;                // File descriptor if file-backed, -1 if anonymous
    int n_loaded_pages;    // Number of pages physically loaded
};

// for `getwmapinfo`
#define MAX_WMMAP_INFO 16
struct wmapinfo {
    int total_mmaps;                    // Total number of wmap regions
    int addr[MAX_WMMAP_INFO];           // Starting address of mapping
    int length[MAX_WMMAP_INFO];         // Size of mapping
    int n_loaded_pages[MAX_WMMAP_INFO]; // Number of pages physically loaded into memory
};
