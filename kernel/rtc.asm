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
; *                             REAL TIME CLOCK                                 *
; *******************************************************************************


CMOS_SEL_PORT   equ 0x70                    ; "select" a CMOS register
CMOS_RD_PORT    equ 0x71                    ; CMOS read port
CMOS_WR_PORT    equ 0x71                    ; CMOS write port

CMOS_RTC_SECONDS_REG    equ 0x00            ; RTC seconds register
CMOS_RTC_MINUTES_REG    equ 0x02            ; RTC minutes register
CMOS_RTC_HOURS_REG      equ 0x04            ; RTC hours register

[BITS 32]

; Get RTC seconds through CMOS
; @return al = seconds
rtc_seconds:
    mov al, CMOS_RTC_SECONDS_REG
    out CMOS_SEL_PORT, al                   ; Select read register
    in al, CMOS_RD_PORT                     ; Read CMOS register
    ret

; Get RTC minutes through CMOS
; @return al = minutes
rtc_minutes:
    mov al, CMOS_RTC_MINUTES_REG
    out CMOS_SEL_PORT, al                   ; Select read register
    in al, CMOS_RD_PORT                     ; Read CMOS register
    ret

; Get RTC hours through CMOS
; @return al = hours
rtc_hours:
    mov al, CMOS_RTC_HOURS_REG
    out CMOS_SEL_PORT, al                   ; Select read register
    in al, CMOS_RD_PORT                     ; Read CMOS register
    ret