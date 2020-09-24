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
; *                                 ZZ SHELL                                    *
; *******************************************************************************


%include "../kernel/rtc.asm"                ; Real Time Clock
%include "../kernel/screen.asm"             ; Screen functions
%include "../kernel/kbd.asm"                ; Keyborad buffer and xlat ascci translation table


WHITE_ON_BLUE       equ 0x1F                ; White on blue
GREEN_ON_BLUE       equ 0x1A                ; Green on blue
PINK_ON_BLUE        equ 0x1D                ; Red on blue
YELLOW_ON_BLUE      equ 0x1E                ; Red on blue

SHELL_BUFFER_SIZE   equ 0x40                ; Shell buffer size

[BITS 32]


; Print shell prompt
print_prompt:
    mov ah, GREEN_ON_BLUE                  ; Text style
    mov ebx, prompt                         ; Pointer to prompt string
    call screen_print
    ret

; Shell
shell:
    ; Clear screen
    mov ah, WHITE_ON_BLUE                  ; Slear style
    call screen_clear

    ; Print welcome message
    mov ah, PINK_ON_BLUE                    ; Text style
    mov ebx, welcome_msg                    ; Pointer to string
    call screen_print

    call print_prompt

    ; Loop waiting for keypress
    .loop:
        hlt
        mov al, [kbd.pending]
        test al, al                         ; Check if there are pending characters
        je .loop                            ; Back to .loop if al = 0

    .read_character:
        call kbd.read                       ; Read character from kbd.buffer

        cmp al, KBD_BACKSPACE               ; Check backspace
        je .backspace
        cmp al, KBD_ENTER                   ; Check enter
        je .enter

    .add_character:                         ; If it's not BACKSPACE or ENTER, add the readed character
        cmp byte [.inputlen], SHELL_BUFFER_SIZE
        jge .loop                           ; Check the input buffer is not full

        mov ah, WHITE_ON_BLUE              ; Print style
        call screen_printchar

        xor bx, bx                          ; Clear bx
        mov bl, [.inputlen]
        add bx, .input
        mov [bx], al                        ; Store character on input buffer

        inc byte [.inputlen]                ; inputlen++
        jmp .loop

    .backspace:
        mov al, [.inputlen]                 ; Get input length
        test al, al                         ; Check that it really exists input
        je .loop

        call screen_backspace
        dec byte [.inputlen]                ; inputlen--
        jmp .loop

    .enter:
        cmp byte [.inputlen], 0x4           ; Check cmd lenght is 4
        mov byte [.inputlen], 0x0           ; Clear input buffer
        jne .unknown

        mov eax, dword [.input]             ; Load first 4 characters of input buffer

        cmp eax, dword [cmd_clsr]           ; Check input against clsr cmd
        je .call_clsr

        cmp eax, dword [cmd_rset]           ; Check input against rset cmd
        je .call_rset

        cmp eax, dword [cmd_time]           ; Check input against time cmd
        je .call_time

    .unknown:
        ; Print unkown cmd message
        mov ah, PINK_ON_BLUE               ; Text style
        mov ebx, unkonw_cmd_msg             ; Pointer to string
        call screen_print
        call print_prompt
        jmp .loop

    .call_clsr:
        call clsr
        jmp .loop

    .call_rset:
        call rset
        jmp .loop

    .call_time:
        call time
        call print_prompt
        jmp .loop

    .input      times SHELL_BUFFER_SIZE db 0   ; Buffer for shell input
    .inputlen   db 0                           ; Shell input size


; *******************************************************************************
; *                               CLEAR SCREEN                                  *
; *******************************************************************************


; Clear screen
; Destroyed: ah, al, ebx
clsr:
    ; Clear screen
    mov ah, WHITE_ON_BLUE                  ; Slear style
    call screen_clear

    call print_prompt
    ret


; *******************************************************************************
; *                                   RESET                                     *
; *******************************************************************************


; Reboot. 8042 reset
rset:
    cli
    mov al, 0xFE                            ; Reset CPU command
    out 0x64, al
    hlt


; *******************************************************************************
; *                                   TIME                                      *
; *******************************************************************************


; Get time (HH:MM:SS) using Real Time Clock
; Destroyed: ah, al, ebx
time:
    call rtc_seconds                        ; Get RTC seconds
    call to_ascci                           ; Tranform seconds to ascci
    mov [time_msg.seconds], word ax         ; Store the value

    call rtc_minutes                        ; Get RTC minutes
    call to_ascci                           ; Tranform minutes to ascci
    mov [time_msg.minutes], word ax         ; Store the value

    call rtc_hours                          ; Get RTC hours
    call to_ascci                           ; Tranform hours to ascci
    mov [time_msg.hours], word ax           ; Store the value

    mov ah, WHITE_ON_BLUE                   ; Print style
    mov ebx, time_msg                       ; Print message

    mov ah, YELLOW_ON_BLUE
    call screen_print                       ; Print time message
    ret

; Transform from BCD to ascci
; @param  al
; @return al = ascci units
; @return ah = ascci tens
to_ascci:
    mov ah, al
    and ah, 0x0F

    and al, 0xF0
    shr al, 4

    add al, 0x30                            ; Transform to ascci
    add ah, 0x30                            ; Transform to ascci
    ret


; *******************************************************************************
; *                                 DATA                                        *
; *******************************************************************************


; Time message
time_msg:
    db ENDL
    .hours:     db 0, 0, ':'                ; ascci hours
    .minutes:   db 0, 0, ':'                ; ascci minutes
    .seconds:   db 0, 0                     ; ascci seconds
    db ENDL, 0

; For convenience all commands have only four characters
cmd_clsr     db 'clsr'                              ; Command clear string
cmd_time     db 'time'                              ; Command time string
cmd_rset     db 'rset'                              ; Command reboot string

unkonw_cmd_msg  db ENDL, 'Unkown command.', ENDL, 0 ; Unkown cmd error message
prompt          db 'shell:$ ', 0                    ; Shell prompt

welcome_msg:
    db '           ***********************************************************', ENDL
    db '           *                                                         *', ENDL
    db '           *                    Welcome to ZZ Shell                  *', ENDL
    db '           *                                                         *', ENDL
    db '           *    clsr: Clear screen                                   *', ENDL
    db '           *    rset: Reboot                                         *', ENDL
    db '           *    time: Real time clock                                *', ENDL
    db '           *                                                         *', ENDL
    db '           ***********************************************************', ENDL, ENDL, 0