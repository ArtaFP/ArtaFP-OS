#!/bin/bash
# build.sh - Complete manual OS build script
# Place this in your project root (where boot.asm, kernel.c, etc. are located)

# -------------------------------------------------------------------
# Configuration (edit these if needed)
# -------------------------------------------------------------------
KERNEL_NAME="myos"
ISO_NAME="myos.iso"
GRUB_CFG="isofiles/boot/grub/grub.cfg"  # You maintain this file manually

# -------------------------------------------------------------------
# Build Process
# -------------------------------------------------------------------

# 1. Clean previous builds
#echo "=== Cleaning old build files ==="
#rm -f *.o *.bin *.iso
#rm -rf isofiles

# 2. Compile bootloader (NASM)
echo -e "\n=== Compiling bootloader (boot.asm) ==="
nasm -f elf32 boot.asm -o boot.o || { echo "Bootloader compilation failed!"; exit 1; }

# 3. Compile all C files
echo -e "\n=== Compiling kernel components ==="
for c_file in *.c; do
    echo "-> $c_file"
    gcc -m32 -ffreestanding -Wall -Wextra -I. -c "$c_file" -o "${c_file%.c}.o" || { echo "Compilation failed!"; exit 1; }
done

# 4. Link the kernel
echo -e "\n=== Linking kernel ($KERNEL_NAME.bin) ==="
ld -m elf_i386 -T linker.ld -o "$KERNEL_NAME.bin" *.o || { echo "Linking failed!"; exit 1; }

# 5. Prepare ISO structure
echo -e "\n=== Preparing ISO directory structure ==="
mkdir -p isofiles/boot/grub
cp "$KERNEL_NAME.bin" isofiles/boot/

# 6. Verify GRUB config exists
echo -e "\n=== Checking GRUB configuration ==="
if [ ! -f "$GRUB_CFG" ]; then
    echo "ERROR: No GRUB config found at $GRUB_CFG"
    echo "Create this file manually with these minimum contents:"
    echo "-----------------------------------------------------"
    echo "menuentry \"$KERNEL_NAME\" {"
    echo "    multiboot /boot/$KERNEL_NAME.bin"
    echo "    boot"
    echo "}"
    echo "-----------------------------------------------------"
    echo "Then run this script again."
    exit 1
fi

# 7. Create ISO
echo -e "\n=== Creating bootable ISO ($ISO_NAME) ==="
if command -v grub-mkrescue >/dev/null; then
    grub-mkrescue -o "$ISO_NAME" isofiles || {
        echo "Falling back to xorriso..."
        xorriso -as mkisofs -R -b boot/grub/i386-pc/eltorito.img \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            -o "$ISO_NAME" isofiles
    }
else
    xorriso -as mkisofs -o "$ISO_NAME" isofiles
fi

# 8. Final verification
if [ -f "$ISO_NAME" ]; then
    echo -e "\n=== Build successful! ==="
    echo "ISO: $ISO_NAME"
    echo "Test with: qemu-system-x86_64 -cdrom $ISO_NAME"
else
    echo -e "\n=== Build failed ==="
    exit 1
fi