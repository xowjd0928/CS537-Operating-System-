CC = gcc
CFLAGS-common = -std=c17 -Wall -Wextra -Werror -pedantic
CFLAGS = $(CFLAGS-common) -O2
CFLAGS-dbg = $(CFLAGS-common) -Og -g
TARGET = letter-boxed
SRC = $(TARGET).c

all: $(TARGET) $(TARGET)-dbg

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $< -o $@

$(TARGET)-dbg: $(SRC)
	$(CC) $(CFLAGS-dbg) $< -o $@

clean:
	rm -f $(TARGET) $(TARGET)-dbg
