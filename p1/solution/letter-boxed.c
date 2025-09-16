#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_WORD_LENGTH 100
#define MAX_SIDES 26
#define ALPHABET_SIZE 26

// Structure to represent a side of the board
typedef struct {
    int num_letters;
    char *letters;
} Side;

// Structure to represent the board
typedef struct {
    int num_sides;
    Side *sides;
} Board;

// Function prototypes
Board load_board(const char *filename);
char **load_dictionary(const char *filename, int *word_count);
int is_valid_word(const char *word, Board *board, char **dictionary, int dict_word_count, int prev_side);
int all_letters_used(Board *board, char *used_letters);
int get_side(Board *board, char letter);
void check_board_validity(Board *board);
int solve_board(Board *board, char **dictionary, int dict_word_count);

// Main function
int main(int argc, char *argv[]) {
    if (argc != 3) {
        exit(1);
    }

    // Load board and dictionary
    Board board = load_board(argv[1]);
    check_board_validity(&board);  // Check if the board is valid (fewer than 3 sides or duplicate letters)

    int dict_word_count;
    char **dictionary = load_dictionary(argv[2], &dict_word_count);

    // Solve the board
    if (solve_board(&board, dictionary, dict_word_count)) {
        printf("Correct\n");
    }

    // Free allocated memory
    for (int i = 0; i < dict_word_count; i++) {
        free(dictionary[i]);
    }
    free(dictionary);

    for (int i = 0; i < board.num_sides; i++) {
        free(board.sides[i].letters);
    }
    free(board.sides);

    return 0;
}
// Function to load the board from a file
Board load_board(const char *filename) {
    Board board;
    FILE *file = fopen(filename, "r");
    if (!file) {
        exit(1);
    }

    // Initialize board structure
    board.num_sides = 0;
    board.sides = NULL;

    // Read each line as a side
    char line[MAX_WORD_LENGTH];
    while (fgets(line, sizeof(line), file)) {
        // Remove newline character if present
        line[strcspn(line, "\n")] = '\0';
        
        // Allocate or reallocate memory for sides
        board.sides = realloc(board.sides, (board.num_sides + 1) * sizeof(Side));
        if (!board.sides) {
            exit(1);
        }

        // Initialize the new side
        size_t line_length = strlen(line);
        board.sides[board.num_sides].num_letters = line_length;
        board.sides[board.num_sides].letters = malloc((line_length + 1) * sizeof(char)); // +1 for the null terminator
        if (!board.sides[board.num_sides].letters) {
            exit(1);
        }

        // Use strncpy to avoid buffer overflow
        strncpy(board.sides[board.num_sides].letters, line, line_length + 1);
        board.num_sides++;
    }

    fclose(file);
    return board;
}
// Function to check if the board is valid
void check_board_validity(Board *board) {
    if (board->num_sides < 3) {
        printf("Invalid board\n");
        exit(1);
    }

    int letter_count[ALPHABET_SIZE] = {0};
    for (int i = 0; i < board->num_sides; i++) {
        for (int j = 0; j < board->sides[i].num_letters; j++) {
            char letter = board->sides[i].letters[j];
            if (++letter_count[letter - 'a'] > 1) {
                printf("Invalid board\n");
                exit(1);
            }
        }
    }
}
char *my_strdup(const char *s) {
    char *dup = malloc(strlen(s) + 1);  // Allocate memory for the string copy
    if (dup != NULL) {
        strcpy(dup, s);  // Copy the contents of s into the newly allocated memory
    }
    return dup;
}
// Function to load dictionary from a file
char **load_dictionary(const char *filename, int *word_count) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        exit(1);
    }

    char **dictionary = malloc(100000 * sizeof(char *));
    *word_count = 0;

    char word[MAX_WORD_LENGTH];
    while (fscanf(file, "%s", word) == 1) {
        dictionary[*word_count] = my_strdup(word);
        (*word_count)++;
    }

    fclose(file);
    return dictionary;
}

// Function to check if a word is valid
int is_valid_word(const char *word, Board *board, char **dictionary, int dict_word_count, int prev_side) {
    // Check if word is in dictionary
    (void)prev_side;
    int valid_word = 0;
    for (int i = 0; i < dict_word_count; i++) {
        if (strcmp(word, dictionary[i]) == 0) {
            valid_word = 1;
            break;
        }
    }

    if (!valid_word) {
        printf("Word not found in dictionary\n");
        exit(0);
    }

    // Check if word can be formed based on board rules
    int word_len = strlen(word);
    int last_side = -1;

    for (int i = 0; i < word_len; i++) {
        char letter = word[i];
        int current_side = get_side(board, letter);

        if (current_side == -1) {
            printf("Used a letter not present on the board\n");
            exit(0);
        }

        if (i > 0 && current_side == last_side) {
            printf("Same-side letter used consecutively\n");
            exit(0);
        }

        last_side = current_side;
    }

    return 1;
}

// Function to determine which side a letter belongs to
int get_side(Board *board, char letter) {
    for (int i = 0; i < board->num_sides; i++) {
        for (int j = 0; j < board->sides[i].num_letters; j++) {
            if (board->sides[i].letters[j] == letter) {
                return i;
            }
        }
    }
    return -1;  // Letter not found on any side
}

// Function to check if all letters on the board are used
int all_letters_used(Board *board, char *used_letters) {
    for (int i = 0; i < board->num_sides; i++) {
        for (int j = 0; j < board->sides[i].num_letters; j++) {
            char letter = board->sides[i].letters[j];
            if (!used_letters[letter - 'a']) {
                return 0;  // Not all letters have been used
            }
        }
    }
    return 1;
}
// Function to solve the board
int solve_board(Board *board, char **dictionary, int dict_word_count) {
    char used_letters[ALPHABET_SIZE] = {0};
    char input[MAX_WORD_LENGTH];
    char last_letter = '\0';
    int prev_side = -1;

    while (1) {
        if (scanf("%s", input) != 1) {
            break;
        }

        if (last_letter != '\0' && input[0] != last_letter) {
            printf("First letter of word does not match last letter of previous word\n");
            exit(0);
        }

        if (!is_valid_word(input, board, dictionary, dict_word_count, prev_side)) {
            continue;
        }

        // Mark letters as used
        size_t input_length = strlen(input);
        for (size_t i = 0; i < input_length; i++) {
            used_letters[input[i] - 'a'] = 1;
        }

        last_letter = input[input_length - 1];
        prev_side = get_side(board, last_letter);

        if (all_letters_used(board, used_letters)) {
            return 1;  // Board solved
        }
    }

    printf("Not all letters used\n");
    exit(0);
}

