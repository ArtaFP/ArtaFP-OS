; boot.s - Multiboot header for GRUB
section .multiboot
align 4
    dd 0x1BADB002          ; Magic number
    dd 0x00000003          ; Flags (align modules + memory map)
    dd -(0x1BADB002 + 3)   ; Checksum

section .text
global _start
extern kmain               ; Your C kernel's entry point

_start:
    call kmain             ; Jump to C code
    cli                    ; Disable interrupts
    hlt                    ; Halt CPU