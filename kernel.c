// kernel.c
#include "vga.h"
#include "keyboard.h"

void kmain(void) {
    vga_initialize();
    vga_clear();
    vga_puts("Hello, Improved OS!\n");
    
    if (!keyboard_init()) {
        vga_setcolor(vga_entry_color(RED, BLACK));
        vga_puts("Keyboard init failed!\n");
    } else {
        vga_puts("Type something (ESC to quit):\n");
        
        while (1) {
            char c = keyboard_getchar();
            if (c == 0x1B) break;  // ESC key
            if (c != 0) {
                vga_putchar(c);
            }
        }
    }
    
    vga_setcolor(vga_entry_color(GREEN, BLACK));
    vga_puts("\nGoodbye!\n");
    while(1);
}