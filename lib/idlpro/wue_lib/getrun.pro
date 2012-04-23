;+
; NAME:
;       GETRUN
; PURPOSE:
;       Return the n'th run of consecutive integers from a given array.'
; CATEGORY:
; CALLING SEQUENCE:
;       w2 = getrun(w, n, [m])
; INPUTS:
;       w = output from where to process.          in 
;       n = run number to get (first = 0 = def).   in 
;       m = optional last run number to get.       in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         LOCATION = l.  Return run n start location. 
;         /LAST means n is offset from last run.  So n=0 gives 
;           last run, n=-1 gives next to last, ... 
;           If n=-2 and m=0 then last 3 runs are returned. 
;         /LONGEST returns the longest run. n is returned, and m is ignored. 
; OUTPUTS:
;       w2 = returned run or runs.                 out 
; COMMON BLOCKS:
; NOTES:
;       Note: Getrun is meant to be used on the output from where. 
;             if m > n then w2 will be a string of runs from run n to 
;             run m.  If no m is given then w2 will be a single run. 
;             If n<0 then returns runs starting at run abs(n) to end of w. 
;             If n is out of range then a -1 is returned. 
;	      See also nruns.
; MODIFICATION HISTORY:
;       R. Sterner, 18 Mar, 1990
;-
 
	FUNCTION GETrun, w, NTH, MTH, help=hlp, location=ll,$
	   last=last, longest=longest
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print," Return the n'th run of consecutive integers from a given array.'
	  print,' w2 = getrun(w, n, [m])'
	  print,'   w = output from where to process.          in'
	  print,'   n = run number to get (first = 0 = def).   in'
	  print,'   m = optional last run number to get.       in'
	  print,'   w2 = returned run or runs.                 out'
	  print,' Keywords:'
	  print,'   LOCATION = l.  Return run n start location.'
	  print,'   /LAST means n is offset from last run.  So n=0 gives'
	  print,'     last run, n=-1 gives next to last, ...'
	  print,'     If n=-2 and m=0 then last 3 runs are returned.'
	  print,'   /LONGEST returns the longest run. n is returned, and m is ignored.'
	  print,'Note: Getrun is meant to be used on the output from where.'
	  print,'      if m > n then w2 will be a string of runs from run n to'
	  print,'      run m.  If no m is given then w2 will be a single run.'
	  print,'      If n<0 then returns runs starting at run abs(n) to end of w.'
	  print,'      If n is out of range then a -1 is returned.'
	  print,'      See also nruns.'
	  return, -1
	endif
 
	if n_elements(nth) eq 0 then nth = 0		; Default is first run.
	IF n_elements(mth) eq 0 THEN MTH = NTH		; Default is one run.
 
	d = w-SHIFT(w,1)				; Compute distance to next point.
	loc = WHERE(d ne 1)				; Find distance ne 1 = run starts.
	loc2 = [loc,n_elements(w)]			; Tack on where next run would start.
	len = (loc2 - shift(loc2,1))(1:*)		; Compute run lengths.
	nwds = n_elements(loc)				; Number of runs.
 
	if keyword_set(longest) then begin		; Find longest run.
	  nth = (where(len eq max(len)))(0)		; Index of longest run.
	  ll = loc(nth)					; Location of longest run.
	  return, w(ll:ll+len(nth)-1)			; Return longest run.
	endif
 
	if keyword_set(last) then begin			; Offset from last run.
	  lst = nwds - 1
	  in = lst + nth				; Nth run.
	  im = lst + mth				; Mth run.
	  if (in lt 0) and (im lt 0) then return, -1	; Out of range.
	  in = in > 0					; Force smaller of in and im
	  im = im > 0					;  to zero.
	  if (in gt lst) and (im gt lst) then return,-1 ; Out of range.
	  in = in < lst					; Force larger of in and im
	  im = im < lst					;  to be last.
	  ll = loc(in)
	  return, w(ll:loc(im)+len(im)-1)		; Return runs from # n to # m.
	endif
 
	N = ABS(NTH)					; Allow nth<0.
	IF N GT NWDS-1 THEN RETURN,-1			; Word number out of range, return -1.
	ll = loc(n)					; Location of n'th run.
	IF NTH LT 0 THEN GOTO, NEG			; handle nth<0.
	IF MTH GT NWDS-1 THEN MTH = NWDS-1		; Return all runs up to end of w.
 
	return, w(ll:loc(mth)+len(mth)-1)		; Return runs from # n to # m.
 
NEG:	RETURN, w(ll:*)					; Return from n'th run to end of w.
 
	END
