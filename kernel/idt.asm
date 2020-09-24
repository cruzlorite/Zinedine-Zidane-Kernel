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
; *                         INTERRUPT DESCRIPTOR TABLE                          *
; *******************************************************************************


; see https://wiki.osdev.org/Interrupt_Descriptor_Table
; see http://www.jamesmolloy.co.uk/tutorial_html/4.-The%20GDT%20and%20IDT.html

; Macro that defines an IDT descriptor
%define idt_descriptor(off1, sel, attr, off2) dw off1, sel, attr << 8, off2

idt:
    .start:
        times 32 idt_descriptor(useless_isr, gdt.code_descriptor, 0x8E, 0x0)    ; Reserved by Intel, from 0x0 to 0x1F

        idt_descriptor(int20h, gdt.code_descriptor, 0x8E, 0x0)                  ; Clock isr,    INT 20h, IRQ0
        idt_descriptor(int21h, gdt.code_descriptor, 0x8E, 0x0)                  ; Keyboard isr, INT 21h, IRQ1
    .end:
    .register:
        dw idt.end - idt.start - 1          ; Defines the length of the IDT in bytes - 1
        dd idt.start                        ; This 32 bits are the linear address where the IDT starts


; *******************************************************************************
; *                      INTERRUPTION SERVICE ROUTINES WRAPPERS                 *
; *******************************************************************************


[BITS 32]

useless_isr:
    iret                                    ; Default isr that is useless

int20h:
    pushad
    call clk.isr_handler
    popad
    iret

int21h:
    pushad
    call kbd.isr_handler
    popad
    iret