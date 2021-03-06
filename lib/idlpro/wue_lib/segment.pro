;+
; NAME:
;       SEGMENT
; PURPOSE:
;       Set boundaries of constant value to 0.
; CATEGORY:
; CALLING SEQUENCE:
;       b = segment(a)
; INPUTS:
;       a = input image.     in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       b = output image.    out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 20 May, 1986.
;       RES 22 Oct, 1989 --- converted to SUN.
;-
 
	FUNCTION SEGMENT, A, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Set boundaries of constant value to 0.'
	  print,' b = segment(a)'
	  print,'   a = input image.     in'
	  print,'   b = output image.    out'
	  return, -1
	endif
 
	B = A
 
	S = SHIFT(A, 0,1)
	W = WHERE(S GT A)
	B(W) = 0
	S = SHIFT(A, 0,-1)
	W = WHERE(S GT A)
	B(W) = 0
	S = SHIFT(A, 1,0)
	W = WHERE(S GT A)
	B(W) = 0
	S = SHIFT(A, -1,0)
	W = WHERE(S GT A)
	B(W) = 0
	S = SHIFT(A, 1,1)
	W = WHERE(S GT A)
	B(W) = 0
	S = SHIFT(A, -1,-1)
	W = WHERE(S GT A)
	B(W) = 0
	S = SHIFT(A, 1,-1)
	W = WHERE(S GT A)
	B(W) = 0
	S = SHIFT(A, -1,1)
	W = WHERE(S GT A)
	B(W) = 0
 
	RETURN, B
 
	END
