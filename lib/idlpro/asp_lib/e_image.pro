pro e_image_usage
;+
;
;	function:  e_image
;
;	purpose:  return sky plane stretched array of an a_* file dumped by
;		  program 'bite' expansions of *.bi with the -x option
;
;	routines:  e_image_usage  e_image_str  e_image
;
;	author:  paul@ncar, 7/94	(minor mod's by rob@ncar)
;
;==============================================================================
;
if 1 then begin
	print
	print, "usage:	image = e_image( a_file )"
	print
	print, "	Return sky plane stretched 2D array of an a_* file"
	print, "	dumped by program 'bite' expansions of *.bi with"
	print, "	-x option."
	print
	print, "	Arguments"
	print, "		a_file	- string variable with file path"
	print, "			  (the directory must hold several"
	print, "			  other a_* files for the function"
	print, "			  to work; a_file is assumed to"
	print, "			  be imageable)"
	print, "	Keywords"
	print, "		bkg	- background value (def=0.)"
	print, "		pix_deg	- great circle pixels per degree"
	print, "			  (use about 45 for no magnification;"
	print, "			  > 70 may not map properly; def=50.)"
	print, "		e_str,	- variables to contain output"
	print, "		 b_str	  structures of data and directories"
	print, "			  (defs=structures not output)"
	print, "		reuse	- reuse e_str if it exists,"
	print, "			  do not recompute e_str"
	print, "			  Directory must remain the same."
	print, "			  pix_deg is ignored."
	print
	print, "   ex:"
	print, "	a_path  = '/hilo/d/asp/data/red/92.06.19/op19/a_1incl'"
	print, "	e_1incl = e_image( a_path, bkg=90., pix_deg=60., $"
	print, "			   e_str=e, b_str=b )"
	return
endif
;-
end
;------------------------------------------------------------------------------
;
;	pocedure:  e_image_str
;
;	purpose:  compute structure for sky plane stretched images
;
;------------------------------------------------------------------------------
pro e_image_str, e, b, pix_deg, a_file

				    ;Set default pixels per degree.
if  n_elements( pix_deg ) eq 0  then  pix_deg=50.

				    ;Compute b structure.
b_data = b_image( a_file, b_str=b )
				    ;Solar circumference in arcseconds.
ccc = 2.*!pi*b.head(102)
				    ;Pixels per arcsecond.
pix_asec = pix_deg*(360./ccc)
				    ;Read arcsecond coordinates.
uuuu = read_floats( b.dty+'a__rgtasn' )
vvvv = read_floats( b.dty+'a__dclntn' )
			
				    ;Form u v distances in arcseconds
				    ;from minimum.
umin = min( uuuu, max=mx )
uuuu = uuuu-umin
umax = mx-umin
vmin = min( vvvv, max=mx)
vvvv = vvvv-vmin
vmax = mx-vmin
				    ;Form ramp through xy space dimensions.
xxyy = lindgen( b.xdim, b.ydim )
				    ;Get xy values corresponding to where
				    ;array.  Offset by one so all values
				    ;are are positive.
xxyy = xxyy( b.pxy )+1
				    ;Transform (u,v) space to array element
				    ;offsets.  Add four pixel boundary.
if  n_elements( pix_deg ) eq 0  then  pix_deg=50.
uuuu = pix_asec*uuuu+4.5
vvvv = pix_asec*vvvv+4.5
udim = long(pix_asec*umax+9.5)
vdim = long(pix_asec*vmax+9.5)
				    ;Form (u,v) space array to hold offsets in
				    ;(x,y) space.
xy_in_uv = lonarr(udim,vdim)
				    ;Move xy values into (u,v) space with
				    ;1/2 pixel offset then overwrite with
				    ;closest pixel.
xy_in_uv(udim*long(vvvv+.5)+long(uuuu+.5)) = xxyy
xy_in_uv(udim*long(vvvv   )+long(uuuu   )) = xxyy

				    ;Stretch the xy pointers up to four
				    ;pixels in uv space.
uoff = [ -1, 0, 1, 0,-1, 0, 1, 0,-1, 0, 1, 0,-1, 0, 1, 0 ]
voff = [  0,-1, 0, 1, 0,-1, 0, 1, 0,-1, 0, 1, 0,-1, 0, 1 ]
for ioff=0,15 do begin
	ii = uoff(ioff)
	jj = voff(ioff)
	u0 = 0 > ii  &  u1 = (udim-1+ii) < (udim-1)
	v0 = 0 > jj  &  v1 = (vdim-1+jj) < (vdim-1)
	xy_in_uv(u0:u1,v0:v1) = xy_in_uv(u0:u1,v0:v1) $
	+ xy_in_uv(u0-ii:u1-ii,v0-jj:v1-jj)*( xy_in_uv(u0:u1,v0:v1) eq 0 )
end
				    ;Remove four pixel boundary.
for ii=0,udim-1 do begin
	whr = where( xy_in_uv(ii,*) ne 0, nwhr )
	if nwhr ne 0 then begin
		if nwhr le 8 then begin
			xy_in_uv(ii,whr) = -1
		end else begin
			xy_in_uv(ii,whr(0:3)) = -1
			xy_in_uv(ii,whr(nwhr-4:nwhr-1)) = -1
		end
	end
end
for jj=0,vdim-1 do begin
	whr = where( xy_in_uv(*,jj) ne 0, nwhr )
	if nwhr ne 0 then begin
		if nwhr le 8 then begin
			xy_in_uv(whr,jj) = -1
		end else begin
			xy_in_uv(whr(0:3),jj) = -1
			xy_in_uv(whr(nwhr-4:nwhr-1),jj) = -1
		end
	end
end
				    ;Remove the added one; xy can be zero.
				    ;Reduce dimensions by 7 pixels.
xy_in_uv = xy_in_uv(4:udim-5,4:vdim-5)-1
udim = udim-8
vdim = vdim-8
				    ;Offsets where there may be data
				    ;in (u,v) space.
uv_off = where( xy_in_uv ge 0 )
				    ;Offsets used to move expanded
				    ;a__vectors to (u,v) space.
puv  = long( where( xy_in_uv ge 0 ) )
pbkg = long( where( xy_in_uv lt 0 ) )

				    ;Place offsets into a__vectors on
				    ;an (x,y) grid.
pxy_in_xy = replicate(-1L,b.xdim,b.ydim)
pxy_in_xy(b.pxy) = lindgen(b.npxy)

				    ;Find offsets used to expand a__vectors
				    ;to be moved to (u,v) space.
vec_puv = pxy_in_xy( xy_in_uv(puv) )

				    ;(x,y) offsets in (x,y) space of solved
				    ;raster points.
xy_in_xy = lindgen(b.xdim,b.ydim)
if  sizeof(b.sbkg,0) ne 0  then  xy_in_xy(b.sbkg) = -1L

				    ;Set solved xy locations in (u,v) space.
xy_in_uv(puv) = xy_in_xy(xy_in_uv(puv))

				    ;Offsets used to move expanded a_vectors
				    ;to (u,v) space.
suv  = long( where( xy_in_uv ge 0 ) )
sbkg = long( where( xy_in_uv lt 0 ) )

				    ;Place offsets into a_vectors on an
				    ;(x,y) grid.
sxy_in_xy = replicate(-1L,b.xdim,b.ydim)
sxy_in_xy(b.sxy) = lindgen(b.nsxy)

				    ;Find offsets used to expand a_vectors
				    ;to be moved to (u,v) space.
vec_suv = sxy_in_xy( xy_in_uv(suv) )

				    ;Set e structure.
e =					$
{ index		: 4L			$
, stretch	: 1L			$
, npoints	: b.npoints		$
, nsolved	: b.nsolved		$
, npxy		: long(n_elements(puv))	$
, nsxy		: long(n_elements(suv))	$
, x0		: b.x0			$
, y0		: b.y0			$
, xpnt		: b.xpnt		$
, ypnt		: b.ypnt		$
, cct_min	: b.cct_min		$
, cct_max	: b.cct_max		$
, mxfld		: b.mxfld		$
, head		: b.head		$
, xdim		: long(udim)		$
, ydim		: long(vdim)		$
, pxy		: puv			$
, sxy		: suv			$
, vec_pxy	: vec_puv		$
, vec_sxy	: vec_suv		$
, pbkg		: pbkg			$
, sbkg		: sbkg			$
, pix_deg       : float(pix_deg)	$
, mm_per_deg	: b.mm_per_deg		$
, dty		: b.dty			$
}

end
;------------------------------------------------------------------------------
;
;	function:  e_image
;
;	purpose:  return sky plane stretched array of an a_* file
;		  dumped by program 'bite' expansions of *.bi with
;		  the -x option
;
;------------------------------------------------------------------------------
function e_image, a_file $
, bkg=bkg, pix_deg=pix_deg $
, e_str=e, b_str=b, reuse=reuse
		    ;
		    ;Check number of parameters.
		    ;
if n_params() eq 0 then begin
	e_image_usage
	return, 0
end
		    ;
		    ;Test if structure is reusable.
		    ;
if  n_elements(reuse) eq 0  then  reuse = 0
if  n_elements(e    ) eq 0  then  reuse = 0
if  reuse eq 0  then  e_image_str, e, b, pix_deg, a_file
		    ;
		    ;Return 2D image.
		    ;
return, s_image( a_file, e, bkg=bkg )
		    ;
end