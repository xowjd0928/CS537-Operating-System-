CC = gcc
CFLAGS-common = -Wall -Wextra -Werror -pedantic -std=gnu18
CFLAGS = $(CFLAGS-common) -O2
CFLAGS-dbg = $(CFLAGS-common) -Og -g
LOGIN = taejeong
SUBMITPATH = ~cs537-1/handin/$(LOGIN)/p3
TARGET = wsh
SRC = $(TARGET).c
HEADER = $(TARGET).h

.PHONY: all clean submit

all: $(TARGET) $(TARGET)-dbg

clean: 
	rm -f $(TARGET) $(TARGET)-dbg

submit: clean
	cp -r ../../p3 $(SUBMITPATH)    

$(TARGET): $(SRC) $(HEADER)
	$(CC) $(CFLAGS) $< -o $@

$(TARGET)-dbg: $(SRC) $(HEADER)
	$(CC) $(CFLAGS-dbg) $< -o $@

