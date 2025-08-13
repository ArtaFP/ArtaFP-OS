ENTRY(_start)
OUTPUT_FORMAT(elf32-i386)

SECTIONS {
    . = 1M;  /* Kernel loads at 1MB */

    .multiboot : {
        *(.multiboot)
    }

    .text : {
        *(.text)  /* Includes kmain() */
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(COMMON)
        *(.bss)
    }
}