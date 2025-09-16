#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include "wsh.h"

// Global variables
ShellVar shell_vars[MAX_LINE];
int shell_var_count = 0;
History history;
int last_exit_status = 0;

/* Initializes the PATH environment variable to "/bin".
 *
 * Returns:
 * - None (void)
 */
void init_path() {
    setenv("PATH", "/bin", 1);  // Set PATH to /bin
}

/* Initializes the history structure with a default size and allocates memory
 * for storing command history.
 *
 * history: pointer to the History structure that will be initialized
 *
 * Notes:
 * - Sets the history size to DEFAULT_HISTORY_SIZE
 * - Initializes the command count to 0
 * - Allocates memory for storing commands up to the specified size
 *
 * Returns:
 * - None (void)
 */
void init_history(History *history) {
    // Set the default size,count of history
    history->size = DEFAULT_HISTORY_SIZE;
    history->count = 0;

    // Allocate memory for the command list
    history->commands = malloc(history->size * sizeof(char *));
    for (int i = 0; i < history->size; i++) {
        history->commands[i] = NULL;
    }
}

/* Frees the memory allocated for storing the command history.
 * 
 * history: pointer to the History structure whose memory will be freed
 * 
 * Notes: 
 * - This function frees memory for each stored command in the history list
 * - After freeing the individual commands, it frees the array used to store the pointers
 * 
 * Returns: 
 * - None (void)
 */
void free_history(History *history) {
    for (int i = 0; i < history->count; i++) {
        free(history->commands[i]);
    }
    free(history->commands);
}

/* Adds a command to the history list, ensuring that built-in commands and
 * consecutive duplicates are not added. If the history is full, the oldest
 * command is removed to make room for the new command.
 * 
 * history: pointer to the History structure where the command will be added
 * command: string representing the command to be added to the history
 * 
 * Notes:
 * - Built-in commands like "exit", "cd", "export", etc., are not stored in the history
 * - Consecutive duplicate commands are not added to the history
 * - If the history is full, the oldest command is removed, and the rest are shifted
 * 
 * Returns: 
 * - None (void)
 */
void add_history(History *history, const char *command) {
    // Don't add if it's a built-in command
    if (strcmp(command, "exit") == 0 || strcmp(command, "cd") == 0 ||
        strcmp(command, "export") == 0 || strcmp(command, "local") == 0 ||
        strcmp(command, "vars") == 0 || strcmp(command, "ls") == 0 ||
        strncmp(command, "history", 7) == 0) {
        return;
    }

    // Don't add consecutive duplicate commands
    if (history->count > 0 && strcmp(history->commands[0], command) == 0) {
        return;
    }

    // If history is full, free the oldest command and shift others
    if (history->count == history->size) {
	// Free the oldest command
        free(history->commands[history->size - 1]);
	// Shift all commands down one slot
        for (int i = history->size - 1; i > 0; i--) {
            history->commands[i] = history->commands[i - 1];
        }
    } else {
        // If history is not full, shift all commands down one slot
        for (int i = history->count; i > 0; i--) {
            history->commands[i] = history->commands[i - 1];
        }
        history->count++;
    }

    // Add the new command to history
    history->commands[0] = strdup(command);
}

/* Prints the command history in reverse order, with each command
 * numbered sequentially starting from 1.
 * 
 * history: pointer to the History structure that contains the list of stored commands
 * 
 * Notes:
 * - This function prints the history of commands, with the most recent command appearing first.
 * - Each command is printed with its respective index starting from 1.
 * 
 * Returns: 
 * - None (void)
 */
void print_history(const History *history) {
    for (int i = 0; i < history->count; i++) {
        printf("%d) %s\n", i + 1, history->commands[i]);
    }
}

/* Re-executes the command at the given index from the command history.
 *
 * history: pointer to the History structure that stores the command history
 * index: index of the command to execute from history
 *
 * Notes:
 * - If the index is out of bounds (less than 1 or greater than the number of stored commands),
 *   an error message is displayed, and no command is executed.
 * - If the index is valid, the command is re-executed using execute_command.
 *
 * Returns:
 * - None (void)
 */
void execute_history(History *history, int index) {
    // Check if the index is invalid
    if (index < 1 || index > history->count) {
        printf("Invalid history index\n");
	last_exit_status = -1;
        return;
    }
    execute_command(history->commands[index - 1]);
}

/* Resizes the command history to the specified new size.
 * 
 * history: pointer to the History structure that stores the command history
 * new_size: the new desired size for the command history
 * 
 * Notes:
 * - If the new size is same as the current size, no changes are made, it just return
 * - If the new size is smaller than the current number of stored commands, the extra commands 
 *   are removed, and their memory is freed.
 * - The history is resized to the new size, either reducing or expanding as needed.
 * - When expanding, new slots are initialized to NULL.
 * 
 * Returns:
 * - None (void)
 */
void resize_history(History *history, int new_size) {
    // New size is same as the current size, just return
    if (new_size == history->size) {
    	return;
    }

    // Check if the new size is invalid
    if (new_size < 1) {
        printf("History size must be at least 1\n");
	last_exit_status = -1;
        return;
    }

    // If new size is smaller, free extra commands
    if (new_size < history->count) {
        for (int i = new_size; i < history->count; i++) {
            free(history->commands[i]);
        }
        history->count = new_size;
    }

    // Reallocate history to the new size
    history->commands = realloc(history->commands, new_size * sizeof(char *));
    for (int i = history->size; i < new_size; i++) {
        history->commands[i] = NULL;
    }

    history->size = new_size;
}

/* Parses and sets up redirection for input, output, and error based on the command arguments.
 * This function identifies and processes redirection tokens that are guaranteed to be the last
 * argument in the command array, modifying file descriptors accordingly.
 *
 * args: array of command arguments, where the last element may contain a redirection token
 * input_fd: pointer to the file descriptor for input redirection (set if '<' is found)
 * output_fd: pointer to the file descriptor for output redirection (set if '>' or '>>' is found)
 * error_fd: pointer to the file descriptor for error redirection (set if '&>' or '&>>' is found)
 *
 * Notes:
 * - This function handles the following redirection types:
 *   - Input redirection: [n]<word
 *   - Output redirection (overwrite): [n]>word
 *   - Output redirection (append): [n]>>word
 *   - Redirecting stdout and stderr (overwrite): &>word
 *   - Redirecting stdout and stderr (append): &>>word
 * - The redirection token is always expected to be the last argument.
 * - The function modifies the argument array (`args[]`) to remove the redirection token.
 *
 * Returns:
 * - 0 on success
 * - -1 on failure
 */
int handle_redirection(char *args[], int *input_fd, int *output_fd, int *error_fd) {
    int i = 0;

    // Find the last argument, which should be the redirection token
    while (args[i] != NULL) {
        i++;
    }
    i--;  // Move to the last valid argument

    if (i >= 0) {
        // Handle appending both stdout and stderr &>>word
        if (strstr(args[i], "&>>") != NULL) {
            char *filename = strstr(args[i], "&>>") + 3;
            *output_fd = open(filename, O_WRONLY | O_CREAT | O_APPEND, 0644);
            *error_fd = *output_fd;  // Redirect stderr to the same file as stdout
            if (*output_fd < 0) {
                perror("Failed to open file for stdout and stderr (append)");
                last_exit_status = -1;
                return -1;
            }
            args[i] = NULL;
        }

        // Handle redirecting both stdout and stderr &>word
        else if (strstr(args[i], "&>") != NULL) {
            char *filename = strstr(args[i], "&>") + 2;
            *output_fd = open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0644);
            *error_fd = *output_fd;  // Redirect stderr to the same file as stdout
            if (*output_fd < 0) {
                perror("Failed to open file for stdout and stderr");
                last_exit_status = -1;
                return -1;
            }
            args[i] = NULL;
        }

        // Handle appending stderr 2>>word
        else if (strstr(args[i], "2>>") != NULL) {
            char *filename = strstr(args[i], "2>>") + 3;
            *error_fd = open(filename, O_WRONLY | O_CREAT | O_APPEND, 0644);
            if (*error_fd < 0) {
                perror("Failed to open file for stderr (append)");
                last_exit_status = -1;
                return -1;
            }
            args[i] = NULL;
        }

        // Handle appending stdout 1>>word
        else if (strstr(args[i], "1>>") != NULL) {
            char *filename = strstr(args[i], "1>>") + 3;
            *output_fd = open(filename, O_WRONLY | O_CREAT | O_APPEND, 0644);
            if (*output_fd < 0) {
                perror("Failed to open file for stdout (append)");
                last_exit_status = -1;
                return -1;
            }
            args[i] = NULL;
        }

        // Handle appending default stdout >>word
        else if (strstr(args[i], ">>") != NULL) {
            char *filename = strstr(args[i], ">>") + 2;
            *output_fd = open(filename, O_WRONLY | O_CREAT | O_APPEND, 0644);
            if (*output_fd < 0) {
                perror("Failed to open output file (append)");
                last_exit_status = -1;
                return -1;
            }
            args[i] = NULL;
        }

        // Handle stderr redirection 2>word
        else if (strstr(args[i], "2>") != NULL) {
            char *filename = strstr(args[i], "2>") + 2;
            *error_fd = open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0644);
            if (*error_fd < 0) {
                perror("Failed to open file for stderr");
                last_exit_status = -1;
                return -1;
            }
            args[i] = NULL;
        }

        // Handle stdout redirection 1>word
        else if (strstr(args[i], "1>") != NULL) {
            char *filename = strstr(args[i], "1>") + 2;
            *output_fd = open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0644);
            if (*output_fd < 0) {
                perror("Failed to open file for stdout");
                last_exit_status = -1;
                return -1;
            }
            args[i] = NULL;
        }

        // Handle input redirection 0<word (for stdin)
        else if (strstr(args[i], "0<") != NULL) {
            char *filename = strstr(args[i], "0<") + 2;
            *input_fd = open(filename, O_RDONLY);
            if (*input_fd < 0) {
                perror("Failed to open input file");
                last_exit_status = -1;
                return -1;
            }
            args[i] = NULL;
        }

        // Handle default input redirection <word (for stdin)
        else if (strchr(args[i], '<') != NULL) {
            char *filename = strchr(args[i], '<') + 1;
            *input_fd = open(filename, O_RDONLY);
            if (*input_fd < 0) {
                perror("Failed to open input file");
                last_exit_status = -1;
                return -1;
            }
            args[i] = NULL;
        }

        // Handle default output redirection >word (for stdout)
        else if (strchr(args[i], '>') != NULL) {
            char *filename = strchr(args[i], '>') + 1;
            *output_fd = open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0644);
            if (*output_fd < 0) {
                perror("Failed to open output file");
                last_exit_status = -1;
                return -1;
            }
            args[i] = NULL;
        }
    }

    return 0;
}

/* Searches for a shell variable by name and returns its value if found.
 * 
 * name: pointer to the string representing the name of the shell variable to search for
 * 
 * Notes:
 * - The function loops through the list of shell variables and compares the provided name
 *   with each variable's name using strcmp.
 * - If a match is found, the corresponding value of the shell variable is returned.
 * - If no match is found, the function returns NULL.
 * 
 * Returns:
 * - Pointer to the value of the shell variable if found, otherwise NULL.
 */
char* find_shell_var(const char *name) {
    for (int i = 0; i < shell_var_count; i++) {
        if (strcmp(shell_vars[i].name, name) == 0) {
            return shell_vars[i].value;
        }
    }
    return NULL;
}

/* Handles local shell variable assignment or removal based on the provided argument.
 * 
 * arg: string in the format "name=value" representing the local variable to be added,
 *      updated, or removed (if the value is empty).
 * 
 * Notes:
 * - If the value is an empty string, the variable is removed from the list of shell variables.
 * - If the variable already exists, its value is updated.
 * - If the variable does not exist, it is added to the list of shell variables.
 * 
 * Returns:
 * - None (void).
 */
void builtin_local(char *arg) {
    char *index = strchr(arg, '=');  // Find the position of '=' in the argument
    if (index == NULL) {
        // If no '=' is found, print an error and return
        fprintf(stderr, "local: invalid format\n");
        last_exit_status = -1;
	return;
    }

    // Extract the variable name
    char *name = strtok(arg, "=");
    if (name == NULL || strlen(name) == 0) {
        fprintf(stderr, "local: invalid format\n");
        last_exit_status = -1;
	return;
    }

    // Extract the variable value (which can be an empty string)
    char *value = index + 1;  // Value starts just after the '=' sign

    // If the value is empty, remove the variable
    if (strlen(value) == 0) {
        for (int i = 0; i < shell_var_count; i++) {
            if (strcmp(shell_vars[i].name, name) == 0) {
                // Shift remaining variables to remove the current one
                for (int j = i; j < shell_var_count - 1; j++) {
                    shell_vars[j] = shell_vars[j + 1];
                }
                shell_var_count--;  // Decrease the count of shell variables
                return;
            }
        }
        return;
    }

    // Check if the variable already exists and update it
    for (int i = 0; i < shell_var_count; i++) {
        if (strcmp(shell_vars[i].name, name) == 0) {
            // Update the variable's value
            strcpy(shell_vars[i].value, value);
            return;
        }
    }

    // If the variable does not exist, add it with the specified value
    strcpy(shell_vars[shell_var_count].name, name);
    strcpy(shell_vars[shell_var_count].value, value);
    shell_var_count++;  // Increase the count of shell variables
}

/* Handles the export of environment variables. If the value is an empty string,
 * the environment variable is set with an empty value.
 * 
 * arg: string in the format "name=value" representing the environment variable to be added
 *      or updated.
 * 
 * Notes:
 * - If the variable already exists in the environment, its value is updated.
 * - If no value is provided (i.e., "export name="), the variable is set with an empty value.
 * - If the format is invalid (no '=' present), an error is printed.
 * 
 * Returns:
 * - None (void)
 */
void builtin_export(char *arg) {
    char *index = strchr(arg, '=');  // Find the position of '=' in the argument
    if (index == NULL) {
        // If no '=' is found, print an error and return
        fprintf(stderr, "export: invalid format\n");
        last_exit_status = -1;
	return;
    }

    // Extract the variable name
    char *name = strtok(arg, "=");
    if (name == NULL || strlen(name) == 0) {
        fprintf(stderr, "export: invalid format\n");
        last_exit_status = -1;
	return;
    }

    // Extract the variable value (which can be an empty string)
    char *value = index + 1;  // Value starts just after the '=' sign

    if (setenv(name, value, 1) != 0) {
        perror("export failed");
        last_exit_status = -1;
	return;
    }
}

/* Prints all shell variables and their values in the format "name=value".
 * 
 * Notes:
 * - The function loops through all shell variables currently stored and prints each
 *   in the format "name=value".
 * - If no variables are set, nothing is printed.
 * 
 * Returns:
 * - None (void)
 */
void builtin_vars() {
    for (int i = 0; i < shell_var_count; i++) {
        printf("%s=%s\n", shell_vars[i].name, shell_vars[i].value);
    }
}

/* Changes the current working directory to the specified path and updates the PWD 
 * environment variable.
 * 
 * arg: string representing the directory path to change to.
 * 
 * Notes:
 * - This function uses `chdir()` to change the working directory.
 * - If the directory change is successful, the function updates the `PWD` environment variable
 *   with the new directory using `setenv()`.
 * - If any of the system calls (`chdir()`, `getcwd()`, or `setenv()`) fail, an error message is printed.
 * 
 * Returns:
 * - None (void)
 */
void builtin_cd(char *arg) {
    char cwd[MAX_LINE];  // Buffer to store the current working directory

    // Change to the specified directory
    if (chdir(arg) != 0) {
        perror("cd");  // Print error if chdir fails
	last_exit_status = -1;
	return;
    }

    // Get the new current working directory after changing directory
    if (getcwd(cwd, sizeof(cwd)) == NULL) {
        perror("getcwd failed");
	last_exit_status = -1;
	return;
    }

    // Update the PWD environment variable with the new working directory
    if (setenv("PWD", cwd, 1) != 0) {
        perror("setenv failed");
	last_exit_status = -1;
	return;
    }
}

/* Comparison function for `qsort`, used to sort an array of strings in alphabetical order.
 * 
 * a: pointer to the first element to compare (a pointer to a string).
 * b: pointer to the second element to compare (a pointer to a string).
 * 
 * Notes:
 * - This function casts the `void *` pointers to `const char **` and compares the strings 
 *   using `strcmp()`.
 * - It returns:
 *   - A negative value if the first string is less than the second string.
 *   - 0 if the two strings are equal.
 *   - A positive value if the first string is greater than the second string.
 * 
 * Returns:
 * - Integer result of the comparison, based on `strcmp`.
 */
int compare(const void *a, const void *b) {
    const char **str_a = (const char **)a;
    const char **str_b = (const char **)b;
    return strcmp(*str_a, *str_b);  // Compare strings alphabetically
}

/* Built-in `ls` function to list the contents of the current directory, excluding hidden files.
 * The filenames are listed alphabetically.
 * 
 * Notes:
 * - This function opens the current directory using `opendir()` and reads the directory entries.
 * - It skips hidden files (those starting with a dot).
 * - The filenames are stored in an array, sorted alphabetically using `qsort()`, and printed.
 * - Memory allocated for the filenames (via `strdup`) is freed after printing.
 * 
 * Returns:
 * - None (void)
 */
void builtin_ls() {
    DIR *dir;
    struct dirent *entry;
    char *filenames[1024];  // Array to store filenames
    int count = 0;

    // Open the current directory
    dir = opendir(".");
    if (dir == NULL) {
        perror("ls");  // Handle error if the directory cannot be opened
	last_exit_status = -1;
	return;
    }

    // Read the directory entries and store the names in filenames[]
    while ((entry = readdir(dir)) != NULL) {
        if (entry->d_name[0] == '.') {
            // Skip hidden files (those starting with '.')
            continue;
        }
        filenames[count] = strdup(entry->d_name);  // Copy the filename into the array
        count++;
    }

    closedir(dir);  // Close the directory after reading all entries

    // Sort the filenames alphabetically using qsort
    qsort(filenames, count, sizeof(char *), compare);

    // Print the sorted filenames
    for (int i = 0; i < count; i++) {
        printf("%s\n", filenames[i]);
        free(filenames[i]);  // Free the memory allocated by strdup
    }
}

/* Performs variable substitution in a command string by replacing any variables
 * (indicated by a leading $) with their corresponding values (environment or shell variables).
 * 
 * command: pointer to the command string in which variable substitution will be performed
 * 
 * Notes:
 * - The function looks for variables in the command, starting with '$', and replaces them
 *   with the corresponding environment variable or shell variable values.
 * - If neither an environment variable nor a shell variable is found, the variable is replaced
 *   with an empty string.
 * 
 * Returns:
 * - None (void). The command string is modified in place.
 */
void substitute_variables(char *command) {
    char temp[MAX_LINE]; // Store the substituted command
    char *ptr = command;
    int i = 0; // Index for temp

    while (*ptr != '\0') {
        if (*ptr == '$') {
            ptr++;  // Skip the '$'
            char var_name[MAX_LINE];
            int j = 0;

            // Extract the variable name
            while (*ptr != ' ' && *ptr != '\0') {
                var_name[j++] = *ptr++;
            }
            var_name[j] = '\0';

            // Try to find the variable value (environment takes precedence)
            char *env_value = getenv(var_name);
            char *shell_value = find_shell_var(var_name);

            if (env_value) {
                // Environment variable found
                strcpy(&temp[i], env_value);
                i += strlen(env_value);
            } else if (shell_value) {
                // Shell variable found
                strcpy(&temp[i], shell_value);
                i += strlen(shell_value);
            }
            // If neither found, it just substitutes with an empty string
        } else {
            temp[i++] = *ptr++;
        }
    }

    temp[i] = '\0';  // Null-terminate
    strcpy(command, temp);  // Replace original command with substituted command
}

/* Resolves the command by searching the directories listed in the `$PATH` environment variable.
 * If the command contains a '/', it is treated as a full or relative path.
 * 
 * command: string representing the command to be resolved (either an executable name or path).
 * 
 * Notes:
 * - If the command contains a '/', the function treats it as a full or relative path and checks 
 *   if the command is executable.
 * - If no '/' is found, the function searches the directories in the `$PATH` environment variable.
 * - If the command is found in one of the directories and is executable, the function returns the full path.
 * - If the command is not found or is not executable, the function returns `NULL`.
 * - Memory allocated by `strdup()` is freed after usage.
 * 
 * Returns:
 * - Pointer to a string containing the full path to the executable if found and executable.
 * - `NULL` if the command is not found or not executable.
 */
char *resolve_command(char *command) {
    // If the command contains a '/', treat it as a full or relative path
    if (strchr(command, '/')) {
        if (access(command, X_OK) == 0) {
            return strdup(command);  // Return dynamically allocated command
        }
        return NULL;  // Command not found or not executable
    }

    // Get path from environment variable
    char *path = getenv("PATH");

    char *path_copy = strdup(path);  // Make a copy since strtok modifies the string
    if (!path_copy) {
        perror("Memory allocation failed");
        last_exit_status = -1;
	return NULL;
    }

    char *dir = strtok(path_copy, ":");
    char full_path[MAX_LINE];

    while (dir != NULL) {
        snprintf(full_path, sizeof(full_path), "%s/%s", dir, command);
        if (access(full_path, X_OK) == 0) {  // Check if the command is executable
            free(path_copy);
            return strdup(full_path);  // Return dynamically allocated path
        }
        dir = strtok(NULL, ":");
    }

    free(path_copy);  // Clean up
    return NULL;  // Command not found in any directory
}

/* Executes a built-in or external command, handling redirection, variable substitution, and history.
 * 
 * command: string representing the command to be executed, including any arguments or redirections.
 * 
 * Notes:
 * - The command is tokenized and processed to handle variable substitution and redirection.
 * - If the command is a built-in (`exit`, `cd`, `export`, `local`, `vars`, `ls`, or `history`), the corresponding built-in function is executed.
 * - If the command is not a built-in, it is searched in the directories listed in `$PATH`, and executed if found.
 * - Redirections (`<`, `>`, `>>`, `&>`, `&>>`) are handled, and standard input/output/error can be redirected.
 * - Commands are added to the history unless they are built-ins.
 * - If the command is not found or cannot be executed, an error is printed.
 * 
 * Returns:
 * - 0 on success.
 * - -1 on failure
 */
int execute_command(char *command) {
    char *args[MAX_LINE / 2 + 1];  // Command arguments (splitting command into words)
    char *token;
    int arg_count = 0;
    
    int input_fd = -1, output_fd = -1, error_fd = -1;  // File descriptors for redirection
    
    // Save the original command for history before tokenization
    char original_command[MAX_LINE];
    strncpy(original_command, command, MAX_LINE - 1);
    original_command[MAX_LINE - 1] = '\0';  // Ensure null termination

    substitute_variables(command); // substitute local or environ variable to actual value

    // Tokenize the command (split by space)
    token = strtok(command, " \t\n");
    while (token != NULL) {
        args[arg_count++] = token;
        token = strtok(NULL, " \t\n");
    }

    args[arg_count] = NULL;  // Null-terminate the arguments list

    if (arg_count == 0) return 0;  // Empty command

    // Handle redirection
    if (handle_redirection(args, &input_fd, &output_fd, &error_fd) != 0) {
        return -1;
    }

    // Handle built-in commands
    if (strcmp(args[0], "exit") == 0) {
        if (arg_count > 1) {
            fprintf(stderr, "exit: too many arguments\n");
            last_exit_status = -1;
	    return -1;
        }
	free_history(&history);
        exit(last_exit_status);
    } else if (strcmp(args[0], "cd") == 0) {
        if (arg_count != 2) {
            fprintf(stderr, "cd: wrong number of arguments\n");
	    last_exit_status = -1;
	    return -1;
        } else {
            builtin_cd(args[1]);
	    last_exit_status = 0;
	    return 0;
        }
    } else if (strcmp(args[0], "export") == 0) {
        if (arg_count != 2) {
            fprintf(stderr, "export: wrong number of arguments\n");
	    last_exit_status = -1;
	    return -1;
        } else {
            builtin_export(args[1]);
	    last_exit_status = 0;
	    return 0;
        }
    } else if (strcmp(args[0], "local") == 0) {
        if (arg_count != 2) {
            fprintf(stderr, "local: wrong number of arguments\n");
	    last_exit_status = -1;
	    return -1;
        } else {
            builtin_local(args[1]);
	    last_exit_status = 0;
	    return 0;
        }
    } else if (strcmp(args[0], "vars") == 0) {
        if (arg_count > 1) {
	    fprintf(stderr, "vars: wrong number of arguments\n");
	    last_exit_status = -1;
	    return -1;
	} else {
	    builtin_vars();
	    last_exit_status = 0;
	    return 0;
	}
    } else if (strcmp(args[0], "ls") == 0) {
        if (arg_count > 1) {
            fprintf(stderr, "ls: wrong number of arguments\n");
	    last_exit_status = -1;
	    return -1;
        } else {
            builtin_ls();
	    last_exit_status = 0;
	    return 0;
        }
    } else if (strcmp(args[0], "history") == 0) {
        if (arg_count == 1) {
            print_history(&history);
        } else if (arg_count == 3 && strcmp(args[1], "set") == 0) {
            int new_size = atoi(args[2]);
            resize_history(&history, new_size);
        } else if (arg_count == 2) {
            int index = atoi(args[1]);
            execute_history(&history, index);
        } else {
            fprintf(stderr, "history: wrong number of arguments\n");
	    last_exit_status = -1;
            return -1;
	}
	last_exit_status = 0;
        return 0;
    }

    // If command is not a built-in, add it to history
    add_history(&history, original_command);

    // Resovle the command using $PATH
    char *resolved_command = resolve_command(args[0]);
    if (resolved_command == NULL) {
        fprintf(stderr, "Command not found: %s\n", args[0]);
        last_exit_status = -1;
	return -1;
    }

    // If not a built-in command, fork a process and execute it
    pid_t pid = fork();
    if (pid < 0) {
        perror("fork failed");
	last_exit_status = -1;
        return -1;
    } else if (pid == 0) {
        // In child process: handle redirection
        if (input_fd != -1) {
            dup2(input_fd, STDIN_FILENO);  // Redirect input
            close(input_fd);
        }
        if (output_fd != -1) {
            dup2(output_fd, STDOUT_FILENO);  // Redirect output
            close(output_fd);
        }
        if (error_fd != -1) {
            dup2(error_fd, STDERR_FILENO);  // Redirect stderr
            close(error_fd);
        }
	// Use execv (requires the full path)
	if (execv(resolved_command, args) == -1) {
    	// If execv fails
    	perror("execv failed");
	free_history(&history);
    	exit(-1);
	}
    } else {
    	// In parent process: wait for the child to finish
        wait(NULL);
    }
    free(resolved_command);
    return 0;
}

/* Checks if a line is a comment by ignoring leading spaces and checking if the first 
 * non-space character is a `#`.
 *
 * line: pointer to the input string (line of text).
 *
 * Notes:
 * - The function uses `strip_leading_spaces` to skip any leading spaces before checking.
 * - Lines starting with `#` after any leading spaces are considered comments.
 *
 * Returns:
 * - 1 if the line is a comment.
 * - 0 otherwise.
 */
int is_comment(char *line) {
    char *stripped = strip_leading_spaces(line);
    return (stripped[0] == '#');
}

/* Removes leading spaces from a string and returns a pointer to the first non-space character.
 * 
 * str: pointer to the string from which leading spaces will be removed
 * 
 * Notes:
 * - This function moves the pointer forward past any leading spaces until the first non-space character is found.
 * - If the string contains only spaces or is empty, the pointer will be moved to the null terminator.
 * 
 * Returns:
 * - Pointer to the first non-space character in the string
 */
char *strip_leading_spaces(char *str) {
    while (*str == ' ') str++;
    return str;
}

/* Handles the shell's interactive mode, where the user enters commands manually.
 * The function prompts the user, reads the input, and executes commands until the end of input.
 *
 * Notes:
 * - Leading spaces are stripped from each line of input.
 * - Empty lines and comment lines (starting with '#') are ignored.
 * - The shell continues running until the input ends (Ctrl+D or exit).
 *
 * Returns:
 * - None (void).
 */
void interactive_mode() {
    char line[MAX_LINE];

    // Treat input redirection as if it's interactive mode
    while (1) {

        // Print prompt only if there's input (i.e., fgets didn't return NULL)
        printf("wsh> ");
	// Read input from stdin (either from terminal or redirected file)
        if (fgets(line, sizeof(line), stdin) == NULL) {
            // End of input (Ctrl+D or end of file), so break the loop
            break;
        }

        fflush(stdout);  // Ensure the prompt is displayed immediately

        // Remove the trailing newline character
        line[strcspn(line, "\n")] = '\0';
	// Strip the leading white spaces	
	char *stripped_line = strip_leading_spaces(line);

        // Skip empty lines and comment lines
        if (strlen(stripped_line) == 0 || is_comment(stripped_line)) {
            continue;
        }

        // Execute the input command
        execute_command(line);
    }
    if (last_exit_status == -1) {
    	free_history(&history);
	exit(-1);
    }
}

/* Handles batch mode execution, reading commands from a batch file or stdin.
 * Each command is processed sequentially until the end of the file or input.
 *
 * batch_file: pointer to a string containing the name of the batch file. If null, reads from stdin.
 *
 * Notes:
 * - Leading spaces are stripped from each line before processing.
 * - Empty lines and comment lines (starting with '#') are ignored.
 * - If a batch file is provided, it is opened and closed appropriately.
 *
 * Returns:
 * - None (void).
 */
void batch_mode(const char *batch_file) {
    FILE *file;

    // Open the batch file or read from stdin if not provided
    if (batch_file) {
        file = fopen(batch_file, "r");
        if (file == NULL) {
            perror("Error opening batch file");
            exit(1);
        }
    } else {
        file = stdin;  // Read from stdin if no batch file is provided
    }

    char line[MAX_LINE];
    while (fgets(line, sizeof(line), file) != NULL) {
        line[strcspn(line, "\n")] = '\0';  // Strip the trailing newline character
	// Strip the leading white spaces
	char *stripped_line = strip_leading_spaces(line);

        // Skip empty lines and comment lines
        if (strlen(stripped_line) == 0 || is_comment(stripped_line)) {
            continue;
        }

        // Execute the command without printing the prompt
        execute_command(line);
    }

    if (batch_file) {
        fclose(file);
    }
    if (last_exit_status == -1) {
        free_history(&history);
        exit(-1);
    }
}

/* Main function to handle shell execution in either interactive or batch mode.
 * It initializes the shell history, checks the provided arguments, and determines
 * whether to run in interactive or batch mode based on the input.
 *
 * argc: number of arguments provided to the shell.
 * argv: array of argument strings (optional batch file name as the second argument).
 *
 * Notes:
 * - If no arguments are provided, the shell runs in interactive mode.
 * - If a batch file is provided as an argument, the shell runs in batch mode.
 * - If more than one argument is provided, the usage message is printed and the shell exits.
 *
 * Returns:
 * - 0 on successful execution.
 * - Exits with code 1 on invalid usage or errors.
 */
int main(int argc, char *argv[]) {
    // Initialize history and path at the start
    init_history(&history);
    init_path();
    // Check if more than two arguments (invalid usage)
    if (argc > 2) {
        fprintf(stderr, "Usage: %s [batch-file]\n", argv[0]);
        exit(1);
    }

    // Check if input is coming from a terminal (interactive mode)
    if (argc == 1) {
        // No arguments and input is from terminal: interactive mode
        interactive_mode();
    } else {
        // One argument: batch mode
        batch_mode(argv[1]);
    }

    return 0;
}

