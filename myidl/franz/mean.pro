FUNCTION MEAN,ARRAY
;+
; NAME:
;	MEAN
; PURPOSE:
;	Compute mean of ARRAY.
;-
ON_ERROR,2

	RETURN,TOTAL(array)/N_ELEMENTS(array)
END