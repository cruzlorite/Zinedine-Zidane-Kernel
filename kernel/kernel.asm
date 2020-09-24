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
; *                                 KERNEL                                      *
; *******************************************************************************


%include "../kernel/gdt.asm"                ; Global descriptor table
%include "../kernel/idt.asm"                ; Interrupt descriptor table
%include "../kernel/pic.asm"                ; init_pic and eoi functions
%include "../kernel/clk.asm"                ; Clock isr handler
%include "../kernel/shell.asm"              ; Shell program


[BITS 32]                                   ; Protected mode on 32 bits

STACK_SIZE   equ 0x40                       ; Stack of 64 double words (64 * 4 bytes)

kernel:
    mov ax,     gdt.data_descriptor         ; Set segment registers to gdt data descriptor
    mov ds,     ax
    mov es,     ax
    mov fs,     ax
    mov gs,     ax
    mov ss,     ax
    mov esp,    stack.top                   ; Set stack pointer

    lidt [idt.register]                     ; Load IDT
    call init_pic                           ; Initialize PIC
    sti                                     ; Enable interruptions

    jmp shell                               ; Jump to shell


; *******************************************************************************
; *                           STACK (PUSH/POP)                                  *
; *******************************************************************************


stack:                                      ; Reserve space for stack
    times STACK_SIZE dd 0
    .top:                                   ; Stack top pointer