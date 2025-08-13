// keyboard.h
#pragma once

int keyboard_init(void);  // Changed from void to int
char keyboard_getchar(void);
unsigned char inb(unsigned short port);  // Add port I/O declaration