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
; *                            GLOBAL DESCRIPTOR TABLE                          *
; *******************************************************************************


; see https://wiki.osdev.org/Global_Descriptor_Table
; see https://wiki.osdev.org/GDT_Tutorial
gdt:
    .start:
; NULL descriptor, an empty descriptor that is required.
; Some use this descriptor to store a pointer to the GDT itself.
; The null descriptor is 8 bytes wide and the pointer (GTDR) is 6 bytes
; wide so it might just be the perfect place for this.
    .register:
; https://en.wikibooks.org/wiki/X86_Assembly/Global_Descriptor_Table
; LIMIT is the size of the GDT, and BASE is the starting address.
; LIMIT is 1 less than the length of the table, so if LIMIT has the value
; 15, then the GDT is 16 bytes long.
        dw gdt.end - gdt.start - 1          ; Limit
        dd gdt.start                        ; Base
        dw 0                                ; Fill last two bytes
    .code:
        dw 0xFFFF                           ; Limit = 0xFFFF (with page granularity turned on, this is actually 4GB)
        dw 0x0                              ; Base address = 0x0
        db 0x0
        db 10011010b                        ; Access byte
        db 11001111b                        ; Flags
        db 0x0
    .data:
        dw 0xFFFF                           ; Limit = 0xFFFF (with page granularity turned on, this is actually 4GB)
        dw 0x0                              ; Base address = 0x0
        db 0x0
        db 10010010b                        ; Access byte
        db 11001111b                        ; Flags
        db 0x0
    .end:
    .code_descriptor equ gdt.code - gdt.start
    .data_descriptor equ gdt.data - gdt.start