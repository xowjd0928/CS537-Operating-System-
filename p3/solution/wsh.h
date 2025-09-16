#ifndef WSH_H
#define WSH_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>

#define MAX_LINE 1024  // Maximum line size
#define DEFAULT_HISTORY_SIZE 5

// Struct to hold shell variables
typedef struct ShellVar {
    char name[MAX_LINE];
    char value[MAX_LINE];
} ShellVar;

// Struct to manage command history
typedef struct History {
    char **commands;   // Array of command strings
    int size;          // Current size of the history list (capacity)
    int count;         // Number of stored commands
} History;

// Global variables
extern ShellVar shell_vars[MAX_LINE];
extern int shell_var_count;
extern History history;

// Function declarations
void init_path();

void init_history(History *history);
void add_history(History *history, const char *command);
void print_history(const History *history);
void execute_history(History *history, int index);
void resize_history(History *history, int new_size);
void free_history(History *history);

int handle_redirection(char *args[], int *input_fd, int *output_fd, int *error_fd);

char *find_shell_var(const char *name);
void builtin_local(char *arg);
void builtin_export(char *arg);
void builtin_vars();

void builtin_cd(char *arg);

int compare(const void *a, const void *b);
void builtin_ls();

void substitute_variables(char *command);
char *resolve_command(char *command);
int execute_command(char *command);

char *strip_leading_spaces(char *str);
int is_comment(char *line);
void interactive_mode();
void batch_mode(const char *batch_file);

#endif /* WSH_H */
