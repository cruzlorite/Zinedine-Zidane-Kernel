;   Copyright 2020 José María Cruz Lorite
;
;   This program is free software: you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation, either version 3 of the License, or
;   (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with this program.  If not, see <https://www.gnu.org/licenses/>.


; *******************************************************************************
; *                         SECOND STAGE BOOTLOADER                             *
; *******************************************************************************


SECONDLOADER_ORG   equ 0x1000               ; Bootloader second stage origin

[BITS 16]                                   ; The zzkernel runs on Real Mode 16 bits
[ORG  SECONDLOADER_ORG]

second_bootloader:
    mov sp, SECONDLOADER_ORG                ; Set stack pointer before second zzkernel
    call videoplayer                        ; Play ZZ video

    .load_gdt:
        cli                                 ; Disable interrupts
        lgdt [gdt.register]                 ; Load GDT

    .enable_A20:                            ; By default it's enabled (I use ubuntu1~18.04.1, qemu-system-i386)
        ; Do nothing

    .enable_protected_mode:
        mov eax, cr0
        or  eax, 0x1                        ; PE (Protected Mode Enabled) bit in cr0 (Control Register 0)
        mov cr0, eax

    .jump_to_kernel:
        jmp gdt.code_descriptor:kernel      ; Jump to 32 bits kernel. [kernel] defined on ../kernel/kernel.asm


%include "../bootloader/videoplayer.asm"    ; ZZ video player
%include "../kernel/kernel.asm"             ; Place Kernel just after second zzkernel

times 2560 - ($ - $$) db 0                  ; Fill five sectors