#include "types.h"
#include "stat.h"
#include "user.h"

int main(void) {
    char parentbuf[256];  // Buffer to store the parent process name
    char childbuf[256];   // Buffer to store the current (child) process name

    // Call the getparentname system call
    if (getparentname(parentbuf, childbuf, sizeof(parentbuf), sizeof(childbuf)) < 0) {
        printf(2, "Error: getparentname system call failed\n");
        exit();
    }

    // Print the result in the required format
    printf(1, "XV6_TEST_OUTPUT Parent name: %s Child name: %s\n", parentbuf, childbuf);

    exit();
}
