;+
; NAME:
;       JD2YMD
; PURPOSE:
;       Find year, month, day from julian day number.
; CATEGORY:
; CALLING SEQUENCE:
;       jd2ymd, jd, y, m, d
; INPUTS:
;       jd = Julian day number (like 2447000).     in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       y = year (like 1987).                      out 
;       m = month number (like 7).                 out 
;       d = day of month (like 23).                out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  21 Aug, 1986.
;       Johns Hopkins Applied Physics Lab.
;       RES 18 Sep, 1989 --- converted to SUN
;-
 
	PRO JD2YMD, JD, Y, M, D, help=hlp
 
	IF (N_PARAMS(0) LT 4) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Find year, month, day from julian day number.'
	  PRINT,' jd2ymd, jd, y, m, d'
	  PRINT,'   jd = Julian day number (like 2447000).     in'
	  PRINT,'   y = year (like 1987).                      out'
	  PRINT,'   m = month number (like 7).                 out'
	  PRINT,'   d = day of month (like 23).                out'
	  RETURN
	ENDIF
 
	Y = FIX((JD - 1721029)/365.25)		; Estimated year.
	JD0 = YMD2JD(Y, 1, 0)			; JD for day 0.
	DAYS = JD - JD0				; Day of year.
	IF DAYS LE 0 THEN BEGIN			; Check if ok.
	  Y = Y - 1				; No. Year was off by 1.
	  JD0 = YMD2JD( Y, 1, 0)		; New JD for day 0.
	  DAYS = JD - JD0			; New day of year.
	ENDIF
 
	; Days before start of each month.
	YDAYS = [0,0,31,59,90,120,151,181,212,243,273,304,334,366]
 
	; Correct YDAYS for leap-year.
	IF (((Y MOD 4) EQ 0) AND ((Y MOD 100) NE 0)) $
            OR ((Y MOD 400) EQ 0) THEN YDAYS(3) = YDAYS(3:*) + 1
 
	; Find which month.
	FOR M = 1, 12 DO IF DAYS LE YDAYS(M+1) THEN GOTO, DONE
	PRINT,'Internal error in JD2YMD.'
	STOP
 
DONE:	D = FIX(DAYS - YDAYS(M))		; Day of month.
 
	RETURN
	END
