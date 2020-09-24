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
; *                             KEYBOARD CONTROLLER                             *
; *******************************************************************************


KBD_DATA_PORT      equ 0x60            ; Read/Write data Port
KBD_STATUS_PORT    equ 0x64            ; Read Status Register
KBD_CMD_PORT       equ 0x64            ; Write Command Register
KBD_BUFFER_SIZE    equ 0x10            ; Keyboard buffer size

KBD_ENTER          equ 0x0a
KBD_TAB            equ 0x09
KBD_BACKSPACE      equ 0x08

kbd:
    .buffer:    times KBD_BUFFER_SIZE db 0  ; Keyboard buffer
    .readpos:   db 0                        ; Buffer read position
    .pending:   db 0                        ; Buffer pending characters

    ; Clock isr handler
    ; Capture scancode and translate to ascci and store to buffer
    .isr_handler:
        mov al, [.pending]
        cmp al, KBD_BUFFER_SIZE                 ; Compare logical size againts buffer max size
        jge .drop                               ; If (.size < KBD_BUFFER_SIZE) the buffer is not full

        in al, KBD_DATA_PORT                    ; Get scancode
        test al, 0x80                           ; Check key up event?
        jnz .drop                               ; Drop scancode when key up event

        mov ebx, ascii_map                      ; ebx = address of translate table used by XLAT
        xlat                                    ; Translate to ASCII
        test al, al
        je .drop                                ; If character to print is 0 we are finished

        mov si, [.pending]
        add si, [.readpos]
        and si, KBD_BUFFER_SIZE - 1             ; Normalize write to be within 0 to KBD_BUFFER_SIZE
        mov [.buffer + si], al                  ; Save character to buffer
        inc byte [.pending]                     ; pending++

    .drop:
        call eoi_master
        ret

    ; Read character from keyboard buffer
    ; @return al,   Ascci code of next character, if no data is available 0 is returned
    ; Destroyed: al, si
    .read:
        mov al, 0x0
        mov bl, [kbd.pending]
        test bl, bl                             ; Check if buffer is empty
        jz .buffer_empty                        ; If buffer is empty return 0

        mov si, [kbd.readpos]
        and si, KBD_BUFFER_SIZE - 1             ; Normalize read to be within 0 to KBD_BUFFER_SIZE
        mov al, [kbd.buffer + si]               ; Read character
        mov byte [kbd.buffer + si], 0x0         ; Remove character

        dec byte [kbd.pending]                  ; size--
        inc byte [kbd.readpos]                  ; readpos++
    .buffer_empty:
        ret

; Scancode to ASCII character translation table
; backspace -> 0x08
; enter     -> 0x0a
ascii_map:
    db  0,  27, '1', '2', '3', '4', '5', '6', '7', '8'    ; 9
    db '9', '0', '-', '=', KBD_BACKSPACE                  ; Backspace
    db KBD_TAB                                            ; Tab
    db 'q', 'w', 'e', 'r'                                 ; 19
    db 't', 'y', 'u', 'i', 'o', 'p', '[', ']', KBD_ENTER  ; Enter key
    db 0                                                  ; 29   - Control
    db 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';'   ; 39
    db "'", '`', 0                                        ; Left shift
    db "\", 'z', 'x', 'c', 'v', 'b', 'n'                  ; 49
    db 'm', ',', '.', '/', 0                              ; Right shift
    db '*'
    db 0                                                  ; Alt
    db ' '                                                ; Space bar
    db 0                                                  ; Caps lock
    db 0                                                  ; 59 - F1 key ... >
    db 0,   0,   0,   0,   0,   0,   0,   0
    db 0                                                  ; < ... F10
    db 0                                                  ; 69 - Num lock
    db 0                                                  ; Scroll Lock
    db 0                                                  ; Home key
    db 0                                                  ; Up Arrow
    db 0                                                  ; Page Up
    db '-'
    db 0                                                  ; Left Arrow
    db 0
    db 0                                                  ; Right Arrow
    db '+'
    db 0                                                  ; 79 - End key
    db 0                                                  ; Down Arrow
    db 0                                                  ; Page Down
    db 0                                                  ; Insert Key
    db 0                                                  ; Delete Key
    db 0,   0,   0
    db 0                                                  ; F11 Key
    db 0                                                  ; F12 Key
    times 128 - ($-ascii_map) db 0                        ; All other keys are undefined