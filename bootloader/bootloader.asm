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
; *                                 BOOTLOADER                                  *
; *******************************************************************************


BOOTLOADER_ORG          equ 0x7C00          ; The BIOS loads the zzkernel at 0000:7C00
BOOTLOADER_SIGNATURE    equ 0xAA55          ; Bootloader signature (little endian)
SECONDLOADER_ORG        equ 0x1000          ; Bootloader second stage origin

[BITS   16]                                 ; The zzkernel runs on Real Mode 16 bits
[ORG    BOOTLOADER_ORG]

; Bootloader located at disk first sector
bootloader:
    .load_kernel_from_disk:
        mov ah, 0x0   	                    ; Reset disk
        mov dl, 0	                        ; Drive number
        int 0x13                            ; Call BIOS service

        mov ah, 0x2	                        ; Function 0x2, read sectors into memory
        mov al, 0x6   	                    ; Number of sectors to read (5)
        mov dl, 0	                        ; Drive number
        mov ch, 0	                        ; Cylinder number
        mov dh, 0	                        ; Head number
        mov cl, 2	                        ; Starting sector number
        mov bx, SECONDLOADER_ORG            ; Direction where to load the kernel
        int 0x13	                        ; Call BIOS service

    jmp SECONDLOADER_ORG                    ; Jump to second stage loader

times 510 - ($ - $$) db 0                   ; Fill first sector with zeros
dw BOOTLOADER_SIGNATURE                     ; Bootloader signature