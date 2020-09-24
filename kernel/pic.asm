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
; *                     8259 PROGRAMABLE INTERRUPT CONTROLLER                   *
; *******************************************************************************


PIC1_CMD_PORT	        equ 0x20            ; 8259 PIC master command port
PIC1_DATA_PORT          equ 0x21            ; 8259 PIC master data port
PIC2_CMD_PORT	        equ 0xA0            ; 8259 PIC slave command port
PIC2_DATA_PORT	        equ 0xA1            ; 8259 PIC slave command port
PIC_EOI		            equ 0x20    		; End-of-interrupt command code

[BITS 32]                                   ; Protected mode on 32 bits

; Initialize 8259 Programmable Interrupt Controller
; see https://wiki.osdev.org/8259_PIC
; Destroyed: al
init_pic:
    mov al, 00010001b                   ; b4=1: Init; b3=0: Edge; b1=0: Cascade; b0=1: Need 4th init step
    out PIC1_CMD_PORT, al               ; Tell master
    out PIC2_CMD_PORT, al               ; Tell slave

    mov al, 0x20                        ; Map master IRQ0 to INT 20h
    out PIC1_DATA_PORT, al              ; Tell master

    mov al, 0x28                        ; Map slave IRQ8 to INT 28h
    out PIC2_DATA_PORT, al              ; Tell slave

    mov al, 00000100b                   ; Master has a Slave on input #2
    out PIC1_DATA_PORT, al              ; Tell master

    mov al, 0x2                         ; Slave is on Master's input #2
    out PIC2_DATA_PORT, al              ; Tell slave

    mov al, 0x01                        ; b4=0: FNM; b3-2=00: Master/Slave set by hardware; b1=0: Not AEOI; b0=1: x86 mode
    out PIC1_DATA_PORT, al              ; Tell master
    out PIC2_DATA_PORT, al              ; Tell slave

    mov al, 11111101b                   ; Master enable IRQ0 = b0 and IRQ1 = b1. Clock and keyboard
    out PIC1_DATA_PORT, al              ; Tell master

    mov al, 11111111b                   ; Slave disable all
    out PIC2_DATA_PORT, al              ; Tell slave
    ret

; End of interruption (Only master)
; see https://wiki.osdev.org/8259_PIC#End_of_Interrupt
; Destroyed : al
eoi_master:
    mov al, PIC_EOI
    out PIC1_CMD_PORT, al                   ; Send EOI to Master PIC
    ret

; End of interruption (Master and slave)
; see https://wiki.osdev.org/8259_PIC#End_of_Interrupt
; Destroyed: al
eoi_master_slave:
    mov al, PIC_EOI
    out PIC1_CMD_PORT, al                   ; Send EOI to Master PIC
    out PIC2_CMD_PORT, al                   ; Send EOI to Slave PIC
    ret
