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
; *                             ZIDANE VIDEO PLAYER                             *
; *******************************************************************************


SECTORS_PER_FRAME   equ 125             ; Size of a frame on sectors

VIDEO_GR_MEMORY     equ 0xA000          ; Address of VGA mode 13h

videoplayer:
    mov bx, VIDEO_GR_MEMORY
    mov es, bx                          ; Extra segment pointing to VIDEO_GR_MEMORY

.to_graphics_mode:
    mov ax, 13h                         ; 320x200x256 colors
    int 10h                             ; Call BIOS

.loop:
    hlt                                 ; Wait next interrupt
    mov ax, [.next_frame]               ; Load next fram sector
.lba_to_chs:
    push ax
    xor cx, cx                          ; Clean cx and dx
    xor dx, dx
    div word [.sectors_per_track]
    inc dx                              ; Starts at zero
    mov cl, dl                          ; Sectors
    xor dx, dx
    div word [.number_of_heads]
    mov dh, dl                          ; Head
    mov ch, al                          ; Track
    xor dl, dl                          ; Drive, normally zero
    pop ax

.load_frame:
    add ax, SECTORS_PER_FRAME           ; Advance pointer
    mov [.next_frame], ax

    mov ah, 0x2	                        ; Function 0x2, read sectors into memory
    mov al, SECTORS_PER_FRAME           ; 125 sectors, 64000 bytes
    mov bx, 0x0
    int 0x13	                        ; Call BIOS

    dec byte [.num_frames]
    jne .loop

.to_text_mode:
    mov ax, 3h                          ; 25x80 Text mode
    int 10h                             ; Call BIOS

    ret                                 ; Return

    .num_frames         db 39           ; Video number of frames
    .next_frame         dw 6            ; Next frame pointer
    .sectors_per_track  dw 36           ; There are 36 sectors per track
    .number_of_heads    dw 2