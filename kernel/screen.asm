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
; *                             KERNEL SCREEN FUNCTIONS                         *
; *******************************************************************************


VIDEO_MEMORY            equ 0xB8000         ; Address of VGA mode 3
VIDEO_ROWS              equ 25              ; Number of rows
VIDEO_COLUMNS           equ 80              ; Number of columns
VIDEO_END               equ VIDEO_MEMORY + VIDEO_ROWS * VIDEO_COLUMNS

ENDL                    equ 0x0A            ; New line character

[BITS 32]                                   ; Protected mode on 32 bits

screen_cursor dw 0                          ; Cursor position

; Move cursor
; @param    bx = cursor position
screen_set_cursor:
    push ax
    push dx

    mov [screen_cursor], bx

    mov dx, 0x03D4
    mov al, 0x0F
    out dx, al                              ; Prepare to write cursor low byte

    mov dx, 0x03D5
    mov al, bl
    out dx, al                              ; Write cursor low byte

    mov dx, 0x03D4
    mov al, 0x0E
    out dx, al                              ; Prepare to write cursor high byte

    mov dx, 0x03D5
    mov al, bh
    out dx, al                              ; Write cursor high byte

    pop dx
    pop ax
    ret

; Print character
; @param    ah = character style
; @param    al = ascci character
screen_printchar:
    push ebx

    cmp al, ENDL                            ; Check end line
    jne .continue

    call screen_newline
    jmp .end

.continue:
    mov bx, [screen_cursor]
    shl bx, 1                               ; Multiply by two
    add ebx, VIDEO_MEMORY                   ; edx = VIDEO_MEMORY + (2 * cursor)
    mov [ebx], ax

    mov bx, [screen_cursor]                 ; cursor++
    inc bx
    call screen_set_cursor                  ; Update character cursor

.end:
    pop ebx
    ret

; Print message
; String end when zero
; @param    ah = character style
; @param    ebx = Pointer to string
screen_print:
    mov al, [ebx]
    test al, al
    je .done                                ; End loop when '0' is found

    call screen_printchar
    inc ebx                                 ; ebx++
    jmp screen_print
.done:
    ret

; Clear screen
; @param    ah = character style
screen_clear:
    pushad

    mov al, 0
    mov edi, VIDEO_MEMORY
    mov ecx, VIDEO_ROWS * VIDEO_COLUMNS
    rep stosw

    mov bx, 0
    call screen_set_cursor                  ; Update character cursor

    popad
    ret

; Decrease cursor and remove last character
screen_backspace:
    push ebx

    xor ebx, ebx

    mov bx, [screen_cursor]                 ; cursor--
    dec bx
    call screen_set_cursor                  ; Update character cursor

    shl ebx, 1                              ; Multiply by 2
    add ebx, VIDEO_MEMORY                   ; Add offset
    mov [ebx], byte 0x0                     ; Clear character

    pop ebx
    ret

; Move cursor to next line
screen_newline:
    push eax
    push ebx

    xor eax, eax
    mov ebx, eax

    mov ax, [screen_cursor]                 ; Load cursor
    mov bl, VIDEO_COLUMNS                   ; Prepare divisor
    div bl

    sub bl, ah                              ; Offset to newline
    add bx, [screen_cursor]
    call screen_set_cursor                  ; Move cursor

.end:
    pop ebx
    pop eax
    ret
