PRO HPS,xsz,ysz,a4=a4,landscape=quer
;+
; NAME:
;	HPS
; PURPOSE:
;       saves actual plot-device name,
;	sets plot-device to 'HP'.
;*CATEGORY:            @CAT-# 25@
;	Plotting
; CALLING SEQUENCE:
;	HPS ,/A4 [,/LANDSCAPE]   or:
;	HPS [,xsz ,ysz] [,/LANDSCAPE]
; INPUTS:
;	none
; OPTIONAL INPUTS:
;	xsz ,ysz : overall size of plot in x and y direction [cm];
;	           ignored, if keyword /A4 is set.
;		   Default: xsz=17.78, ysz=12.7 (7" x 5") if portrait mode,
;		            xsz=24.13, ysz=17.78 (9.5" x 7") if landscape mode.
;      /A4       : set xsz=18, ysz=27 (portrait) or xsz=27, ysz=18 (landscape).
;      /LANDSCAPE : if set, x-direction is parallel to the longer paper size.
;		    Default: "portrait"-mode.
; OUTPUTS: 
;	none
; COMMON BLOCKS:
;	ODEVCOM,old_device,old_backgrnd,old_color,old_chsz,pscolor
;	       To save device-name, fore- & background color.
;              old_device: string containing the old devive-name
;	                   !d.name as set on entry.
;	       old_backgrnd: !p.background as set on entry.
;	       old_color:  !p.color as set on entry.
;	       old_chsz: !p.charsize as set on entry.
;	       pscolor: (unused here).
; SIDE EFFECTS:
;	plot-output generated by subsequent plot commands will be 
;       written into file idl.hp (HP-GL format) until device is
;       reset by calling procedure HPP.
; RESTRICTIONS:
;	
; PROCEDURE:
;	straight
; MODIFICATION HISTORY:
;	nlte, (KIS) 1990-03-17
;       nlte, 1991-08-13 : saving of !p.background, !p.color
;       nlte, 1992-09-23 : optional parameters xsz,ysz,/A4,/LANDSCAPE;
;                          ODEVCOM extended.
;       nlte, 1993-04-08 : special case GOOFY: no action.
;-
on_error,1
common odevcom,old_device,old_backgrnd,old_color,old_chsz,pscolor
;
if strlowcase(getenv('HOST')) eq 'goofy' then message,$
   'no HP-device available at this site! No action.'
;
old_device=!d.name
old_backgrnd=!p.background
old_color=!p.color
old_chsz=!p.charsize
;
if n_params() eq 1 or n_params() gt 2 then message,$
   'Usage: HPS [{ ,/A4 | ,xsz,ysz}] [,/LANDSCAPE]'
if keyword_set(a4) then begin
   if keyword_set(quer) then begin
      ydef=18. & xdef=27.   ; DIN A4
      xoff=1.0 & yoff=1.0
   endif else begin
      xdef=18. & ydef=27.   ; DIN A4
      xoff=2. & yoff=1.
   endelse
endif else begin
   if keyword_set(quer) then begin
      xdef=24.13 & ydef=17.78   ; IDL default 9.5 x 7 inch
      xoff=0.635 & yoff=1.27
   endif else begin
      xdef=17.78 & ydef=12.7   ; IDL default 7 x 5 inch
      xoff=0.3175 & yoff=11.42
   endelse
endelse
;
if n_params() lt 1 or keyword_set(a4) then begin
   y=ydef & x=xdef
endif else begin
   y=ysz & x=xsz
   if keyword_set(quer) then begin
      xoff=1. & yoff=1.
   endif else begin
      xoff=2. & yoff=1.
   endelse
endelse
f=1.
if (x lt 16.) or (y lt 12.) then $
   f=0.25*fix(0.5+min([x/17.78,y/12.7])/0.25)>0.5 else $
if (x gt 18.) or (y gt 13.) then $
   f=0.25*fix(0.5+max([x/17.78,y/12.7])/0.25)<1.5
!p.charsize=f
;
set_plot,'HP'
if keyword_set(quer) then $
   device,xsize=x,ysize=y,xoffset=xoff,yoffset=yoff,/landscape else $
   device,xsize=x,ysize=y,xoffset=xoff,yoffset=yoff,/portrait
printf,-2,'HPS: set_plot,''HP'' done.'
;
end
