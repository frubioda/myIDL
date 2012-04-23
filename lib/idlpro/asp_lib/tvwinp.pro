pro tvwinp, array, free=free, tv=tv, title=title, $
	xr=xr, yr=yr
;+
;
;	function:  tvwinp
;
;	purpose:  do "tvwin" with profiles to center of screen
;
;	author:  rob@ncar, 2/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  tvwinp, array"
	print
	print, "	Do 'tvwin' with profiles to center of screen."
	print
	print, "	Arguments"
	print, "		array	 - input array to plot"
	print
	print, "	Keywords"
	print, "		free	 - if set, open new window"
	print, "			    (def=use window of index 0)"
	print, "		tv	 - if set, use tv to plot"
	print, "			    (def=use tvscl)"
	print, "		title	 - window title"
	print, "			    (def=use IDL default)"
	print, "		xr	 - factor to rebin X with (def=1=none)"
	print, "		yr	 - factor to rebin Y with (def=1=none)"
	print
	return
endif
;-
;
;	Check number of dimensions.
;
if sizeof(array, 0) ne 2 then begin
	print
	print, 'Must be a 2-D array.'
	print
	return
endif
;
;	Set general parameters.
;
true = 1
false = 0
do_rebin = false
;
;	Get dimensions of array.
;
nx = sizeof(array, 1)
ny = sizeof(array, 2)
;
;	Handle resizing of array.
;
if n_elements(xr) ne 0 then begin
	do_rebin = true
	nx = nx * xr
endif
if n_elements(yr) ne 0 then begin
	do_rebin = true
	ny = ny * yr
endif
if do_rebin  then arr = rebin(array, nx, ny, sample=1)    else arr = array
;
;	Set image and profile window positions.
;
x_size = 1152		; not correct in !d.x_size
y_size = 900		; not correct in !d.y_size
x_sizep = .75 * 640	; see profilep.pro (wsize = 0.75)
y_sizep = .75 * 512	; see profilep.pro
xborder = 0.5 * (x_size - nx - x_sizep)
xposp = xborder
yposp = 0.5 * (y_size - y_sizep)
xpos = xborder + x_sizep + 10
ypos = 0.5 * (y_size - ny)
;
;	Open window.
;
if n_elements(title) eq 0 then begin
	window, xpos=xpos, ypos=ypos, xsize=nx, ysize=ny, free=free
endif else begin
	window, xsize=nx, xpos=xpos, ypos=ypos, ysize=ny, free=free, $
		title=title
endelse
window_ix = !d.window
;
;	Plot.
;
if keyword_set(tv)  then tv, arr    else tvscl, arr
;
;	Profile.
;
profilep, arr, xpos=xposp, ypos=yposp
;
;	Remove image window.
;
wdelete, window_ix
end
