PRO PSS ,xsz,ysz,a4=a4,landscape=quer,color=color,encapsulated=enc
;+
; NAME:
;	PSS
; PURPOSE:
;       saves actual plot-device name,
;	sets plot-device to 'PS' (PostScript; optionally encapsulated) 
;	(b/w or color depending on !D.N_COLORS).
;*CATEGORY:            @CAT-# 25@
;	Plotting
; CALLING SEQUENCE:
;       PSS ,/A4 [,/LANDSCAPE] [,/COLOR] [,/ENCAPSULATED] or:
;	PSS [,xsz ,ysz] [,/LANDSCAPE] [,/COLOR] [,/ENCAPSULATED]
; INPUTS:
;	none
;OPTIONAL INPUTS:
;	  xsz, ysz : overall size of plot in x and y direction [cm];
;	             ignored, if keyword /A4 set.
;                    default: xsz=17.78 , ysz=12.7 (7" x 5").
;         /A4      : set xsz=18, ysz=27 ; ignore any xsz,ysz.
;         /LANDSCAPE: if set, x-direction is parallel to the longer
;	             paper size. Default : "portrait" mode.
;         /COLOR   : if set, plot device is set to color-PostScript;
;		     default: b/w-PostScript.
;         /ENCAPSULATED : if set, an "encapsulated" PostScript-file
;	             will be created, suitable for importing into another
;		     document (e.g., TeX, LaTeX);
;		     default: non-encapsulated PostScript.
; OUTPUTS:
;	none
; COMMON BLOCKS:
;	common ODEVCOM,old_device,old_backgrnd,old_color,old_chsz,pscolor,psenc
;	       string containing the old devive-name,
;	       background- & foreground color, character-size-factor of active
;	       device when entering PSS;
;	       pscolor: set =1 if case /color, else set =0;
;	       psenc: set=1 if case /encapsulated, else set =0.
;              
; SIDE EFFECTS:
;	plot-output generated by subsequent plot commands will be 
;       written into file idl.ps until device is
;       reset by calling procedure PSP.
; RESTRICTIONS:
;	
; PROCEDURE:
;	straight
; MODIFICATION HISTORY:
;	nlte, ?
;       nlte, 1991-08-13 : save !p.background, !p.color 
;       hoba,nlte 1992-08-31 : optional input parameters xsz,ysz,/LANDSCAPE,/A4
;	nlte, 1992-09-23 : keyword COLOR, variable character size
;	nlte, 1993-06-18 : keyword ENCAPSULATED
;-
on_error,1
common odevcom,old_device,old_backgrnd,old_color,old_chsz,pscolor,psenc
old_device=!d.name & old_chsz=!p.charsize
old_backgrnd=!p.background & old_color=!p.color 
if n_params() eq 1 or n_params() gt 2 then message,$
   'Usage: PSS [{ ,/A4 | ,xsz,ysz }] [,/LANDSCAPE] [,/COLOR] [,/ENCAPSULATED]'
;
psenc=keyword_set(enc)
;
if keyword_set(a4) then begin 
   if keyword_set(quer) then begin 
      ydef=18. & xdef=27.    ; DIN A4
      xoff=1.0 & yoff=27.7
   endif else begin
      xdef=18. & ydef=27.    ; DIN A4
      xoff=2.0 & yoff=1.0
   endelse
endif else begin
   if keyword_set(quer) then begin
      xdef=24.13 & ydef=17.78  ; IDL default 9.5 x 7 inch  
      xoff=1.905 & yoff=26.035
   endif else begin
      xdef=17.78 & ydef=12.7  ; IDL default 7 x 5 inch
      xoff=1.905 & yoff=12.7
   endelse
endelse
;
if n_params() lt 1 or keyword_set(a4) then begin 
   y=ydef & x=xdef 
endif else begin
   y=ysz & x=xsz
   if keyword_set(quer) then begin
      xoff=1. & yoff=27.7
   endif else begin
      xoff=2. & yoff=1.
   endelse   
endelse
;
f=1.
if (x lt 16.) or (y lt 12.) then f=0.25*fix(0.5+min([x/17.78,y/12.7])/0.25)>0.5 $
else if (x gt 18.) or (y gt 13.) then f=0.25*fix(0.5+max([x/17.78,y/12.7])/0.25)<1.5
!p.charsize=f
;
pscolor=keyword_set(color)
if pscolor then begin
   n_old_colors=!d.n_colors
   if n_old_colors gt 2 then tvlct,red,green,blue,/get ; get actual color table
   set_plot,'PS',/copy,/interpolate
   device,/color,bits_per_pixel=8
   n_new_colors=!d.n_colors
  if n_old_colors gt 2 then begin
    if n_old_colors lt n_new_colors then begin
      red=[red,replicate(255b,n_new_colors-n_old_colors)]
      green=[green,replicate(255b,n_new_colors-n_old_colors)]
      blue=[blue,replicate(255b,n_new_colors-n_old_colors)]
    endif
    tvlct,red,green,blue  ; use actual color table
  endif else $
    printf,-2,"PSS: ATTENTION: don't forget to load a color table !!"
endif else set_plot,'PS'
;
if psenc then device,/encapsulated
;
if keyword_set(quer) then $
  device,xsize=x,ysize=y,xoffset=xoff,yoffset=yoff,/landscape $
else $ 
  device,xsize=x,ysize=y,xoffset=xoff,yoffset=yoff,/portrait
;
mess='PSS: set_plot,''PS'''
if psenc or pscolor then mess=mess+'('
if psenc then mess=mess+'encapsulated '
if pscolor then mess=mess+'color'
if psenc or pscolor then mess=mess+')'
printf,-2,mess
end
