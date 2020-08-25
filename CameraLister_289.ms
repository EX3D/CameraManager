-- macroScript ARQRenderz_CameraLister
-- category:"ARQ Renderz"
-- buttonText:"Camera Lister"
-- toolTip: "Camera Lister"
-- Icon:#("ArqRenderZ",7)

/* VERSIONING


v0.289
Se invirtio la funcion de sun elevation para coincidir con el x rotation.
El sol de esta version no es compatible con v288 y anteriores



END OF VERSIONING*/

(--[ Begin Script ]--!!
	
local CamMan_InternalVersion = 289
local version = 0.29
local betaversion = " 	Beta 9"
	
--[ Versioning ]--!!

	fn updateversion = (
		fileIn ("Z:\MaxScript\Projects\ArqRenderZ CameraLister\CameraLister v" + CameraListerVer as string + ".ms")
		dontopendialog = true
		messageBox ("Installed ArqRenderZ Camera Lister v" + CameraListerVer as string )
	)
	
	fn noversion = (
		persistent global CameraListerVer = version
		dontopendialog = false
		messageBox ("ArqRenderZ Camera Lister was updated to v" + CameraListerVer as string )
	)
	
	fn cancelversion = (
		dontopendialog = true
	)
	
if CameraListerVer == undefined then (
	messageBox ("Welcome to ArqRenderZ Camera Lister v" + version as string )
	dontopendialog = false
	persistent global CameraListerVer = version
)
	
if CameraListerVer != undefined then (
	
	if CameraListerVer == version then (
		dontopendialog = false
	)
	
	if CameraListerVer < version then (
		answer = yesNoCancelBox ("This file was configured using a previous version of ArqRenderZ Camera Lister. " + 
		"You may experience problems! Do you want to roll back to version v" + (CameraListerVer as string) + "?") title:"Warning!" beep:on
		case answer of (
			(#yes): updateversion()
			
			(#no): noversion()
			
			(default): cancelversion()
		)
	)
	
	if CameraListerVer > version then (
		answer = yesNoCancelBox ("This file was configured using an updated version of ArqRenderZ Camera Lister. " + 
		"You may experience problems! Do you want to update to version v" + (CameraListerVer as string) + "?") title:"Warning!" beep:on
		case answer of (
			(#yes): updateversion()
			
			(#no): noversion()
			
			(default): cancelversion()
		)
	)
)	
	

	
(--[ List avaliable Render Engines ]--		
rendererlist = RendererClass.classes as array
rendererlist2 =  #()

for obj in rendererlist do (
append rendererlist2 (obj as string)	
)	

/* rendererlist [1] as string */	


)	
fn camlist = (--[ List all Cameras ]--
camlist =  #()
for o in cameras where superclassof o == camera do (

	c1 = o.name
	--print c1
	append camlist c1

)
camlist = sort camlist 
)
camlist()

(--[ List all Layers ]--
s = LayerManager 					
LyrList =  #()
cnt = s.count - 1

for i = 0 to cnt  do (
	x =  s.getlayer i
	s1 = x.name
	append  LyrList  s1 
)	
LyrList = sort LyrList 
)
(--[ Define Active Properties ]--
activeprops = #("camlock","rtime_lock","rarea_lock","rlay_lock","rsize_lock","renv_lock","rsun_lock","rfile_lock","RTime",
	"RStart","RStop","RFrames","RArea","RCropX","RCropY","RCropW","RCropH","RWidth","RHeight","RAspect","RLock","RFile",
	"RExt","RName","Name","jpgio1","jpgio2","pngio1","pngio2","pngio3","exrio1","exrio2","exrio3","exrio4","exrio5",
	"REnv","REnvClass","renv_lock","RBitmap1","RBitmap2","CoronaOutput1","CoronaOutput2","CoronaOutput3","CoronaOutput4",
	"CoronaOutput5","CoronaOutput6","CoronaOutput7r","CoronaOutput7g","CoronaOutput7b","CoronaOutput8","Sun","SunAnim",
	"SunWire","SunOn","SunTarget","SunCoronaSky","SunIntensity","SunSize","SunElevation","SunColor","SunVis1","SunVis2",
	"SunVis3","SunVis4","CoronaRegion")
)

(--[ Begin Dialog CameraManager ]--
try destroyDialog CameraManager catch ()
	
rollout CameraManager ("v" + version as string + betaversion) ( 
	global UI_colwidth = 240
	global UI_yseam = 12
	global UI_xseam = 12	
	global debugging = 0	
	global currentcam = ""	
	global gotocam = false
	global changelayers = true
	global lockson = false
	

	
	timer clock "CheckValues" interval:100

	groupBox list_box "Camera List" width:UI_colwidth height:72
		dropdownlist  cameralist  height:60 tooltip:"Select Camera" items:camlist width:(UI_colwidth-20) height:14 selection:0
		checkbox cam_go "Go to Camera" 
		checkbox cam_lock "Lock Camera Movement" 

		
	groupBox name_box "Camera" width:UI_colwidth height:48	
		edittext cam_name  width:(UI_colwidth-20) height:17 fieldwidth:250 
		
	groupBox renderer_box "Renderer" width:UI_colwidth height:48	
		dropdownlist  rendererlist  height:60 tooltip:"Select Renderer" items:rendererlist2 width:(UI_colwidth-20) height:14 selection:0

	groupBox rtime_box "       Time Output" width:UI_colwidth height:48
		checkbutton rtime_lock ""  width:16 height:16 images:#("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,24,24,1,1)
		dropdownlist rtime_drop "" items:#("Single Frame","Active Time","Custom Range","Specific") width:96 pos:[rtime_box.pos.x+10,rtime_box.pos.y+20]
		label rtime_lbl "Frame 0" 
		edittext rtime_name "" width:80 visible:false
		spinner rstart_spinner "" width:42 height:20 enabled:true range:[0,9999,0] scale:1 type:#integer 
		spinner rstop_spinner "to" width:42 height:20 enabled:true range:[0,9999,0] scale:1 type:#integer 
   
	groupBox rarea_box "       Render Area" width:UI_colwidth height:48
		checkbutton rarea_lock ""  width:16 height:16 images:#("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,24,24,1,1)
		dropdownlist rarea_drop "" items:#("View","Selected","Region","Crop","Blowup") width:80 
		checkbutton rarea_pck "Set Crop Box" width:80 
		checkbutton corona_region_chk "Enable Corona Region" 
		
	groupBox rlay_box "       Layers" width:UI_colwidth height:48
		checkbutton rlay_lock ""  width:16 height:16 images:#("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,24,24,1,1)
		dropdownlist layerlist  height:22 width:172 items:lyrlist 
		button lay1_button ""  width:20 height:20 images:#("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,15,15,1,1)
		button lay2_button ""   width:20 height:20 images:#("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,13,13,1,1)
		checkbutton lay3_chk "on" checked:true

	groupBox rsize_box "       Render Size" width:UI_colwidth height:84
		checkbutton rsize_lock ""  width:16 height:16 images:#("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,24,24,1,1)
		spinner rwidth_spinner "Width:  " width:70 height:20 enabled:true range:[10,32768,10] scale:1 type:#integer 
		spinner rheight_spinner "Height: " width:70 height:20 enabled:true range:[10,32768,10] scale:1 type:#integer 
		button hd0_button "Preview"   width:60 height:16 
		button hd1_button "FullHD"  width:60 height:16 
		button hd2_button "4K UHD"  width:60 height:16 
		button hd3_button "Full Pano"  width:60 height:16 
		spinner ratio_spinner "Aspect: " width:70 height:20 enabled:true range:[0,32768,0] scale:0.0001 type:#float 
		checkbox ratio_chk "Lock Aspect Ratio" 

	groupBox renv_box "       Environment"  width:UI_colwidth height:96
		checkbutton  renv_lock ""  width:16 height:16 images:#("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,24,24,1,1)
		colorpicker renv_col "" color:[11,11,11] modal:false height:17 width:24		
		mapbutton renv_map "..."  width:162 height:17 
		checkbutton  renvuse_lock "Map"  width:30 height:17 
		
	groupBox bitmap_box "Bitmap Settings" width:(UI_colwidth-16) height:60
		edittext coronaoutput1_name "" width:180 readonly:true labelOnTop:true 	
		spinner bitmap1_spinner "Output:" width:80 height:17 range:[0,360,0] scale:0.01 

	groupBox coronaoutput_box "Corona Output Settings" width:(UI_colwidth-16) height:110 visible:false
		spinner coronaoutput2_spinner "Brightness:" width:60 height:16 enabled:true range:[-1,1,0] scale:0.01 visible:false
		spinner coronaoutput3_spinner "Saturation:" width:60 height:16 enabled:true range:[-1,1,0] scale:0.01 visible:false
		spinner coronaoutput4_spinner "Contrast:" width:60 height:16 enabled:true range:[0,99,0] scale:0.01 visible:false
		spinner coronaoutput5_spinner "Gamma:" width:60 height:16 enabled:true range:[0.01,10,0] scale:0.01 visible:false
		spinner coronaoutput6_spinner "Exposure:" width:60 height:16 enabled:true range:[-20,20,0] scale:0.01 visible:false
		colorpicker coronaoutput7_pck "Tint:" color:[0,0,255] modal:false visible:false
		checkbox coronaoutput8_chk "Affected by Corona VFB Tone Mapping" visible:false
		
	groupBox rsun_box "       Corona Sun" width:UI_colwidth height:200
		checkbox sun_on "On" 
		checkbox sun_targeted "Targeted" checked:true enabled:false
		checkbox sun_env "Use CoronaSky" enabled:false

		
		groupBox sun_position_grp "Position" height:40 width:(UI_colwidth-16)
			spinner sun_azimuth "Azimuth" width:68 height:16 enabled:true range:[-360,360,0] scale:0.1
			spinner sun_elevation "Inv. Elevation" width:64 height:16 enabled:true range:[0,90,0] scale:0.1 		
		
		spinner sun_intensity "Intensity"  width:58 height:16 enabled:true range:[-360,999,1] scale:0.01
		spinner sun_size "Size"  width:58 height:16 enabled:true range:[0.4,64,1] scale:0.01
				checkbox sun_wire "Wire" 

		
		groupBox sun_color_grp "Color" height:40 width:(UI_colwidth-16)
			dropdownlist sun_color items:#("Realistic","Direct Input","Kelvin Temp") width:90 enabled:false
		
		groupBox sun_vis_grp "Visibility" height:40	width:(UI_colwidth-16)		
			checkbox sun_vis1 "Direct"
			checkbox sun_vis2 "Reflect"
			checkbox sun_vis3 "Refract"
			checkbox sun_vis4 "Caustics"
		
		
		button sun_properties "Save sun properties"
	
		checkbutton rsun_lock ""  width:16 height:16 images:#("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,24,24,1,1)
		
		checkbox sun_anim "Animate" 

	groupBox rfile_box "       File"  width:UI_colwidth height:116
		checkbutton rfile_lock ""  width:16 height:16 images:#("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,24,24,1,1)
		edittext name_props "View Name:" labelontop:true  width:172 height:17 
		dropdownlist RExt_drop "Extension:" labelontop:true items:#(".jpg",".png",".exr","Custom") offset: [0,0] width:52 height:17 

	groupBox jpgio_box "File I/O (.jpg)" width:(UI_colwidth-16) height:48
		spinner jpgio1_spinner "Quality"  width:70 height:20 enabled:true range:[0,100,100] scale:1 type:#integer 
		spinner jpgio2_spinner "Smoothing" width:70 height:20 enabled:true range:[0,100,0] scale:1 type:#integer 

	groupBox pngio_box "File I/O (.png)" width:(UI_colwidth-16) height:70 visible:false
		dropdownlist pngio1_drop "Colors" labelontop:true items:#("Optimized (256)","RGB 24bit","RGB 48bit","Grayscale 8bit","Grayscale 16bit") width:100 visible:false
		checkbox pngio2_chk "Alpha" visible:false
		checkbox pngio3_chk "Interlaced" visible:false
	
	groupBox exrio_box "File I/O (.exr)" width:(UI_colwidth-16) height:220 visible:false
		dropdownlist exrio1_drop "Format" labelontop:true items:#("Full Float (32bit)","Half Float (16bit)","Integer (32bit)") width:120 visible:false
		dropdownlist exrio2_drop "Type" labelontop:true items:#("RGBA","RGB","Mono") width:76 visible:false
		dropdownlist exrio3_drop "Compression" items:#("No compression","Run Lenght Encoding (RLE)",
		"Zip Compression per Scanline (ZIPS)","Zip Compression per Scanline Band (ZIP)","Piz-based Wavelet Compression (PIZ)",
		"Lossy 24bits Float Compression (PXR24)","Lossy 4x4 Pixel Block Compression (fixed rate)(B44)","Lossy 4x4 Pixel Block Compression (B44A)") width:210 visible:false
		dropdownlist exrio4_drop "Storage Type" items:#("Store Image as Scanlines","Store Image as Tiles") width:210 visible:false
		dropdownlist exrio5_drop "Image Region" items:#("Save Full Image","Save Region") width:210 visible:false
		label exrio6_lbl "? Open EXR Layers && Elements disabled" style_sunkenedge:true height:16 visible:false width:210

	groupBox customio_box "Custom Extension (Use .dot format)" width:(UI_colwidth-16) height:48 visible:false
		edittext customext_props visible:false labelOnTop:false width:60

	groupBox rrend_box "Network Rendering" width:UI_colwidth height:48
		button render_button "Network Render" align:#left width:120 
		
	groupBox corona_box "Corona Connectivity" pos:[(UI_colwidth+UI_yseam/2),6] width:UI_colwidth height:780
		checkbox corona_chk "Use Global Settings for this Camera" pos:[corona_box.pos.x+UI_yseam/2,corona_box.pos.y+24] enabled:false checked:true
		
	groupBox corona_gnrl_box "General Settings" pos:[corona_box.pos.x+UI_yseam/2,corona_box.pos.y+48] width:(UI_colwidth-UI_yseam) height:72
		spinner corona_pass_spinner "Pass Limit" pos:[corona_gnrl_box.pos.x+48,corona_gnrl_box.pos.y+24] width:60 height:20  range:[0,9999,0] scale:1 type:#integer 
		spinner corona_noise_spinner "Noise Limit" pos:[corona_gnrl_box.pos.x+160,corona_pass_spinner.pos.y] width:60 height:20  range:[0,100,5] scale:0.1 type:#float 
		spinner corona_timeh_spinner "Time Limit     h" pos:[corona_gnrl_box.pos.x+70,corona_pass_spinner.pos.y+24] width:40 height:20 range:[0,24,0] scale:1 type:#integer 
		spinner corona_timem_spinner "m" pos:[corona_gnrl_box.pos.x+124,corona_pass_spinner.pos.y+24] width:40 height:20  range:[0,60,0] scale:1 type:#integer 
		spinner corona_times_spinner "s" pos:[corona_gnrl_box.pos.x+180,corona_pass_spinner.pos.y+24] width:40 height:20  range:[0,60,0] scale:1 type:#integer 
	
	groupBox corona_over_box "Render Overrides" pos:[corona_box.pos.x+UI_yseam/2,((corona_gnrl_box.height)+(corona_gnrl_box.pos.y))] width:(UI_colwidth-UI_yseam) height:72
		checkbox corona_hlights_chk "Render hidden lights" pos:[corona_over_box.pos.x+UI_yseam/2,corona_over_box.pos.y+24] enabled:false
		checkbox corona_masks_chk "Only masks" pos:[corona_over_box.pos.x+UI_yseam/2+130,corona_over_box.pos.y+24] enabled:false
		checkbox corona_mtrl_chk "Mtl. Override" pos:[corona_hlights_chk.pos.x,corona_hlights_chk.pos.y+24] enabled:false
		button corona_mtrl_button "None" height:17 pos:[corona_mtrl_chk.pos.x+90,corona_mtrl_chk.pos.y] width:120 enabled:false
		
	groupBox corona_dnoise_box "Denoising" pos:[corona_box.pos.x+UI_yseam/2,((corona_over_box.height)+(corona_gnrl_box.height)+(corona_gnrl_box.pos.y))] width:(UI_colwidth-UI_yseam) height:72
		dropdownlist corona_dnoise_drop "Denoise Mode" pos:[corona_dnoise_box.pos.x+8,corona_dnoise_box.pos.y+24] items:#("Only Fireflies","Full Denoising") width:120 enabled:false selection:2
		spinner corona_namount_spinner "Amount" pos:[corona_dnoise_box.pos.x+164,corona_dnoise_box.pos.y+20] width:50 height:20  range:[0,1,0.5] scale:0.01 type:#float enabled:false
		spinner corona_nradius_spinner "Radius" pos:[corona_dnoise_box.pos.x+164,corona_dnoise_box.pos.y+44] width:50 height:20  range:[0,1,0.25] scale:0.01 type:#float enabled:false
		
	groupBox corona_env_box "Scene Environment" pos:[corona_box.pos.x+UI_yseam/2,((corona_dnoise_box.height)+(corona_over_box.height)+(corona_gnrl_box.height)+(corona_gnrl_box.pos.y))] width:(UI_colwidth-UI_yseam) height:72		
		checkbox corona_menv_chk "Use 3ds Max Settings" pos:[corona_env_box.pos.x+UI_yseam,corona_env_box.pos.y+24] enabled:false
		checkbox corona_cenv_chk "Use Corona" pos:[corona_env_box.pos.x+UI_yseam/2+136,corona_env_box.pos.y+24] enabled:false
		colorpicker corona_envc_pck "" pos:[corona_env_box.pos.x+8,corona_env_box.pos.y+48]  color:[255,255,255] modal:false height:17 enabled:false   
		button corona_env_button "None" height:17 pos:[corona_env_box.pos.x+54,corona_envc_pck.pos.y] width:140 enabled:false
		checkbox corona_env_chk "" pos:[corona_env_box.pos.x+UI_yseam/2+194,corona_env_button.pos.y+2] enabled:false
		
	groupBox corona_cam_box "Camera" pos:[corona_box.pos.x+UI_yseam/2,((corona_dnoise_box.height)+(corona_over_box.height)+(corona_gnrl_box.height)+(corona_gnrl_box.pos.y)+(corona_env_box.height))] width:(UI_colwidth-UI_yseam) height:182
		
	groupBox corona_dof_box "Depth of Field" pos:[corona_cam_box.pos.x+UI_yseam/2,corona_cam_box.pos.y+20] width:(UI_colwidth-UI_yseam*2) height:96
		checkbox corona_dof_chk "Enable" pos:[corona_dof_box.pos.x+8,corona_dof_box.pos.y+24] enabled:false
		spinner corona_dof_spinner "Sensor Width [mm]:" pos:[corona_dof_chk.pos.x+138,corona_dof_chk.pos.y] width:60 height:20  range:[0,999,36] scale:0.1 type:#float enabled:false
		dropdownlist corona_dof_drop "Shape:" pos:[corona_dof_chk.pos.x,corona_dof_chk.pos.y+22] items:#("Circular","Bladed","Custom") width:80 enabled:false selection:2 
		spinner corona_dofb_spinner "Blades:" pos:[corona_dof_chk.pos.x+138,corona_dof_chk.pos.y+24] width:60 height:20  range:[0,128,6] scale:1 type:#integer enabled:false
		spinner corona_dofr_spinner "Rotation:" pos:[corona_dof_chk.pos.x+138,corona_dof_chk.pos.y+44] width:60 height:20  range:[0,9999,0] scale:0.01 type:#float enabled:false
	
	groupBox corona_blur_box "Motion Blur" pos:[corona_cam_box.pos.x+UI_yseam/2,corona_cam_box.pos.y+20+(corona_dof_box.height)] width:(UI_colwidth-UI_yseam*2) height:60
		checkbox corona_blur_camera "Camera" pos:[corona_blur_box.pos.x+8,corona_blur_box.pos.y+20] enabled:false
 
	groupBox corona_perf_box "Performance Settings" pos:[corona_cam_box.pos.x,((corona_dnoise_box.height)+(corona_over_box.height)+(corona_gnrl_box.height)+(corona_gnrl_box.pos.y)+(corona_env_box.height)+(corona_cam_box.height))] width:(UI_colwidth-UI_yseam) height:100	
	
	groupBox corona_gi_box "Global Ilumination" pos:[corona_perf_box.pos.x+UI_yseam/2,corona_perf_box.pos.y+20] width:(UI_colwidth-UI_yseam*2) height:96
	
	groupBox corona_uhd_box "UHD Cache" pos:[corona_cam_box.pos.x,((corona_dnoise_box.height)+(corona_over_box.height)+(corona_gnrl_box.height)+(corona_gnrl_box.pos.y)+(corona_env_box.height)+(corona_cam_box.height)+(corona_perf_box.height))] width:(UI_colwidth-UI_yseam) height:60
 
	groupBox corona_proxy_box "Proxy Manager" pos:[corona_cam_box.pos.x,((corona_dnoise_box.height)+(corona_over_box.height)+(corona_gnrl_box.height)+(corona_gnrl_box.pos.y)+(corona_env_box.height)+(corona_cam_box.height)+(corona_perf_box.height)+(corona_uhd_box.height))] width:(UI_colwidth-UI_yseam) height:100
		button corona_prox1_btn "Unload hidden Proxys" pos:[corona_proxy_box.pos.x+UI_yseam/2,corona_proxy_box.pos.y+24] 
		button corona_prox2_btn "Load unhidden Proxys" pos:[corona_proxy_box.pos.x+UI_yseam/2,corona_proxy_box.pos.y+48] 

	groupBox debug_box "Debugger" pos:[(UI_colwidth*2+UI_yseam),6] width:UI_colwidth height:200
		dropdownlist cam_props_drop "Active Properties" width:(UI_colwidth-20) pos:[debug_box.pos.x+10,debug_box.pos.y+20] items:activeprops width:120 enabled:true selection:0 height:600
		edittext cam_props height:17 width:(UI_colwidth-20) pos:[debug_box.pos.x+10,debug_box.pos.y+70] editable:true 
		edittext debugger "Message:" height:17 width:(UI_colwidth-20) labelOnTop:true readOnly:true pos:[debug_box.pos.x+10,debug_box.pos.y+120]
		button del_props "Clear Properties"  width:100 pos:[debug_box.pos.x+10,debug_box.pos.y+160]
		button show_props "Print Properties" width:100 pos:[debug_box.pos.x+120,debug_box.pos.y+160]
		
	groupBox script_box "Custom Scripts" pos:[(UI_colwidth*2+UI_yseam),debug_box.height+6] width:UI_colwidth height:200
		edittext script_in "Script In" height:120 width:(UI_colwidth-20) pos:[script_box.pos.x+10,script_box.pos.y+20] editable:true --fieldWidth:20
		
	groupBox note_box "Notes" pos:[(UI_colwidth*2+UI_yseam),(debug_box.height + script_box.height) + 6] width:UI_colwidth height:200
		edittext notes_in "" height:120 width:(UI_colwidth-20) pos:[note_box.pos.x+6,note_box.pos.y+20] editable:true 
		
	groupBox util_box "Utilities" pos:[(UI_colwidth*2+UI_yseam),(debug_box.height + script_box.height + note_box.height) + 6] width:UI_colwidth height:130
		button getenv "GetEnvironment" width:100 pos:[util_box.pos.x+108,util_box.pos.y+24]
		checkbutton ColorMgr "Color Manager" width:100 pos:[util_box.pos.x+6,util_box.pos.y+24]
		button tocoronacam "Duplicate to Corona Camera" width:140 pos:[util_box.pos.x+80,util_box.pos.y+50]
		button tocoronacam2 "Transfer Animation to Camera" width:140 pos:[util_box.pos.x+80,util_box.pos.y+80]
		button tocoronacam3 "Transfer Animation to Target" width:140 pos:[util_box.pos.x+80,util_box.pos.y+110]
		
	
	groupBox credit_box "Credits" width:UI_colwidth height:80
		hyperlink test"Created by ArqrenderZ @2018" color:[248,114,50] hoverColor:[248,114,50] visitedColor:[128, 128, 128] 
		address:"http://www.arqrenderz.com"  
		button debug_button "Debugger Mode"
		button debug_button2 "Close Debugger" visible:false
		button update_button "Update"

	--[ UI  LAYOUT FUNCTIONS ]--
	fn list_layout = (
		list_box.pos = [0,6]
		cameralist.pos = [list_box.pos.x+10,list_box.pos.y+20]
		cam_go.pos = [list_box.pos.x+10,list_box.pos.y+48]
		cam_lock.pos = [list_box.pos.x+100,list_box.pos.y+48]
	)
	fn cam_layout = (
		name_box.pos = [0,list_box.height+(UI_yseam/2)]
		cam_name.pos = [name_box.pos.x+10,name_box.pos.y+20]
	)
	fn renderer_layout = (
		renderer_box.pos = [0,list_box.height+(name_box.height)+(UI_yseam/2)]
		rendererlist.pos = [renderer_box.pos.x+10,renderer_box.pos.y+20]
	)
	fn rtime_layout = (
		rtime_box.pos = [0,(list_box.height)+(name_box.height)+(renderer_box.height)+(UI_yseam/2)]
		rtime_lock.pos = [rtime_box.pos.x+10,rtime_box.pos.y]
		rtime_drop.pos = [rtime_box.pos.x+10,rtime_box.pos.y+20]
		rtime_lbl.pos = [rtime_drop.pos.x+100,rtime_drop.pos.y+5]
		rtime_name.pos = [rtime_drop.pos.x+140,rtime_drop.pos.y]
		rstart_spinner.pos = [rtime_drop.pos.x+126,rtime_drop.pos.y+2] 
		rstop_spinner.pos = [rtime_drop.pos.x+180,rtime_drop.pos.y+2]
	)
	fn rarea_layout = (
		rarea_box.pos = [0,(list_box.height)+(name_box.height)+(renderer_box.height)+(rtime_box.height)+(UI_yseam/2)]
		rarea_lock.pos = [rarea_box.pos.x+10,rarea_box.pos.y] 
		rarea_drop.pos = [rarea_box.pos.x+10,rarea_box.pos.y+20]
		rarea_pck.pos = [rarea_drop.pos.x+84,rarea_drop.pos.y] 
		corona_region_chk.pos = [rarea_drop.pos.x+84,rarea_drop.pos.y] 
	)
	fn rlay_layout = (
		rlay_box.pos = [0,(list_box.height)+(name_box.height)+(renderer_box.height)+(rtime_box.height)+(rarea_box.height)+(UI_yseam/2)]
		rlay_lock.pos = [rlay_box.pos.x+10,rlay_box.pos.y] 
		layerlist.pos = [rlay_box.pos.x+10,rlay_box.pos.y+20] 
		lay1_button.pos = [LayerList.pos.x+175,LayerList.pos.y]
		lay2_button.pos = [LayerList.pos.x+175,LayerList.pos.y] 
		lay3_chk.pos = [LayerList.pos.x+195,LayerList.pos.y] 
	)
	fn rsize_layout = (
		rsize_box.pos = [0,(list_box.height)+(name_box.height)+(renderer_box.height)+(rtime_box.height)+(rarea_box.height)+(rlay_box.height)+(UI_yseam/2)]
		rsize_lock.pos = [rsize_box.pos.x+10,rsize_box.pos.y] 
		rwidth_spinner.pos = [rsize_box.pos.x+90,rsize_box.pos.y+20] 
		rheight_spinner.pos = [rsize_box.pos.x+90,rsize_box.pos.y+40] 
		hd0_button.pos = [rsize_box.pos.x+110,rsize_box.pos.y+20] 
		hd1_button.pos = [rsize_box.pos.x+170,rsize_box.pos.y+20] 
		hd2_button.pos = [rsize_box.pos.x+110,rsize_box.pos.y+40] 
		hd3_button.pos = [rsize_box.pos.x+170,rsize_box.pos.y+40] 
		ratio_spinner.pos = [rsize_box.pos.x+90,rsize_box.pos.y+60] 
		ratio_chk.pos = [rsize_box.pos.x+128,rsize_box.pos.y+60] 
	)
	fn renv_layout = (
		renv_box.pos = [0,(list_box.height)+(name_box.height)+(renderer_box.height)+(rtime_box.height)+(rarea_box.height)+(rsize_box.height)+(rlay_box.height)+(UI_yseam/2)]
		renv_lock.pos = [renv_box.pos.x+10,renv_box.pos.y] 
		renv_col.pos = [renv_box.pos.x+10,renv_box.pos.y+18] 	
		renv_map.pos = [renv_box.pos.x+34,renv_box.pos.y+18]
		renvuse_lock.pos = [renv_box.pos.x+200,renv_box.pos.y+18] 
	)
	fn bitmap_layout = (
		bitmap_box.pos = [renv_box.pos.x+8,renv_box.pos.y+40]
		coronaoutput1_name.pos = [bitmap_box.pos.x+8,bitmap_box.pos.y+18]
		bitmap1_spinner.pos = [bitmap_box.pos.x+140,bitmap_box.pos.y+36]
	)
	fn coronaoutput_layout = (
		coronaoutput_box.pos = [renv_box.pos.x+8,bitmap_box.pos.y+bitmap_box.height+4]
		coronaoutput2_spinner.pos = [coronaoutput_box.pos.x+90,coronaoutput_box.pos.y+24]
		coronaoutput3_spinner.pos = [coronaoutput_box.pos.x+204,coronaoutput_box.pos.y+24]
		coronaoutput4_spinner.pos = [coronaoutput_box.pos.x+90,coronaoutput_box.pos.y+44]
		coronaoutput5_spinner.pos = [coronaoutput_box.pos.x+204,coronaoutput_box.pos.y+44]
		coronaoutput6_spinner.pos = [coronaoutput_box.pos.x+90,coronaoutput_box.pos.y+64]
		coronaoutput7_pck.pos = [coronaoutput_box.pos.x+176,coronaoutput_box.pos.y+64] 
		coronaoutput8_chk.pos = [coronaoutput_box.pos.x+8,coronaoutput_box.pos.y+84] 
	)
	fn rsun_layout = (
		rsun_box.pos = [0,(list_box.height)+(name_box.height)+(renderer_box.height)+(rtime_box.height)+(rarea_box.height)+(rsize_box.height)+(renv_box.height)+(rlay_box.height)+(UI_yseam/2)]
		rsun_lock.pos = [rsun_box.pos.x+10,rsun_box.pos.y]
		
		sun_on.pos = [rsun_box.pos.x+8,rsun_box.pos.y+20]
		sun_targeted.pos = [rsun_box.pos.x+48,rsun_box.pos.y+20]
		sun_env.pos = [rsun_box.pos.x+116,rsun_box.pos.y+20]
		sun_intensity.pos = [rsun_box.pos.x+80,rsun_box.pos.y+40]
		sun_size.pos = [rsun_box.pos.x+154,rsun_box.pos.y+40]
		sun_wire.pos = [rsun_box.pos.x+180,rsun_box.pos.y+40]
		
		sun_position_grp.pos = [rsun_box.pos.x+8,rsun_box.pos.y+60]
		sun_azimuth.pos = [sun_position_grp.pos.x+80,sun_position_grp.pos.y+20]
		sun_elevation.pos = [sun_position_grp.pos.x+188,sun_position_grp.pos.y+20]
		
		sun_color_grp.pos = [rsun_box.pos.x+8,rsun_box.pos.y+100]
		sun_color.pos = [sun_color_grp.pos.x+8,sun_color_grp.pos.y+16]
		
		sun_vis_grp.pos = [rsun_box.pos.x+8,rsun_box.pos.y+140]
		sun_vis1.pos = [sun_vis_grp.pos.x+4,sun_vis_grp.pos.y+20]
		sun_vis2.pos = [sun_vis_grp.pos.x+50,sun_vis_grp.pos.y+20]
		sun_vis3.pos = [sun_vis_grp.pos.x+104,sun_vis_grp.pos.y+20]
		sun_vis4.pos = [sun_vis_grp.pos.x+160,sun_vis_grp.pos.y+20]
		
		sun_anim.pos = [rsun_box.pos.x+20,rsun_box.pos.y+180]
	)
	fn rfile_layout = (
		rfile_box.pos = [ 0,(list_box.height)+(name_box.height)+(renderer_box.height)+(rtime_box.height)+(rarea_box.height)+(rsize_box.height)+(renv_box.height)+(rsun_box.height)+(rlay_box.height)+(UI_yseam/2)]
		rfile_lock.pos = [rfile_box.pos.x+10,rfile_box.pos.y]
		name_props.pos = [rfile_box.pos.x+8,rfile_box.pos.y+36]
		RExt_drop.pos = [name_props.pos.x +(name_props.width),name_props.pos.y-2]
	)
	fn jpgio_layout = (
		jpgio_box.pos = [rfile_box.pos.x+8,rfile_box.pos.y+60]
		jpgio1_spinner.pos = [jpgio_box.pos.x+84,jpgio_box.pos.y+20]
		jpgio2_spinner.pos = [jpgio_box.pos.x+200,jpgio_box.pos.y+20]
	)
	fn pngio_layout = (
		pngio_box.pos = [rfile_box.pos.x+8,rfile_box.pos.y+60] 
		pngio1_drop.pos = [pngio_box.pos.x+8,pngio_box.pos.y+36] 
		pngio2_chk.pos = [(pngio1_drop.pos.x+120),(pngio1_drop.pos.y-20)] 
		pngio3_chk.pos = [(pngio1_drop.pos.x+120),(pngio1_drop.pos.y+2)]
	)
	fn exrio_layout = (	
		exrio_box.pos = [rfile_box.pos.x+8,rfile_box.pos.y+60]
		exrio1_drop.pos = [exrio_box.pos.x+8,exrio_box.pos.y+40] 
		exrio2_drop.pos = [exrio_box.pos.x+140,exrio_box.pos.y+40] 
		exrio3_drop.pos = [exrio_box.pos.x+8,exrio_box.pos.y+84] 
		exrio4_drop.pos = [exrio_box.pos.x+8,exrio_box.pos.y+124]
		exrio5_drop.pos = [exrio_box.pos.x+8,exrio_box.pos.y+164]
		exrio6_lbl.pos = [exrio_box.pos.x+8,exrio_box.pos.y+190]
	)
	fn customio_layout = (
		customio_box.pos = [rfile_box.pos.x+8,rfile_box.pos.y+60]
		customext_props.pos = [customio_box.pos.x+8,customio_box.pos.y+24]
	)
	fn rrend_layout = (
		rrend_box.pos = [0,(list_box.height)+(name_box.height)+(renderer_box.height)+(rtime_box.height)+(rarea_box.height)+(rsize_box.height)+(renv_box.height)+(rsun_box.height)+(rfile_box.height)+(rlay_box.height)+(UI_yseam/2)]
		render_button.pos = [rrend_box.pos.x+10,rrend_box.pos.y+20]
	)
	fn credits_layout = (
		credit_box.pos = [0,(list_box.height)+(name_box.height)+(renderer_box.height)+(rtime_box.height)+(rarea_box.height)+(rsize_box.height)+(renv_box.height)+(rsun_box.height)+(rfile_box.height)+(rrend_box.height)+(rlay_box.height)+(UI_yseam/2)]
		test.pos = [credit_box.pos.x+10,credit_box.pos.y+20]  
		debug_button.pos = [credit_box.pos.x+10,credit_box.pos.y+40] 
		debug_button2.pos = [credit_box.pos.x+10,credit_box.pos.y+40] 
		update_button.pos = [credit_box.pos.x+120,credit_box.pos.y+40]
	)
	fn managerheight = (
	CameraManager.height = ((list_box.height)+(name_box.height)+(renderer_box.height)+(rtime_box.height)+(rarea_box.height)+(rsize_box.height)+(renv_box.height)+
	(rsun_box.height)+(rfile_box.height)+(rrend_box.height)+(rlay_box.height)+(credit_box.height)+(UI_yseam/2))
	)
	--[ UI  OFF FUNCTIONS ]--
	fn rlist_off = (
			cam_lock.enabled = false
	)
	fn rcam_off = (
		cam_name.enabled = false
	)
	fn rtime_off = (
		rtime_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,23,23,1,1)
		rtime_lock.state = off
		rtime_drop.enabled = false
		rtime_lbl.enabled = false
		rtime_name.enabled = false
		rtime_name.visible = false
		rstart_spinner.visible = false
		rstop_spinner.visible = false
	)
	fn rarea_off = (
		rarea_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,23,23,1,1)
		rarea_lock.state = off
		rarea_drop.enabled = false
		rarea_pck.visible = false
		corona_region_chk.enabled = false
	)
	fn rlay_off = (
		rlay_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,23,23,1,1)
		rlay_lock.state = off
		layerlist.enabled = false
		lay1_button.enabled = false
		lay2_button.enabled = false	
	)
	fn rsize_off = (
		rsize_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,23,23,1,1)
		rsize_lock.state = off
		rwidth_spinner.enabled = false
		rheight_spinner.enabled = false
		ratio_spinner.enabled = false
		ratio_chk.enabled = false
		hd0_button.enabled = false
		hd1_button.enabled = false
		hd2_button.enabled = false
		hd3_button.enabled = false
	)
	fn rsun_off = (
-- 		rsun_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,23,23,1,1)
-- 		rsun_lock.state = off
-- 		sun_azimuth.enabled = false
-- 		sun_wire.enabled = false
-- 		sun_anim.enabled = false
	)
	fn renv_off = (
		renv_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,23,23,1,1)
		renv_lock.state = off
		renv_col.enabled = false
		renv_map.enabled = false	
		renvuse_lock.enabled = false	
	)
	fn rbitmap_off = (
		bitmap1_spinner.enabled = false
		coronaoutput1_name.enabled = false 
	)
	fn rbitmap_inv = (
		bitmap_box.visible = false
		coronaoutput1_name.visible = false 
		bitmap1_spinner.visible = false
	)
	fn 	coronaoutput_off = (
		coronaoutput_box.enabled = false 
		coronaoutput2_spinner.enabled = false 
		coronaoutput3_spinner.enabled = false 
		coronaoutput4_spinner.enabled = false 
		coronaoutput5_spinner.enabled = false 
		coronaoutput6_spinner.enabled = false 
		coronaoutput7_pck.enabled = false 
		coronaoutput8_chk.enabled = false 
	)
	fn 	coronaoutput_inv = (
		coronaoutput_box.visible = false 
		coronaoutput2_spinner.visible = false 
		coronaoutput3_spinner.visible = false 
		coronaoutput4_spinner.visible = false 
		coronaoutput5_spinner.visible = false 
		coronaoutput6_spinner.visible = false 
		coronaoutput7_pck.visible = false 
		coronaoutput8_chk.visible = false 
	)
	fn rfile_off = (
		rfile_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,23,23,1,1)
		rfile_lock.state = off
		RExt_drop.enabled = false
		name_props.enabled = false
		jpgio_box.enabled = false
		jpgio1_spinner.enabled = false
		jpgio2_spinner.enabled = false
	)
	fn jpgio_off = (
		jpgio_box.enabled = false 
		jpgio1_spinner.enabled = false 
		jpgio2_spinner.enabled = false 
	)
	fn pngio_off = (
		pngio_box.enabled = false 
		pngio1_drop.enabled = false 
		pngio2_chk.enabled = false  
		pngio3_chk.enabled = false 
	)
	fn exrio_off = (	
		exrio_box.enabled = false 
		exrio1_drop.enabled = false  
		exrio2_drop.enabled = false  
		exrio3_drop.enabled = false 
		exrio4_drop.enabled = false 
		exrio5_drop.enabled = false 
		exrio6_lbl.enabled = false 
	)
	fn rrend_off = (
		render_button.enabled = false
	)
	fn rdeb_off = (
		debug_box.enabled = false
		cam_props_drop.enabled = false
		del_props.enabled = false
		debugger.enabled = false
	)
	--[ UI  ON FUNCTIONS ]--
	fn rlist_on = (
			cam_lock.enabled = true
	)
	fn rcam_on = (
		cam_name.enabled = true
	)
	fn rtime_on = (
		rtime_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,21,21,1,1)
		rtime_lock.state = on
		rtime_drop.enabled = true
		rtime_lbl.enabled = true
		rtime_name.enabled = true
		rstart_spinner.enabled = true 
		rstop_spinner.enabled = true 
	)
	fn rarea_on = (
		rarea_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,21,21,1,1)
		rarea_lock.state = on
		rarea_drop.enabled = true
		rarea_pck.visible = true
		corona_region_chk.enabled = true
	)
	fn rlay_on = (
		rlay_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,21,21,1,1)
		rlay_lock.state = on
		layerlist.enabled = true
		lay1_button.enabled = true
		lay2_button.enabled = true	
	)
	fn rsize_on = (
		rsize_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,21,21,1,1)
		rsize_lock.state = on
		rwidth_spinner.enabled = true
		rheight_spinner.enabled = true
		ratio_spinner.enabled = true
		ratio_chk.enabled = true
		hd0_button.enabled = true
		hd1_button.enabled = true
		hd2_button.enabled = true
		hd3_button.enabled = true
	)
	fn rsun_on = (
-- 		rsun_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,21,21,1,1)
-- 		rsun_lock.state = on
-- 		sun_azimuth.enabled = true
-- 		sun_wire.enabled = true
-- 		sun_anim.enabled = true
	)
	fn renv_on = (
		renv_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,21,21,1,1)
		renv_lock.state = on
		renv_col.enabled = true
		renv_map.enabled = true	
		renvuse_lock.enabled = true	
	)
	fn rbitmap_on = (
		coronaoutput1_name.enabled = true 
		bitmap1_spinner.enabled = true
	)
	fn rbitmap_vis = (
		bitmap_box.visible = true
		coronaoutput1_name.enabled = true 
		bitmap1_spinner.visible = true
	)
	fn 	coronaoutput_on = (
		coronaoutput_box.enabled = true 
		coronaoutput2_spinner.enabled = true 
		coronaoutput3_spinner.enabled = true 
		coronaoutput4_spinner.enabled = true 
		coronaoutput5_spinner.enabled = true 
		coronaoutput6_spinner.enabled = true 
		coronaoutput7_pck.enabled = true 
		coronaoutput8_chk.enabled = true 
	)
	fn 	coronaoutput_vis = (
		coronaoutput_box.visible = true 
		coronaoutput2_spinner.visible = true 
		coronaoutput3_spinner.visible = true 
		coronaoutput4_spinner.visible = true 
		coronaoutput5_spinner.visible = true 
		coronaoutput6_spinner.visible = true 
		coronaoutput7_pck.visible = true
		coronaoutput8_chk.visible = true 	
	)
	fn rfile_on = (
		rfile_lock.images = #("UVWUnwrapView_16i.bmp","UVWUnwrapTypeIn_16a.bmp",28,21,21,1,1)
		rfile_lock.state = on
		RExt_drop.enabled = true
		name_props.enabled = true
		jpgio_box.enabled = true
		jpgio1_spinner.enabled = true
		jpgio2_spinner.enabled = true
	)
	fn jpgio_on = (
		jpgio_box.enabled = true 
		jpgio1_spinner.enabled = true 
		jpgio2_spinner.enabled = true 
	)
	fn pngio_on = (
		pngio_box.enabled = true 
		pngio1_drop.enabled = true 
		pngio2_chk.enabled = true  
		pngio3_chk.enabled = true 
	)
	fn exrio_on = (	
		exrio_box.enabled = true 
		exrio1_drop.enabled = true  
		exrio2_drop.enabled = true  
		exrio3_drop.enabled = true 
		exrio4_drop.enabled = true 
		exrio5_drop.enabled = true 
		exrio6_lbl.enabled = true 
		
		exrio_box.visible = true 
		exrio1_drop.visible = true  
		exrio2_drop.visible = true  
		exrio3_drop.visible = true 
		exrio4_drop.visible = true 
		exrio5_drop.visible = true 
		exrio6_lbl.visible = true 
	)
	fn rrend_on = (
		render_button.enabled = true
	)
	fn rdeb_on = (
		debug_box.enabled = true
		cam_props_drop.enabled = true
		del_props.enabled = true
		debugger.enabled = true
	)
	--[ RENDER ENGINE FUNCTIONS ]--
	fn checkRender nSearch = (
		theRenderer = for obj in RendererClass.classes where \
		  (matchPattern (obj as string) pattern:nSearch) -- check if the name in nSearch variable exist
			collect  obj
			if theRenderer.count ==1
			   then  renderers.current = theRenderer[1]()
	 else  
			 (messageBox "Render engine not installed")
	)	
	
	--[ CORONA RENDERER SUPPORT FUNCTIONS ]--
	
	
	fn getCoronaVer = (
		CamMan_CoronaVer = undefined
		try (
			if coronarenderer.getCoronaVersion() != undefined  do (
				CamMan_CoronaVer = ((coronarenderer.getCoronaVersion())[1] as integer)
			)
			if coronarenderer.getVersionString () != undefined do (
				CamMan_CoronaVer = ((coronarenderer.getVersionString ())[1] as integer)
			)
		)
		catch()
	)
	
	--Sun rotation 
	
	fn setsun =	(
			---deleteKeys$CoronaSun001
		currentsun = $CoronaSun001
		if currentsun == undefined then (--shit code while i solve the sun
				rsun_off ()
		)
		else (
			
		
			sun = #("on","targeted","rotation","position","targetposition","")
			
			
			
			
			if getuserprop currentcam "SunWire" == undefined then (
				setuserprop currentcam "SunWire" 1
			) 
			if getuserprop currentcam "SunWire" ==  1 then (
				sun_wire.checked = true
				if classof environmentmap == Bitmaptexture then (
					paramWire.connect currentsun.rotation.controller[#Z_Rotation] environmentmap.coords[#U_Offset] "radTodeg Z_Rotation / 360.0"
				)
				if classof environmentmap == CoronaOutput then (
					paramWire.connect currentsun.rotation.controller[#Z_Rotation] environmentmap.inputTexmap.coords[#U_Offset] "radTodeg Z_Rotation / 360.0"
				)
				if classof environmentmap == CoronaColorCorrect then (
					paramWire.connect currentsun.rotation.controller[#Z_Rotation] environmentmap.inputTexmap.coords[#U_Offset] "radTodeg Z_Rotation / 360.0"
				)
			)		
			if getuserprop currentcam "SunWire" ==  0 then (
				sun_wire.checked = false
				try(
				if classof environmentmap == Bitmaptexture then (
					paramWire.disconnect environmentmap.coords.U_Offset.controller
					environmentmap.coords.U_Offset = 0
				)
				if classof environmentmap == CoronaOutput then (
					paramWire.disconnect environmentmap.inputTexmap.coords.U_Offset.controller
					environmentmap.inputTexmap.coords.U_Offset = 0
				)
				if classof environmentmap == CoronaColorCorrect then (
					paramWire.disconnect environmentmap.inputTexmap.coords.U_Offset.controller
					environmentmap.inputTexmap.coords.U_Offset = 0
				)
				)catch()
			)
			if getuserprop currentcam "SunOn" == undefined then (
				setuserprop currentcam "SunOn" (getproperty currentsun #on)
			) else (
				sun_on.state = (getuserprop currentcam "SunOn")
			)
			currentsun.on = (getuserprop currentcam "SunOn")
			
			if getuserprop currentcam "SunTarget" == undefined then (
				setuserprop currentcam "SunTarget" false --(getproperty currentsun #targeted)
			) else (
				sun_targeted.state = false --(getuserprop currentcam "SunTarget")
			)
			currentsun.targeted = false--(getuserprop currentcam "SunTarget")
			
			if getuserprop currentcam "SunCoronaSky" == undefined then (
				setuserprop currentcam "SunCoronaSky" false
			) else (
				sun_env.state = (getuserprop currentcam "SunCoronaSky")
			)
			if getuserprop currentcam "SunIntensity" == undefined then (
				setuserprop currentcam "SunIntensity" (getproperty currentsun #intensity)
			) else (
				sun_intensity.value = (getuserprop currentcam "SunIntensity")
			)
			currentsun.intensity = (getuserprop currentcam "SunIntensity")
			
			if getuserprop currentcam "SunSize" == undefined then (
				setuserprop currentcam "SunSize" (getproperty currentsun #size)
			) else (
				sun_size.value = (getuserprop currentcam "SunSize")
			)
			currentsun.size = (getuserprop currentcam "SunSize")
			
			if getuserprop currentcam "Sun" == undefined then (
				setuserprop currentcam "Sun" 0
			) else (
				sun_azimuth.value = (getuserprop currentcam "Sun")
			)
			currentsun.rotation.z_rotation = (getuserprop currentcam "Sun") 
			
			if getuserprop currentcam "SunElevation" == undefined then (
				setuserprop currentcam "SunElevation" 45
			) else (
				sun_elevation.value = (getuserprop currentcam "SunElevation")
			)
			currentsun.rotation.x_rotation = (getuserprop currentcam "SunElevation") 
			
			if getuserprop currentcam "SunColor" == undefined then (
				setuserprop currentcam "SunColor" (currentsun.colorMode)
			) else (
				sun_color.selection = (currentsun.colorMode)
			)
			currentsun.colorMode = (currentsun.colorMode)
			
			if getuserprop currentcam "SunVis1" == undefined then (
				setuserprop currentcam "SunVis1" (getproperty currentsun #visibleDirectly)
			) else (
				sun_vis1.checked = (getuserprop currentcam "SunVis1")
			)
			currentsun.visibleDirectly = (getuserprop currentcam "SunVis1")
			
			if getuserprop currentcam "SunVis2" == undefined then (
				setuserprop currentcam "SunVis2" (getproperty currentsun #visibleRefl)
			) else (
				sun_vis2.checked  = (getuserprop currentcam "SunVis2")
			)
			currentsun.visibleRefl = (getuserprop currentcam "SunVis2")
			
			if getuserprop currentcam "SunVis3" == undefined then (
				setuserprop currentcam "SunVis3" (getproperty currentsun #visibleRefr)
			) else (
				sun_vis3.checked  = (getuserprop currentcam "SunVis3")
			)
			currentsun.visibleRefr = (getuserprop currentcam "SunVis3")
			
			if getuserprop currentcam "SunVis4" == undefined then (
				setuserprop currentcam "SunVis4" (getproperty currentsun #visibleCaustics )
			) else (
				sun_vis4.checked = (getuserprop currentcam "SunVis4")
			)
			currentsun.visibleCaustics = (getuserprop currentcam "SunVis4")
		)--end sun exists
	)--end setsun
	
/*//// ON OPENING //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/	
	--[ RENDER ENGINE FUNCTIONS ]--
	on CameraManager open do (
		
		--currentcam = "lol"
		
		if pos1 == undefined then (
		SetDialogPos CameraManager [400,400]
		)
		
		if pos1 != undefined then (
		SetDialogPos CameraManager pos1
		)
		
		--[ Opening GoTo Cam ]--
		(
		if gotocam == true then (
		cam_go.checked = true
		)
		if gotocam == false then (
		cam_go.checked = false
		)
		)
		--[ Opening UI ]--
		(
		list_layout ()
		cam_layout ()
		renderer_layout()
		rtime_layout ()
		rarea_layout ()
		rlay_layout ()
		rsize_layout ()
		renv_layout ()
		bitmap_layout ()
		coronaoutput_layout ()
		rsun_layout ()
		rfile_layout ()
		jpgio_layout ()
		pngio_layout ()
		exrio_layout ()
		customio_layout ()
		rrend_layout ()
		credits_layout ()
		managerheight ()	
		)
		--[ Opening UI Activation ]--
		(
		clearSelection()
		print "Welcome to ArqRenderZ Camera Manager"
		rlist_off()		
		rtime_off ()
		rarea_off ()
		rlay_off ()
		rsize_off ()
		renv_off ()
		rsun_off()
		rbitmap_off ()
		coronaoutput_off ()
		rfile_off ()
		rdeb_off()
		rrend_off ()
		lockson = false
		)
	)

	on CameraManager close do (
		if classOf environmentmap == Bitmaptexture then (
			--setsunrot()
		)
		if classOf environmentmap == CoronaOutput then (
			--setsunrot()		
		)
		if classOf environmentmap == CoronaColorCorrect then (
			--setsunrot()	
		)
	)

/*//// ON CAMERA SELECTED /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/	
	
	on cameralist selected nameIndex do (			
		rlist_on()
		rcam_on()
		rrend_on ()
		rdeb_on()
				
		select (getnodebyname cameralist.items[nameIndex])
			
		currentcam = $
		cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string
			
		cam_name.text = currentcam.name
		
		if cam_props.text == undefined do (
		cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string	
		)			
		debugger.text = "Selcected Camera Object: " + (currentcam.name as string) 
		
		/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//// GOTOCAM /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/		
			
		if gotocam == true then (	
			if viewport.numViews == 2 then (
			viewport.activeviewport=2 
			)
			if viewport.numViews == 3 then (
			viewport.activeviewport=2 
			)
			if viewport.numViews == 4 then (
			viewport.activeviewport=2 
			)
			if viewport.numViews == 1 then (
			viewport.activeviewport=1 
			)
			macros.run "Lights and Cameras" "Camera_ActivateView"	
			renderSceneDialog.update()	
		)
		
		if getuserprop currentcam "camlock" == undefined then (
			setuserprop currentcam "camlock" false
			cam_lock.checked = false
		)
		
		if getuserprop currentcam "camlock" == true then (
			setTransformLockFlags currentcam #all
			if currentcam.target != undefined then (
				setTransformLockFlags currentcam.target #all			
			)
			cam_lock.checked = true
		)
		
		if getuserprop currentcam "camlock" == false then (
			setTransformLockFlags currentcam #none
			if currentcam.target != undefined then (
				setTransformLockFlags currentcam.target #none			
			)
			cam_lock.checked = false
		)
			
		/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//// LOCKS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/			
		lockson = true
		if getuserprop currentcam "rtime_lock" == undefined then (
			setuserprop currentcam "rtime_lock" 0
			rtime_on ()
		)
		if getuserprop currentcam "rtime_lock" == 0 then (
			rtime_on ()
		)	
		if getuserprop currentcam "rtime_lock" == 1 then (
			rtime_off ()
		)	
		if getuserprop currentcam "rarea_lock" == undefined then (
			setuserprop currentcam "rarea_lock" 0
			rarea_on ()
		)
		if getuserprop currentcam "rarea_lock" == 0 then (
			rarea_on ()
		)	
		if getuserprop currentcam "rarea_lock" == 1 then (
			rarea_off ()
		)
		if getuserprop currentcam "rlay_lock" == undefined then (
			setuserprop currentcam "rlay_lock" 0
			rlay_on ()
		)
		if getuserprop currentcam "rlay_lock" == 0 then (
			rlay_on ()
		)	
		if getuserprop currentcam "rlay_lock" == 1 then (
			rlay_off ()
		)
		if getuserprop currentcam "rsize_lock" == undefined then (
			setuserprop currentcam "rsize_lock" 0
			rsize_on ()
		)
		if getuserprop currentcam "rsize_lock" == 0 then (
			rsize_on ()
		)	
		if getuserprop currentcam "rsize_lock" == 1 then (
			rsize_off ()
		)
		if getuserprop currentcam "renv_lock" == undefined then (
			setuserprop currentcam "renv_lock" 0
			renv_on ()
			rbitmap_on()
			coronaoutput_on()
		)
		if getuserprop currentcam "renv_lock" == 0 then (
			renv_on ()
			rbitmap_on()
			coronaoutput_on()
			rbitmap_on()
			coronaoutput_on()
		)	
		if getuserprop currentcam "renv_lock" == 1 then (
			renv_off ()
			rbitmap_off()
			coronaoutput_off()
			rbitmap_off()
			coronaoutput_off()
		)
		if getuserprop currentcam "rsun_lock" == undefined then (
			rsun_on ()
		)
		if getuserprop currentcam "rsun_lock" == 0 then (
			rsun_on ()
		)	
		if getuserprop currentcam "rsun_lock" == 1 then (
			rsun_off ()
		)
		if getuserprop currentcam "rfile_lock" == undefined then (
			setuserprop currentcam "rfile_lock" 0
			rfile_on ()
			jpgio_on()
			pngio_on()
			exrio_on()
			--customio_on()
		)
		if getuserprop currentcam "rfile_lock" == 0 then (
			rfile_on ()
			jpgio_on()
			pngio_on()
			exrio_on()
			--customio_on()
		)	
		if getuserprop currentcam "rfile_lock" == 1 then (
			rfile_off ()
			jpgio_off()
			pngio_off()
			exrio_off()
			--customio_off()
		)
		/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//// INITIAL USER DEFINED PROPS ////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
		(--[ Time Output ]--
			if (getuserprop currentcam "RTime") == undefined do (
				--setuserprop currentcam "RTime" ""
			)			
			if (getuserprop currentcam "RTime") == "Single Frame" then (
				rtime_drop.selection = 1
				rendTimeType = 1
				rtime_lbl.text = ("Frame " + ((currentTime as integer)/TicksPerFrame)as string)
				rtime_lbl.pos.x = (rtime_drop.pos.x+100)
				rtime_name.visible = false
				rstart_spinner.visible = false
				rstop_spinner.visible = false
			)
			if (getuserprop currentcam "RTime") == "Active Time" then (
				rtime_drop.selection = 2
				rendTimeType = 2
				rtime_lbl.text = ("Frames " + (animationRange.start as string) + " to" + (animationRange.end as string))
				rtime_lbl.pos.x = (rtime_drop.pos.x+100)
				rtime_name.visible = false
				rstart_spinner.visible = false
				rstop_spinner.visible = false
			)			
			if (getuserprop currentcam "RTime") == "Custom Range" then (
				rtime_drop.selection = 3
				rendTimeType = 3
				rtime_lbl.text = "From" 
				rtime_lbl.pos.x = (rtime_drop.pos.x+100)
				rtime_name.visible = false
				rstart_spinner.visible = true
				rstop_spinner.visible = true
			)			
			if (getuserprop currentcam "RTime") == "Specific" then (
				rtime_drop.selection = 4
				rendTimeType = 4
				rtime_lbl.text = "Frames: "
				rtime_lbl.pos.x = (rtime_drop.pos.x+100)
				rtime_name.visible = true
				rstart_spinner.visible = false
				rstop_spinner.visible = false
			)			
			if (getuserprop currentcam "RStart") == undefined do (
				setuserprop currentcam "RStart" 0
			)			
			if (getuserprop currentcam "RStop") == undefined do (
				setuserprop currentcam "RStop" 1
			)			
			if (getuserprop currentcam "RFrames") == undefined do (
				setuserprop currentcam "RFrames" ""
			)
			if rstart_spinner.value != undefined do (
				rstart_spinner.value = (getuserprop currentcam "RStart") 
			)
			if rstop_spinner.value != undefined do (
				rstop_spinner.value = (getuserprop currentcam "RStop") 
			)	
			if rtime_name != undefined do (
				rtime_name.text = ((getuserprop currentcam "RFrames")as string)
			)
			rendStart = getuserprop currentcam "RStart"as time
			rendEnd = getuserprop currentcam "RStop"as time
			rendPickupFrames  = (getuserprop currentcam "RFrames") as string
		)
		(--[ Render Regions ]--
			if (getuserprop currentcam "CoronaRegion") == undefined do (
				setuserprop currentcam "CoronaRegion" false
				corona_region_chk.checked = false
				renderers.current.system_vfbRegions_enabled = false
			)
			if (getuserprop currentcam "CoronaRegion") == true do (
				setuserprop currentcam "CoronaRegion" true
				corona_region_chk.checked = true
				renderers.current.system_vfbRegions_enabled = true
			)
			if (getuserprop currentcam "CoronaRegion") == false do (
				setuserprop currentcam "CoronaRegion" false
				corona_region_chk.checked = false
				renderers.current.system_vfbRegions_enabled = false
			)
				
			--rarea_pck.checked = false
			if EditRenderRegion.IsEditing == true then (
				EditRenderRegion.EditRegion()
				EditRenderRegion.UpdateRegion()
			)
			if (getuserprop currentcam "RArea") == undefined do (
				--------	
				corona_region_chk.visible = true
				if getuserprop currentcam "CoronaRegion" == true then ( 
					renderers.current.system_vfbRegions_enabled = true
					corona_region_chk.checked = true
					)
				if getuserprop currentcam "CoronaRegion" == false then ( 
					renderers.current.system_vfbRegions_enabled = false
					corona_region_chk.checked = false
					)
				--------
				setuserprop currentcam "RArea" "View"
				rarea_pck.visible = false
			)
			if (getuserprop currentcam "RArea") != undefined do (
				if (getuserprop currentcam "RArea") == "View" then (
				--------	
				corona_region_chk.visible = true
				if getuserprop currentcam "CoronaRegion" == true then ( 
					renderers.current.system_vfbRegions_enabled = true
					corona_region_chk.checked = true
					)
				if getuserprop currentcam "CoronaRegion" == false then ( 
					renderers.current.system_vfbRegions_enabled = false
					corona_region_chk.checked = false
					)
				--------	
					
					rarea_drop.selection = 1
					rarea_pck.visible = false
					EditRenderRegion.UpdateRegion()
					setRenderType #view	
				)
				if (getuserprop currentcam "RArea") == "Selected" then (
					rarea_drop.selection = 2
					setRenderType #selected	
					EditRenderRegion.UpdateRegion()
				)
				if (getuserprop currentcam "RArea") == "Region" then (
				corona_region_chk.visible = false
				renderers.current.system_vfbRegions_enabled = false
					rarea_drop.selection = 3
					rarea_pck.visible = true
					rarea_pck.text = "Set Region Box"
					setRenderType #region
					if getuserprop currentcam "RCropX" == undefined then (
						setuserprop currentcam "RCropX" 0 --(viewport.getRegionRect viewport.activeViewport).x
						setuserprop currentcam "RCropY" 0 --(viewport.getRegionRect viewport.activeViewport).y
						setuserprop currentcam "RCropW" 1 --(viewport.getRegionRect viewport.activeViewport).w
						setuserprop currentcam "RCropH" 1 --(viewport.getRegionRect viewport.activeViewport).h
					)
					if getuserprop currentcam "RCropX" != undefined then (
						viewport.setRegionRect viewport.activeViewport (Box2 ((getuserprop currentcam "RCropX")*renderWidth) ((getuserprop currentcam "RCropY")*renderHeight) ((getuserprop currentcam "RCropW")*renderWidth) ((getuserprop currentcam "RCropH")*renderHeight))
						--print "lol"
					)
					EditRenderRegion.UpdateRegion()		
				)
				if (getuserprop currentcam "RArea") == "Crop" then (
								corona_region_chk.visible = false
				renderers.current.system_vfbRegions_enabled = false
					rarea_drop.selection = 4
					rarea_pck.visible = true
					rarea_pck.text = "Set Crop Box"
					setRenderType #crop
					if getuserprop currentcam "RCropX" == undefined then (
						setuserprop currentcam "RCropX" 0 --(viewport.getRegionRect viewport.activeViewport).x
						setuserprop currentcam "RCropY" 0 --(viewport.getRegionRect viewport.activeViewport).y
						setuserprop currentcam "RCropW" 1 --(viewport.getRegionRect viewport.activeViewport).w
						setuserprop currentcam "RCropH" 1 --(viewport.getRegionRect viewport.activeViewport).h
					)
					if getuserprop currentcam "RCropX" != undefined then (
						viewport.setRegionRect viewport.activeViewport (Box2 ((getuserprop currentcam "RCropX")*renderWidth) ((getuserprop currentcam "RCropY")*renderHeight) ((getuserprop currentcam "RCropW")*renderWidth) ((getuserprop currentcam "RCropH")*renderHeight))
					)
					EditRenderRegion.UpdateRegion()	
				)				
				if (getuserprop currentcam "RArea") == "Blowup" then (
					corona_region_chk.visible = false
					renderers.current.system_vfbRegions_enabled = false
					rarea_drop.selection = 5
					rarea_pck.visible = true
					rarea_pck.text = "Set Blowup Box"
					setRenderType #blowup
					if getuserprop currentcam "RBlowX" == undefined then (
						setuserprop currentcam "RBlowX" 0 --(viewport.getBlowupRect viewport.activeViewport).x
						setuserprop currentcam "RBlowY" 0 --(viewport.getBlowupRect viewport.activeViewport).y
						setuserprop currentcam "RBlowW" 1 --(viewport.getBlowupRect viewport.activeViewport).w
						setuserprop currentcam "RBlowH" 1 --(viewport.getBlowupRect viewport.activeViewport).h
					)
					if getuserprop currentcam "RBlowX" != undefined then (
						viewport.setBlowupRect viewport.activeViewport (Box2 ((getuserprop currentcam "RBlowX")*renderWidth) ((getuserprop currentcam "RBlowY")*renderHeight) ((getuserprop currentcam "RBlowW")*renderWidth) ((getuserprop currentcam "RBlowH")*renderHeight))
					)
					EditRenderRegion.UpdateRegion()			
				)
			)
		)
		--[ Render Size & Aspect ]-------------------------------------------------------------
		(
				if (getuserprop currentcam "RWidth") == undefined do (
					setuserprop currentcam "RWidth" renderwidth		
				)
				if (getuserprop currentcam "RHeight") == undefined do (
					setuserprop currentcam "RHeight" renderheight	
				)			
				if (getuserprop currentcam "RLock") == undefined do (
					setuserprop currentcam "RLock" 0
				)			
				if getuserprop currentcam "RLock" ==  1 then (
					ratio_spinner.enabled = false
					ratio_chk.checked = true
				)			
				if getuserprop currentcam "RLock" ==  0 and getuserprop currentcam "rsize_lock" == 0 then (
					ratio_spinner.enabled = true
					ratio_chk.checked = false
				)
				if rwidth_spinner.value != undefined do (
					rwidth_spinner.value = (getuserprop currentcam "RWidth") 		
				)
				if rwidth_spinner.value != undefined do	(
					rheight_spinner.value = (getuserprop currentcam "RHeight") 
				)
				renderWidth = (getuserprop currentcam "RWidth") 
				renderHeight = (getuserprop currentcam "RHeight")
				ratio_spinner.value = getRendImageAspect() 
				setuserprop currentcam "RAspect" (getRendImageAspect() as float)
		)
		--[ Layers]-----------------------------------------------------------------------------------
		(
		sel = LayerList.selected 
		Temp_LM = LayerManager
		lyrName = Temp_LM.getLayerFromName sel
		lyrName.current = true
		
		if layermanager.current.on == false then (
			lay1_button.visible = true	
			lay2_button.visible = false
		)
		if layermanager.current.on == true then (
			lay1_button.visible = false
			lay2_button.visible = true
		)
		
		if changelayers == true then (
			for i in 0 to layerManager.count-1 do (	
				if getuserprop currentcam ("Layer" + i as string) == undefined then (
					setuserprop currentcam ("Layer" + i as string) true
				)
				
				if layermanager.current.on == false then (
					lay1_button.visible = true	
					lay2_button.visible = false
				)
				if layermanager.current.on == true then (
					lay1_button.visible = false
					lay2_button.visible = true
				)
				
				
				if getuserprop currentcam ("Layer" + i as string) == true then (
					lol = layerManager.getLayer i
					lay1_button.visible = true	
					lay2_button.visible = false
					lol.on = true
				)
				if getuserprop currentcam ("Layer" + i as string) == false then (
					lol = layerManager.getLayer i
					lay1_button.visible = false
					lay2_button.visible = true
					lol.on = false
				)
			
			)
		)
		)
		
		--[ File Handling ]--------------------------------------------------------------------------
		(	
				if (getuserprop currentcam "RFile") == undefined do (
					setuserprop currentcam "RFile" "Default"	
				)
				if (getuserprop currentcam "RExt") == undefined do (
					setuserprop currentcam "RExt" ".jpg"
				)
				if (getuserprop currentcam "RName") == undefined do (
					setuserprop currentcam "RName" ""		
				)
				if (getuserprop currentcam "Name") == undefined do (
					setuserprop currentcam "Name" ""		
				)
				if name_props != undefined do (
					name_props.text = (getuserprop currentcam "RName") as string
				)
				if rname_props != undefined do (
					rname_props.text = (getuserprop currentcam "RFile") 
				)
				if (getuserprop currentcam "jpgio1") == undefined do (	
					setuserprop currentcam "jpgio1" 100
					jpgio1_spinner.value = 100
					jpegio.setQuality 100 -- By default is set to the highest quality
				)
				if (getuserprop currentcam "jpgio2") == undefined do (	
					setuserprop currentcam "jpgio2" 0
					jpgio2_spinner.value = 0
					jpegio.setSmoothing 0 -- By default is set to the lowest smoothing level
				)
				if getuserprop currentcam "RExt" == undefined do (
					setuserprop currentcam "RExt" ".jpg"
					RExt_drop.selection = 1
					jpgio_box.visible = true
					jpgio1_spinner.visible = true
					jpgio2_spinner.visible = true
					pngio_box.visible = false
					pngio1_drop.visible = false
					pngio2_chk.visible = false
					pngio3_chk.visible = false
					exrio_box.visible = false
					exrio1_drop.visible = false
					exrio2_drop.visible = false
					exrio3_drop.visible = false
					exrio4_drop.visible = false
					exrio5_drop.visible = false
					exrio6_lbl.visible = false
					customio_box.visible = false
					customext_props.visible = false
					rfile_box.height = 116
					managerheight ()
					rrend_layout()
					credits_layout()
					rendoutputfilename = ((getFilenamePath rendoutputfilename) + (getuserprop currentcam "RName" as string)+(getuserprop currentcam "RExt" as string))
				)
				if getuserprop currentcam "RExt" == ".jpg" do (
					RExt_drop.selection = 1
					jpgio_box.visible = true
					jpgio1_spinner.visible = true
					jpgio2_spinner.visible = true
					pngio_box.visible = false
					pngio1_drop.visible = false
					pngio2_chk.visible = false
					pngio3_chk.visible = false
					exrio_box.visible = false
					exrio1_drop.visible = false
					exrio2_drop.visible = false
					exrio3_drop.visible = false
					exrio4_drop.visible = false
					exrio5_drop.visible = false
					exrio6_lbl.visible = false
					customio_box.visible = false
					customext_props.visible = false
					rfile_box.height = 116
					managerheight ()
					rrend_layout()
					credits_layout()
					
					--Set .jpg I/O controls
					jpgio1_spinner.value = (getUserProp currentcam "jpgio1")
					jpegio.setQuality (getUserProp currentcam "jpgio1")
					jpgio2_spinner.value = (getUserProp currentcam "jpgio2")
					jpegio.setSmoothing (getUserProp currentcam "jpgio2")
					rendoutputfilename = ((getFilenamePath rendoutputfilename) + (getuserprop currentcam "RName" as string)+(getuserprop currentcam "RExt" as string))
				renderSceneDialog.update()	
				)
				if getuserprop currentcam "RExt" == ".png" do (
					RExt_drop.selection = 2
					jpgio_box.visible = false
					jpgio1_spinner.visible = false
					jpgio2_spinner.visible = false
					pngio_box.visible = true
					pngio1_drop.visible = true
					pngio2_chk.visible = true
					pngio3_chk.visible = true
					exrio_box.visible = false
					exrio1_drop.visible = false
					exrio2_drop.visible = false
					exrio3_drop.visible = false
					exrio4_drop.visible = false
					exrio5_drop.visible = false
					exrio6_lbl.visible = false
					customio_box.visible = false
					customext_props.visible = false
					rfile_box.height = 136
					managerheight ()
					rrend_layout()
					credits_layout()
					rendoutputfilename = ((getFilenamePath rendoutputfilename) + (getuserprop currentcam "RName" as string)+(getuserprop currentcam "RExt" as string))
					if getUserProp currentcam "pngio1" == undefined then (
						pngio1_drop.selection = 2
						pngio.setType #true24
					)
					if getUserProp currentcam "pngio1" == "#paletted" then (
						pngio1_drop.selection = 1
						pngio.setType #paletted
						pngio2_chk.checked = false
						pngio2_chk.enabled = false
					)
					if getUserProp currentcam "pngio1" == "#true24" then (
						pngio1_drop.selection = 2
						pngio.setType #true24
						pngio2_chk.enabled = true
					)
					if getUserProp currentcam "pngio1" == "#true48" then (
						pngio1_drop.selection = 3
						pngio.setType #true48
						pngio2_chk.enabled = true
					)
					if getUserProp currentcam "pngio1" == "#gray8" then (
						pngio1_drop.selection = 4
						pngio.setType #gray8
						pngio2_chk.enabled = true
					)
					if getUserProp currentcam "pngio1" == "#gray16" then (
						pngio1_drop.selection = 5
						pngio.setType #gray16
						pngio2_chk.enabled = true
					)
					if getUserProp currentcam "pngio2" == 1 then  (
						pngio2_chk.checked = true
						pngio.setAlpha true
					)
					if getUserProp currentcam "pngio2" == 0 then	(
						pngio2_chk.checked = false
						pngio.setAlpha false
					)
					if getUserProp currentcam "pngio3" == 1 then  (
						pngio3_chk.checked = true
						pngio.setInterlaced true
					)
					if getUserProp currentcam "pngio3" == 0 then	(
						pngio3_chk.checked = false
						pngio.setInterlaced false
					)
				renderSceneDialog.update()		
				)
				if getuserprop currentcam "RExt" == ".exr" do (
					RExt_drop.selection = 3
					jpgio_box.visible = false
					jpgio1_spinner.visible = false
					jpgio2_spinner.visible = false
					pngio_box.visible = false
					pngio1_drop.visible = false
					pngio2_chk.visible = false
					pngio3_chk.visible = false
					-- 				exrio_box.visible = true
					-- 				exrio1_drop.visible = true
					-- 				exrio2_drop.visible = true
					-- 				exrio3_drop.visible = true
					-- 				exrio4_drop.visible = true
					-- 				exrio5_drop.visible = true
					-- 				exrio6_lbl.visible = true
					exrio_box.visible = false 
					exrio1_drop.visible = false  
					exrio2_drop.visible = false  
					exrio3_drop.visible = false 
					exrio4_drop.visible = false 
					exrio5_drop.visible = false 
					exrio6_lbl.visible = false 
					customio_box.visible = false
					customext_props.visible = false
					rfile_box.height = 116 --286
					managerheight ()
					rrend_layout()
					credits_layout()
					rendoutputfilename = ((getFilenamePath rendoutputfilename) + (getuserprop currentcam "RName" as string)+(getuserprop currentcam "RExt" as string))
					if getuserprop currentcam "exrio1" == undefined then (
						setUserProp currentcam "exrio1" 1
						fopenexr.setLayerOutputFormat 0 1	
						exrio1_drop.selection = 2
					)
					if getuserprop currentcam "exrio2" == undefined then (
						setUserProp currentcam "exrio2" 1
						fopenexr.setLayerOutputType 0 1
						exrio2_drop.selection = 2
					)
					if getuserprop currentcam "exrio3" == undefined then (
						setUserProp currentcam "exrio3" 2
						fopenexr.SetCompression 2
						exrio3_drop.selection = 3
					)
					if getuserprop currentcam "exrio4" == undefined then (
						setUserProp currentcam "exrio4" 0
						fopenexr.setSaveScanline  false
						exrio4_drop.selection = 2
					)
					if getuserprop currentcam "exrio5" == undefined then (
						setUserProp currentcam "exrio5" 0
						fopenexr.setSaveRegion  false
						exrio5_drop.selection = 1
					)
					if getuserprop currentcam "exrio1" == 0 then (
						fopenexr.setLayerOutputFormat 0 0	
						exrio1_drop.selection = 1
					)
					if getuserprop currentcam "exrio1" == 1 then (
						fopenexr.setLayerOutputFormat 0 1	
						exrio1_drop.selection = 2
					)
					if getuserprop currentcam "exrio1" == 2 then (
						fopenexr.setLayerOutputFormat 0 2	
						exrio1_drop.selection = 3
					)
					if getuserprop currentcam "exrio2" == 1 then (
						fopenexr.setLayerOutputType 0 0	
						exrio1_drop.selection = 1
					)
					if getuserprop currentcam "exrio2" == 2 then (
						fopenexr.setLayerOutputType 0 1	
						exrio1_drop.selection = 2
					)
					if getuserprop currentcam "exrio2" == 3 then (
						fopenexr.setLayerOutputType 0 2	
						exrio1_drop.selection = 3
					)
					if getuserprop currentcam "exrio3" == 0 then (
						fopenexr.SetCompression 0	
						exrio3_drop.selection = 1
					)
					if getuserprop currentcam "exrio3" == 1 then (
						fopenexr.SetCompression 1	
						exrio3_drop.selection = 2
					)
					if getuserprop currentcam "exrio3" == 2 then (
						fopenexr.SetCompression 2	
						exrio3_drop.selection = 3
					)
					if getuserprop currentcam "exrio3" == 3 then (
						fopenexr.SetCompression 3	
						exrio3_drop.selection = 4
					)
					if getuserprop currentcam "exrio3" == 4 then (
						fopenexr.SetCompression 4	
						exrio3_drop.selection = 5
					)
					if getuserprop currentcam "exrio3" == 5 then (
						fopenexr.SetCompression 5	
						exrio3_drop.selection = 6
					)
					if getuserprop currentcam "exrio3" == 6 then (
						fopenexr.SetCompression 6	
						exrio3_drop.selection = 7
					)
					if getuserprop currentcam "exrio3" == 7 then (
						fopenexr.SetCompression 7	
						exrio3_drop.selection = 8
					)
					if getuserprop currentcam "exrio4" == 0 then (
					fopenexr.setSaveScanline  false	
					exrio4_drop.selection = 2
					)
					if getuserprop currentcam "exrio4" == 1 then (
						fopenexr.setSaveScanline  true	
						exrio4_drop.selection = 1
					)
					if getuserprop currentcam "exrio5" == 0 then (
						fopenexr.setSaveRegion  false
						exrio4_drop.selection = 1
					)
					if getuserprop currentcam "exrio5" == 1 then (
						fopenexr.setSaveRegion  true
						exrio4_drop.selection = 2
					)
				renderSceneDialog.update()	
				)
				if getuserprop currentcam "RExt" == "Custom" do (
					RExt_drop.selection = 4
					jpgio_box.visible = false
					jpgio1_spinner.visible = false
					jpgio2_spinner.visible = false
					pngio_box.visible = false
					pngio1_drop.visible = false
					pngio2_chk.visible = false
					pngio3_chk.visible = false
					exrio_box.visible = false
					exrio1_drop.visible = false
					exrio2_drop.visible = false
					exrio3_drop.visible = false
					exrio4_drop.visible = false
					exrio5_drop.visible = false
					exrio6_lbl.visible = false
					customio_box.visible = true
					customext_props.visible = true
					rfile_box.height = 116
					managerheight ()
					rrend_layout()
					credits_layout()
				if getuserprop currentcam "RExt2" == undefined then (
					customext_props.text = ""
					rendoutputfilename = ((getFilenamePath rendoutputfilename) + (getuserprop currentcam "RName" as string)+(getuserprop currentcam "RExt2" as string))
				)
				if getuserprop currentcam "RExt2" != undefined then (
					customext_props.text = (getuserprop currentcam "RExt2")
					rendoutputfilename = ((getFilenamePath rendoutputfilename) + (getuserprop currentcam "RName" as string)+(getuserprop currentcam "RExt2" as string))
				)			
				)	
		
		)	
		--[ Environment ]---------------------------------------------------------------------------
		(
			if getuserprop currentcam "REnvClass" == undefined then (
				--setuserprop currentcam "REnvClass" ((classof environmentmap) as string)
			)
			if classof environmentmap == Bitmaptexture and getuserprop currentcam "REnv" == undefined then (
				if getuserprop currentcam "renv_lock" == 0 then (
				rbitmap_on()
				)
				rbitmap_vis()
				coronaoutput_inv()
				renv_box.height = 96
				rsun_layout()
				rfile_layout()
				jpgio_layout()
				pngio_layout()
				exrio_layout()
				customio_layout()
				rrend_layout()
				credits_layout()
				managerheight()
				setuserprop currentcam "REnv" environmentmap
				setuserprop currentcam "REnvClass" (classof environmentmap)
				setuserprop currentcam "RBitmap2" environmentmap.output.output_amount
				bitmap1_spinner.value = environmentmap.output.output_amount
				if environmentmap.filename == undefined then (
					setuserprop currentcam "RBitmap1" ""
					renv_map.text = "None"
				)
				if environmentmap.filename != undefined then (
					setuserprop currentcam "RBitmap1" environmentmap.filename
					renv_map.text = ((getFilenameFile environmentmap.filename) + (getFilenameType environmentmap.filename))
				)
			)
			if getuserprop currentcam "REnv" != undefined and getuserprop currentcam "REnvClass" == "Bitmaptexture" then (
				if getuserprop currentcam "renv_lock" == 0 then (
					rbitmap_on()
				)
				rbitmap_vis()
				coronaoutput_inv()
				renv_box.height = 106
				rsun_layout()
				rfile_layout()
				jpgio_layout()
				pngio_layout()
				exrio_layout()
				customio_layout()
				rrend_layout()
				credits_layout()
				managerheight()
				environmentmap = Bitmaptexture ()
				if getuserprop currentcam "RBitmap2" == undefined then (
					setuserprop currentcam "RBitmap2" environmentmap.output.output_amount 
					bitmap1_spinner.value = environmentmap.output.output_amount 
				)
				if getuserprop currentcam "RBitmap2" != undefined then (
					environmentmap.output.output_amount = getuserprop currentcam "RBitmap2" 
					bitmap1_spinner.value = getuserprop currentcam "RBitmap2" 
				)
				if getuserprop currentcam "RBitmap1" != undefined then (
					renv_map.text = "Bitmap" 
				)
				if environmentmap.filename != undefined and environmentmap.filename != getuserprop currentcam "RBitmap1"  then (
					environmentmap.filename = getuserprop currentcam "RBitmap1" 
					renv_map.text = ((getFilenameFile environmentmap.filename) + (getFilenameType environmentmap.filename))
				)
			)
			-------------------------------------------------------------------------------------------
			------------------------------------------------------------------------------------------
			if classof environmentmap == CoronaOutput and getuserprop currentcam "REnv" == undefined then (
				rbitmap_vis()
				coronaoutput_vis()
				if getuserprop currentcam "renv_lock" == 0 then (
					coronaoutput_on()
				)
				renv_box.height = 220
				rsun_layout()
				rfile_layout()
				jpgio_layout()
				pngio_layout()
				exrio_layout()
				customio_layout()
				rrend_layout()
				credits_layout()
				managerheight()
				setUserProp currentcam "RBitmap2" environmentmap.inputTexmap.output.output_amount
				setuserprop currentcam "REnv" environmentmap
				setuserprop currentcam "REnvClass" (classof environmentmap)
				setuserprop currentcam "CoronaOutput2" environmentmap.brightness
				coronaoutput2_spinner.value = environmentmap.brightness
				setuserprop currentcam "CoronaOutput3" environmentmap.saturation
				coronaoutput3_spinner.value = environmentmap.saturation
				setuserprop currentcam "CoronaOutput4" environmentmap.contrast
				coronaoutput4_spinner.value = environmentmap.contrast
				setuserprop currentcam "CoronaOutput5" environmentmap.gamma
				coronaoutput5_spinner.value = environmentmap.gamma
				setuserprop currentcam "CoronaOutput6" environmentmap.exposure
				coronaoutput6_spinner.value = environmentmap.exposure
				setuserprop currentcam "CoronaOutput7r" (environmentmap.tint.r as integer)
				setuserprop currentcam "CoronaOutput7g" (environmentmap.tint.g as integer)
				setuserprop currentcam "CoronaOutput7b" (environmentmap.tint.b as integer)
				coronaoutput7_pck.color = environmentmap.tint	
				
				if environmentmap.affectedByColorMapping == undefined then (
				setuserprop currentcam "CoronaOutput8" true	
				coronaoutput8_chk.checked = true
				)
				
				if environmentmap.affectedByColorMapping == true then (
				setuserprop currentcam "CoronaOutput8" true	
				coronaoutput8_chk.checked = true
				)
				if environmentmap.affectedByColorMapping == false then (
				setuserprop currentcam "CoronaOutput8" false
				coronaoutput8_chk.checked = false
				)
				if environmentmap.inputTexmap == undefined then (
					renv_map.text = "Corona Output"
					setuserprop currentcam "CoronaOutput1" ""
					coronaoutput1_name.text = "Undefined"
				)
				if environmentmap.inputTexmap != undefined then (
					renv_map.text = ((getFilenameFile environmentmap.inputTexmap.filename) + (getFilenameType environmentmap.inputTexmap.filename))
					setuserprop currentcam "CoronaOutput1" environmentmap.inputTexmap.filename
					coronaoutput1_name.text = environmentmap.inputTexmap.filename
					environmentmap.inputTexmap.output.output_amount = getUserProp currentcam "RBitmap2" 
					bitmap1_spinner.value = getUserProp currentcam "RBitmap2" 
				)
			)
			-------------------------------------------------------------------------------------------
			------------------------------------------------------------------------------------------
			if classof environmentmap == CoronaColorCorrect and getuserprop currentcam "REnv" == undefined then (
				rbitmap_vis()
				coronaoutput_vis()
				if getuserprop currentcam "renv_lock" == 0 then (
					coronaoutput_on()
				)
				renv_box.height = 220
				rsun_layout()
				rfile_layout()
				jpgio_layout()
				pngio_layout()
				exrio_layout()
				customio_layout()
				rrend_layout()
				credits_layout()
				managerheight()
				setUserProp currentcam "RBitmap2" environmentmap.inputTexmap.output.output_amount
				setuserprop currentcam "REnv" environmentmap
				setuserprop currentcam "REnvClass" (classof environmentmap)
				setuserprop currentcam "CoronaOutput2" environmentmap.brightness
				coronaoutput2_spinner.value = environmentmap.brightness
				setuserprop currentcam "CoronaOutput3" environmentmap.saturation
				coronaoutput3_spinner.value = environmentmap.saturation
				setuserprop currentcam "CoronaOutput4" environmentmap.contrast
				coronaoutput4_spinner.value = environmentmap.contrast
				setuserprop currentcam "CoronaOutput5" environmentmap.gamma
				coronaoutput5_spinner.value = environmentmap.gamma
				setuserprop currentcam "CoronaOutput6" environmentmap.exposure
				coronaoutput6_spinner.value = environmentmap.exposure
				setuserprop currentcam "CoronaOutput7r" (environmentmap.tint.r as integer)
				setuserprop currentcam "CoronaOutput7g" (environmentmap.tint.g as integer)
				setuserprop currentcam "CoronaOutput7b" (environmentmap.tint.b as integer)
				coronaoutput7_pck.color = environmentmap.tint	
				
				if environmentmap.affectedByColorMapping == undefined then (
				setuserprop currentcam "CoronaOutput8" true	
				coronaoutput8_chk.checked = true
				)
				
				if environmentmap.affectedByColorMapping == true then (
				setuserprop currentcam "CoronaOutput8" true	
				coronaoutput8_chk.checked = true
				)
				if environmentmap.affectedByColorMapping == false then (
				setuserprop currentcam "CoronaOutput8" false
				coronaoutput8_chk.checked = false
				)
				if environmentmap.inputTexmap == undefined then (
					renv_map.text = "Corona Output"
					setuserprop currentcam "CoronaOutput1" ""
					coronaoutput1_name.text = "Undefined"
				)
				if environmentmap.inputTexmap != undefined then (
					renv_map.text = ((getFilenameFile environmentmap.inputTexmap.filename) + (getFilenameType environmentmap.inputTexmap.filename))
					setuserprop currentcam "CoronaOutput1" environmentmap.inputTexmap.filename
					coronaoutput1_name.text = environmentmap.inputTexmap.filename
					environmentmap.inputTexmap.output.output_amount = getUserProp currentcam "RBitmap2" 
					bitmap1_spinner.value = getUserProp currentcam "RBitmap2" 
				)
			)
			-------------------------------------------------------------------------------------------
			------------------------------------------------------------------------------------------
			
			
			if getuserprop currentcam "REnv" != undefined and getuserprop currentcam "REnvClass" == "CoronaOutput" then (
				rbitmap_vis()
				coronaoutput_vis()
				if getuserprop currentcam "renv_lock" == 0 then (
					coronaoutput_on()
				)
				--print "eureka"
				renv_box.height = 220
				rsun_layout()
				rfile_layout()
				jpgio_layout()
				pngio_layout()
				exrio_layout()
				customio_layout()
				rrend_layout()
				credits_layout()
				managerheight()
				
				
				getCoronaVer()
				
				
				if  CamMan_CoronaVer == undefined then ( 
					getCoronaVer()
					if  CamMan_CoronaVer != undefined and CamMan_CoronaVer < 2  then (  
						environmentmap = CoronaOutput ()
					) 
					if  CamMan_CoronaVer != undefined and CamMan_CoronaVer >= 2  then (  
						environmentmap = CoronaColorCorrect ()
					) 
						
				) 
				if  CamMan_CoronaVer != undefined and CamMan_CoronaVer < 2  then (  
					environmentmap = CoronaOutput ()
				) 
				if  CamMan_CoronaVer != undefined and CamMan_CoronaVer >= 2  then (  
					environmentmap = CoronaColorCorrect ()
				) 
				
				
				
				environmentmap.brightness = getuserprop currentcam "CoronaOutput2"
				coronaoutput2_spinner.value = getuserprop currentcam "CoronaOutput2"
				environmentmap.saturation = getuserprop currentcam "CoronaOutput3" 
				coronaoutput3_spinner.value = getuserprop currentcam "CoronaOutput3"
				environmentmap.contrast = getuserprop currentcam "CoronaOutput4" 
				coronaoutput4_spinner.value = getuserprop currentcam "CoronaOutput4" 
				environmentmap.gamma = getuserprop currentcam "CoronaOutput5" 
				coronaoutput5_spinner.value = getuserprop currentcam "CoronaOutput5" 
				environmentmap.exposure = getuserprop currentcam "CoronaOutput6" 
				coronaoutput6_spinner.value = getuserprop currentcam "CoronaOutput6" 
				environmentmap.tint = (color (getuserprop currentcam "CoronaOutput7r" as integer) (getuserprop currentcam "CoronaOutput7g" as integer) (getuserprop currentcam "CoronaOutput7b" as integer))
				coronaoutput7_pck.color = (color (getuserprop currentcam "CoronaOutput7r" as integer) (getuserprop currentcam "CoronaOutput7g" as integer) (getuserprop currentcam "CoronaOutput7b" as integer))				
				
				if getuserprop currentcam "CoronaOutput8" == true then (
				environmentmap.affectedByColorMapping = true
				coronaoutput8_chk.checked = true
				)
				if getuserprop currentcam "CoronaOutput8" == false then (
				environmentmap.affectedByColorMapping = false
				coronaoutput8_chk.checked = false
				)
				
				if getuserprop currentcam "CoronaOutput1"  == undefined then (
					coronaoutput1_name.text = "None"
					renv_map.text = "CoronaOutput"
				)			
				if getuserprop currentcam "CoronaOutput1" != undefined then (
					environmentmap.inputTexmap = Bitmaptexture ()	
					environmentmap.inputTexmap.output.output_amount = (getUserProp currentcam "RBitmap2" as float) 
					bitmap1_spinner.value = getUserProp currentcam "RBitmap2" 
					environmentmap.inputTexmap.coordinates.mappingtype = 1
					environmentmap.inputTexmap.coordinates.mapping = 0
					environmentmap.inputTexmap.filename = getuserprop currentcam "CoronaOutput1"
					coronaoutput1_name.text = ((getFilenameFile environmentmap.inputTexmap.filename) + (getFilenameType environmentmap.inputTexmap.filename))
					renv_map.text = ((getFilenameFile environmentmap.inputTexmap.filename) + (getFilenameType environmentmap.inputTexmap.filename))
				)
			)
			
			if getuserprop currentcam "REnv" != undefined and getuserprop currentcam "REnvClass" == "CoronaColorCorrect" then (
				environmentmap = CoronaColorCorrect ()
				
				rbitmap_vis()
				coronaoutput_vis()
				if getuserprop currentcam "renv_lock" == 0 then (
					coronaoutput_on()
				)
				--print "eureka"
				renv_box.height = 220
				rsun_layout()
				rfile_layout()
				jpgio_layout()
				pngio_layout()
				exrio_layout()
				customio_layout()
				rrend_layout()
				credits_layout()
				managerheight()
				
				
				getCoronaVer()
				
				
				if  CamMan_CoronaVer == undefined then ( 
					getCoronaVer()
					if  CamMan_CoronaVer != undefined and CamMan_CoronaVer < 2  then (  
						environmentmap = CoronaOutput ()
					) 
					if  CamMan_CoronaVer != undefined and CamMan_CoronaVer >= 2  then (  
						environmentmap = CoronaColorCorrect ()
					) 
						
				) 
				if  CamMan_CoronaVer != undefined and CamMan_CoronaVer < 2  then (  
					environmentmap = CoronaOutput ()
				) 
				if  CamMan_CoronaVer != undefined and CamMan_CoronaVer >= 2  then (  
					environmentmap = CoronaColorCorrect ()
				) 
				
				
				
				environmentmap.brightness = getuserprop currentcam "CoronaOutput2"
				coronaoutput2_spinner.value = getuserprop currentcam "CoronaOutput2"
				environmentmap.saturation = getuserprop currentcam "CoronaOutput3" 
				coronaoutput3_spinner.value = getuserprop currentcam "CoronaOutput3"
				environmentmap.contrast = getuserprop currentcam "CoronaOutput4" 
				coronaoutput4_spinner.value = getuserprop currentcam "CoronaOutput4" 
				environmentmap.gamma = getuserprop currentcam "CoronaOutput5" 
				coronaoutput5_spinner.value = getuserprop currentcam "CoronaOutput5" 
				environmentmap.exposure = getuserprop currentcam "CoronaOutput6" 
				coronaoutput6_spinner.value = getuserprop currentcam "CoronaOutput6" 
				environmentmap.tint = (color (getuserprop currentcam "CoronaOutput7r" as integer) (getuserprop currentcam "CoronaOutput7g" as integer) (getuserprop currentcam "CoronaOutput7b" as integer))
				coronaoutput7_pck.color = (color (getuserprop currentcam "CoronaOutput7r" as integer) (getuserprop currentcam "CoronaOutput7g" as integer) (getuserprop currentcam "CoronaOutput7b" as integer))				
				
				if getuserprop currentcam "CoronaOutput8" == true then (
				environmentmap.affectedByColorMapping = true
				coronaoutput8_chk.checked = true
				)
				if getuserprop currentcam "CoronaOutput8" == false then (
				environmentmap.affectedByColorMapping = false
				coronaoutput8_chk.checked = false
				)
				
				if getuserprop currentcam "CoronaOutput1"  == undefined then (
					coronaoutput1_name.text = "None"
					renv_map.text = "CoronaOutput"
				)			
				if getuserprop currentcam "CoronaOutput1" != undefined then (
					environmentmap.inputTexmap = Bitmaptexture ()	
					environmentmap.inputTexmap.output.output_amount = (getUserProp currentcam "RBitmap2" as float) 
					bitmap1_spinner.value = getUserProp currentcam "RBitmap2" 
					environmentmap.inputTexmap.coordinates.mappingtype = 1
					environmentmap.inputTexmap.coordinates.mapping = 0
					environmentmap.inputTexmap.filename = getuserprop currentcam "CoronaOutput1"
					coronaoutput1_name.text = ((getFilenameFile environmentmap.inputTexmap.filename) + (getFilenameType environmentmap.inputTexmap.filename))
					renv_map.text = ((getFilenameFile environmentmap.inputTexmap.filename) + (getFilenameType environmentmap.inputTexmap.filename))
				)
			)
			
		)
		--[ Sun Position ]---------------------------------------------------------------------------
         setsun()		
		--[ Corona General Settings ]---------------------------------------------------------------------------
		
		
		/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//// SCRIPTS ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
		if getuserprop currentcam "Script_In" == undefined then (
		script_in.text = ""
		)
		
		
		if getuserprop currentcam "Script_In" != undefined then (
		script_in.text = getuserprop currentcam "Script_In"
			
		script_in.text = (getuserprop currentcam "Script_In" as string)
			--print (script_in.text)
			try execute (getuserprop currentcam "Script_In")
		catch ()
		)
		
		/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//// NOTES /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
		
		if getuserprop currentcam "Notes_In" == undefined then (
			notes_in.text = ""
		)
		
		if getuserprop currentcam "Notes_In" != undefined then (
			notes_in.text = getuserprop currentcam "Notes_In"		
		)	
	)--End Of camera selection
	
/*//// BUTTONS ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/	



/* --LOCKS //////////////////////////////////////////////////////////////////////////////////////////////// */
on rtime_lock  changed state do ( 
	if state == on and lockson == true then (
		setUserProp currentcam "rtime_lock"  0
		rtime_on ()
		
	)
	if state == off and lockson == true then (
		setUserProp currentcam "rtime_lock"  1
		rtime_off ()
	)
)
on rarea_lock  changed state do ( 
	if state == on and lockson == true then (
		setUserProp currentcam "rarea_lock"  0
		rarea_on ()
	)
	if state == off and lockson == true then (
		setUserProp currentcam "rarea_lock"  1
		rarea_off ()
	)
)
on rlay_lock  changed state do ( 
	if state == on and lockson == true then (
		setUserProp currentcam "rlay_lock"  0
		rlay_on ()
	)
	if state == off and lockson == true then (	
		setUserProp currentcam "rlay_lock"  1
		rlay_off ()
	)
)
on rsize_lock  changed state do ( 
	if state == on and lockson == true then (
		setUserProp currentcam "rsize_lock"  0
		rsize_on ()
	)
	if state == off and lockson == true then (
		setUserProp currentcam "rsize_lock"  1
		rsize_off ()
	)
)
on renv_lock  changed state do ( 
	if state == on and lockson == true then (
		setUserProp currentcam "renv_lock"  0
		renv_on ()
		rbitmap_on()
		coronaoutput_on()
	)
	if state == off and lockson == true then (
		setUserProp currentcam "renv_lock"  1
		renv_off ()
		rbitmap_off()
		coronaoutput_off()
	)
)
on rsun_lock  changed state do ( 
	if state == on and lockson == true then (
		setUserProp currentcam "rsun_lock"  0
		rsun_on ()
	)
	if state == off and lockson == true then (
		setUserProp currentcam "rsun_lock"  1
		rsun_off ()
	)
)
on rfile_lock  changed state do ( 
	if state == on and lockson == true then (
		setUserProp currentcam "rfile_lock"  0
		rfile_on ()
		jpgio_on()
		pngio_on()
		exrio_on()
		--customio_on()
	)
	if state == off and lockson == true then (
		setUserProp currentcam "rfile_lock"  1
		rfile_off ()
		pngio_off()
		exrio_off()
		--customio_off()
	)
)

/* --GOTOCAMERA //////////////////////////////////////////////////////////////////////////////////////////////// */
on cam_go changed ckeck do (
		if cam_go.checked == true then  (
		gotocam = true
		)
		if cam_go.checked == false then	(
		gotocam = false
		)
)	
on cam_lock changed ckeck do (
		if cam_lock.checked == true then  (
		setuserprop currentcam "camlock" true
		setTransformLockFlags currentcam #all
			if currentcam.target != undefined then (
			setTransformLockFlags currentcam.target #all			
			)
		)
		if cam_lock.checked == false then	(
		setuserprop currentcam "camlock" false
		setTransformLockFlags currentcam #none
			if currentcam.target != undefined then (
			setTransformLockFlags currentcam.target #none			
			)
		)
)
/* --CAMERA NAME//////////////////////////////////////////////////////////////////////////////////////////////// */
on cam_name entered new_name do (
		-- rename camera if text in name box is changed
		currentcam.name = new_name
		
		-- refresh and update list and name
		cameralist.items = for o in cameras where classof o != TargetObject collect o.name
		cam_name.text = currentcam.name
		debugger.text = "Camera renamed"
)
/* --RENDER AREAS ///////////////////////////////////////////////////////////////////////////////////// */
on corona_region_chk changed check do (
	
if corona_region_chk.checked == true do (
			setuserprop currentcam "CoronaRegion" true
			renderers.current.system_vfbRegions_enabled = true
)
if corona_region_chk.checked == false do (
			setuserprop currentcam "CoronaRegion" false
			renderers.current.system_vfbRegions_enabled = false
)
		
)
on rarea_drop selected i do (
		rarea_pck.checked = false
		debugger.text = "Render Type set to " + (rarea_drop.items[i] as string)
		setUserProp currentcam "RArea" (rarea_drop.items[i] as string)	
		if EditRenderRegion.IsEditing == true then (
			EditRenderRegion.EditRegion()
			print"test"
		)	
		if EditRenderRegion.IsEditing == falcse then (
			EditRenderRegion.UpdateRegion()
		)
		if  (getuserprop currentcam "RArea" as string) == "View" then (
						--------	
			corona_region_chk.visible = true
			if getuserprop currentcam "CoronaRegion" == true then ( 
				renderers.current.system_vfbRegions_enabled = true
				corona_region_chk.checked = true
				)
			if getuserprop currentcam "CoronaRegion" == false then ( 
				renderers.current.system_vfbRegions_enabled = false
				corona_region_chk.checked = false
				)
			--------
			setRenderType #view
			rarea_pck.visible = false
			EditRenderRegion.UpdateRegion()
		)		
		if  (getuserprop currentcam "RArea" as string) == "Selected" then (
						--------	
			corona_region_chk.visible = true
			if getuserprop currentcam "CoronaRegion" == true then ( 
				renderers.current.system_vfbRegions_enabled = true
				corona_region_chk.checked = true
				)
			if getuserprop currentcam "CoronaRegion" == false then ( 
				renderers.current.system_vfbRegions_enabled = false
				corona_region_chk.checked = false
				)
			--------
			setRenderType #selected
			rarea_pck.visible = false
			EditRenderRegion.UpdateRegion()
		)		
		if  (getuserprop currentcam "RArea" as string) == "Region" then (
			corona_region_chk.visible = false
			renderers.current.system_vfbRegions_enabled = false
			setRenderType #region
			rarea_pck.visible = true
			rarea_pck.text = "Set Region Box"
			if getuserprop currentcam "RCropX" == undefined then (
				setuserprop currentcam "RCropX" 0 --(viewport.getRegionRect viewport.activeViewport).x
				setuserprop currentcam "RCropY" 0 --(viewport.getRegionRect viewport.activeViewport).y
				setuserprop currentcam "RCropW" 1 --(viewport.getRegionRect viewport.activeViewport).w
				setuserprop currentcam "RCropH" 1 --(viewport.getRegionRect viewport.activeViewport).h
			)
			if getuserprop currentcam "RCropX" != undefined then (
				viewport.setRegionRect viewport.activeViewport (Box2 ((getuserprop currentcam "RCropX")*renderWidth) ((getuserprop currentcam "RCropY")*renderHeight) ((getuserprop currentcam "RCropW")*renderWidth) ((getuserprop currentcam "RCropH")*renderHeight))
			)
			EditRenderRegion.UpdateRegion()	
		)			
		if  (getuserprop currentcam "RArea" as string) == "Crop" then (
			corona_region_chk.visible = false
			renderers.current.system_vfbRegions_enabled = false
			setRenderType #crop
			rarea_pck.visible = true
			rarea_pck.text = "Set Crop Box"
			if getuserprop currentcam "RCropX" == undefined then (
				setuserprop currentcam "RCropX" 0 --(viewport.getRegionRect viewport.activeViewport).x
				setuserprop currentcam "RCropY" 0 --(viewport.getRegionRect viewport.activeViewport).y
				setuserprop currentcam "RCropW" 1 --(viewport.getRegionRect viewport.activeViewport).w
				setuserprop currentcam "RCropH" 1 --(viewport.getRegionRect viewport.activeViewport).h
			)
			if getuserprop currentcam "RCropX" != undefined then (
				viewport.setRegionRect viewport.activeViewport (Box2 ((getuserprop currentcam "RCropX")*renderWidth) ((getuserprop currentcam "RCropY")*renderHeight) ((getuserprop currentcam "RCropW")*renderWidth) ((getuserprop currentcam "RCropH")*renderHeight))
			)
			EditRenderRegion.UpdateRegion()
		)
		if  (getuserprop currentcam "RArea" as string) == "Blowup" then (
			corona_region_chk.visible = false
			renderers.current.system_vfbRegions_enabled = false
			setRenderType #blowup
			rarea_pck.visible = true
			rarea_pck.text = "Set Blowup Box"
			if getuserprop currentcam "RBlowX" == undefined then (
				setuserprop currentcam "RBlowX" 0 --(viewport.getBlowupRect viewport.activeViewport).x
				setuserprop currentcam "RBlowY" 0 --(viewport.getBlowupRect viewport.activeViewport).y
				setuserprop currentcam "RBlowW" 1 --(viewport.getBlowupRect viewport.activeViewport).w
				setuserprop currentcam "RBlowH" 1 --(viewport.getBlowupRect viewport.activeViewport).h
			)
			if getuserprop currentcam "RBlowX" != undefined then (
				viewport.setBlowupRect viewport.activeViewport (Box2 ((getuserprop currentcam "RBlowX")*renderWidth) ((getuserprop currentcam "RBlowY")*renderHeight) ((getuserprop currentcam "RBlowW")*renderWidth) ((getuserprop currentcam "RBlowH")*renderHeight))
			)
			EditRenderRegion.UpdateRegion()	
		)	
		renderSceneDialog.update()	
		macros.run "Lights and Cameras" "Camera_ActivateView"
		completeRedraw()
)

on rarea_pck changed state do ( 
	if state == on then (
		EditRenderRegion.EditRegion()
	)
	if state == off then (
		if  (getuserprop currentcam "RArea" as string) == "Region" then (
				setuserprop currentcam "RCropX" ((((viewport.getRegionRect viewport.activeViewport).x)as float)/renderWidth)
				setuserprop currentcam "RCropY" ((((viewport.getRegionRect viewport.activeViewport).y)as float)/renderHeight)
				setuserprop currentcam "RCropW" ((((viewport.getRegionRect viewport.activeViewport).w)as float)/renderWidth)
				setuserprop currentcam "RCropH" ((((viewport.getRegionRect viewport.activeViewport).h)as float)/renderHeight)
			)
			if  (getuserprop currentcam "RArea" as string) == "Crop" then (
				setuserprop currentcam "RCropX" ((((viewport.getRegionRect viewport.activeViewport).x)as float)/renderWidth)
				setuserprop currentcam "RCropY" ((((viewport.getRegionRect viewport.activeViewport).y)as float)/renderHeight)
				setuserprop currentcam "RCropW" ((((viewport.getRegionRect viewport.activeViewport).w)as float)/renderWidth)
				setuserprop currentcam "RCropH" ((((viewport.getRegionRect viewport.activeViewport).h)as float)/renderHeight)
			)
			if  (getuserprop currentcam "RArea" as string) == "Blowup" then (
				setuserprop currentcam "RBlowX" ((((viewport.getBlowupRect viewport.activeViewport).x)as float)/renderWidth)
				setuserprop currentcam "RBlowY" ((((viewport.getBlowupRect viewport.activeViewport).y)as float)/renderHeight)
				setuserprop currentcam "RBlowW" ((((viewport.getBlowupRect viewport.activeViewport).w)as float)/renderWidth)
				setuserprop currentcam "RBlowH" ((((viewport.getBlowupRect viewport.activeViewport).h)as float)/renderHeight)
			)
		EditRenderRegion.EditRegion()
	)
)

/* --LAYERS ///////////////////////////////////////////////////////////////////////////////////////////////////////////// */
on LayerList  Selected sel do (
	lyrIndex = sel 
	Temp_LM = LayerManager
	lyrName = Temp_LM.getLayerFromName LyrList[lyrIndex]
	lyrName.current = true
	
	if layermanager.current.on == false then (
		lay1_button.visible = false
		lay2_button.visible = true
	)
	if layermanager.current.on == true then (
		lay1_button.visible = true
		lay2_button.visible = false
	)

)

on lay1_button pressed do ( 
	
	if layermanager.current.on == true then (
		layermanager.current.on = false
		lay1_button.visible = false
		lay2_button.visible = true
		for i in 0 to layerManager.count-1 do (

			lay = layerManager.getLayer i
			setuserprop currentcam ("Layer" + i as string) lay.on		
		)
	)

)

on lay2_button pressed do (
	
	if layermanager.current.on == false then (
		layermanager.current.on = true
		lay1_button.visible = true
		lay2_button.visible = false
		for i in 0 to layerManager.count-1 do (

			lay = layerManager.getLayer i
			setuserprop currentcam ("Layer" + i as string) lay.on		
		)
	)

)

on lay3_chk changed state do (	
		lay3_chk.checked = state
		changelayers = state
)


/* --RENDER SIZE///////////////////////////////////////////////////////////////////////////////////////////////// */
on rwidth_spinner changed rwidth_new do (
		if getuserprop currentcam "RLock" == 0 then (
			setUserProp currentcam "RWidth" rwidth_spinner.value
			renderWidth = rwidth_spinner.value
			--Ratio
			ratio_spinner.value = getRendImageAspect() 
			setUserProp currentcam "RAspect" (getRendImageAspect() as float)
			--Text
			cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string
			debugger.text = "Changed Render Width to " + ((getuserprop currentcam "RWidth") as string)
			renderSceneDialog.update()
		)
		if getuserprop currentcam "RLock" == 1 then (
			setUserProp currentcam "RWidth" rwidth_spinner.value
			renderWidth = (getuserprop currentcam "RWidth")
			renderHeight = (getuserprop currentcam "RWidth") / (getUserProp currentcam "RAspect")
			setUserProp currentcam "RHeight" (ceil((getuserprop currentcam "RWidth") / (getUserProp currentcam "RAspect")))
			rheight_spinner.value =  (ceil((getuserprop currentcam "RWidth") / (getUserProp currentcam "RAspect")))
			--Text
			cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string
			renderSceneDialog.update()
		)
)	
on rheight_spinner changed height_new do (
		
		if getuserprop currentcam "RLock" == 0 then (
				setUserProp currentcam "RHeight" rheight_spinner.value
				renderHeight = rheight_spinner.value
				--Ratio
				ratio_spinner.value = getRendImageAspect() 
				setUserProp currentcam "RAspect" (getRendImageAspect() as float)
				--Text
				cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string
				debugger.text = "Changed Render Height to " + ((getuserprop currentcam "RWidth") as string)
				renderSceneDialog.update()
		)
	
	
		if getuserprop currentcam "RLock" == 1 then (
			setUserProp currentcam "RHeight" rheight_spinner.value
			renderHeight = (getuserprop currentcam "RHeight")
			renderWidth = (getuserprop currentcam "RHeight") * (getUserProp currentcam "RAspect")
			setUserProp currentcam "RWidth" (ceil((getuserprop currentcam "RHeight") * (getUserProp currentcam "RAspect")))
			rwidth_spinner.value = (ceil((getuserprop currentcam "RHeight") * (getUserProp currentcam "RAspect")))
			--Text
			cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string
			renderSceneDialog.update()
		)
)	

/* --ASPECT RATIO/////////////////////////////////////////////////////////////////////////////////////////////// */
on ratio_spinner changed aspect_new do (
		renderHeight = (getuserprop currentcam "RWidth") / (getuserprop currentcam "RAspect")
		setRendImageAspect = ratio_spinner.value
		setUserProp currentcam "RAspect" ratio_spinner.value
		rheight_spinner.value = renderHeight
		cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string	
		debugger.text = "Changed Render Aspect to " + (getRendImageAspect() as string)
		renderSceneDialog.update()
)	
on ratio_chk changed ckeck do (
		if ratio_chk.checked == true then  (	
			setuserprop currentcam "RLock" 1
			ratio_spinner.enabled = false	
			renderSceneDialog.update()
		)
		
		if ratio_chk.checked == false then	(
			setuserprop currentcam "RLock" 0
			ratio_spinner.enabled = true
			renderSceneDialog.update()	
		)
		
)

/* --SIZE PRESETS/////////////////////////////////////////////////////////////////////////////////////////////// */
on hd0_button pressed do (
		setUserProp currentcam "RHeight" 720
		setUserProp currentcam "RWidth" 1280
		renderHeight = 720
		renderWidth = 1280
		rheight_spinner.value = 720 
		rwidth_spinner.value = 1280 
		ratio_spinner.value =  getRendImageAspect()
		updateratio = getRendImageAspect()
		setUserProp currentcam "RAspect" updateratio
		cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string	
		debugger.text = "Changed Render Height to preview resolution."
		renderSceneDialog.update()
)	
on hd1_button pressed do (
		setUserProp currentcam "RHeight" 1080
		setUserProp currentcam "RWidth" 1920
		renderHeight = 1080
		renderWidth = 1920
		rheight_spinner.value = 1080 
		rwidth_spinner.value = 1920
		ratio_spinner.value =  getRendImageAspect()
		updateratio = getRendImageAspect()
		setUserProp currentcam "RAspect" updateratio
		cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string	
		debugger.text = "Changed Render Height to Full HD resolution."
		renderSceneDialog.update()
)	
on hd2_button pressed do (
		setUserProp currentcam "RHeight" 2560
		setUserProp currentcam "RWidth" 3840
		renderHeight = 2560
		renderWidth = 3840
		rheight_spinner.value = 2560 
		rwidth_spinner.value = 3840 
		ratio_spinner.value =  getRendImageAspect()
		updateratio = getRendImageAspect()
		setUserProp currentcam "RAspect" updateratio
		cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string	
		debugger.text = "Changed Render Height to 4K resolution."
		renderSceneDialog.update()
)	
on hd3_button pressed do (
		setUserProp currentcam "RHeight" 8000
		setUserProp currentcam "RWidth" 8000
		renderHeight = 8000
		renderWidth = 8000
		rheight_spinner.value = 8000 
		rwidth_spinner.value = 8000 
		ratio_spinner.value =  getRendImageAspect()
		updateratio = getRendImageAspect()
		setUserProp currentcam "RAspect" updateratio
		cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string	
		debugger.text = "Changed Render Height to Panorama resolution."
		renderSceneDialog.update()
)	

/* --///////SUN /////////////////////////////////////////////////////////////////////////////////////////////////////// */	
on sun_on changed state do (
	setuserprop currentcam "SunOn" state
	setsun()
)
on sun_targeted changed state do (
	setuserprop currentcam "SunTarget" state
	setsun()
)
on sun_env changed state do (
	setuserprop currentcam "SunCoronaSky" state
	setsun()
)

on sun_vis1  changed state do (
	setuserprop currentcam "SunVis1" state
	setsun()
)
on sun_vis2  changed state do (
	setuserprop currentcam "SunVis2" state
	setsun()
)
on sun_vis3  changed state do (
	setuserprop currentcam "SunVis3" state
	setsun()
)
on sun_vis4  changed state do (
	setuserprop currentcam "SunVis4" state
	setsun()
)
on sun_azimuth changed sun_new do (
	setuserprop currentcam "Sun" sun_new
	setsun()
)
on sun_elevation changed sun_new do (
	setuserprop currentcam "SunElevation" sun_new
	setsun()
)
on sun_intensity changed sun_int do (
	setuserprop currentcam "SunIntensity" sun_int
	setsun()
)
on sun_size changed sun_size do (
	setuserprop currentcam "SunSize" sun_size
	setsun()
)
on sun_anim changed check do (
		if sun_anim.checked == true then  (	
			setuserprop currentcam "SunAnim" 1
			setsun()
		)
		if sun_anim.checked == false then	(
			setuserprop currentcam "SunAnim" 0
			setsun()
		)
		
)
on sun_wire changed check do (
		if sun_wire.checked == true then  (	
			setuserprop currentcam "SunWire" true
			setsun()
		)
		if sun_wire.checked == false then	(
			setuserprop currentcam "SunWire" false
			setsun()
		)		
)

/* --FILE /////////////////////////////////////////////////////////////////////////////////////////////////////////////// */
/* 	on file_button pressed do
		(
			try
				file_save = getBitmapSaveFileName()
			catch (getCurrentException())
			
			if file_name != undefined then
			(		
				
    setUserProp currentcam "RFile" file_save as string
	rname_props.text = (getuserprop currentcam "RFile" as string)
	rendOutputFilename = ""
	debugger.text = "Changed Output to " + (getFilenameFile rendoutputfilename as string) 
      
				
			)
		) */

/* --RENDER EXTENSION /////////////////////////////////////////////////////////////////////////////////// */
on rext_drop selected i do ( 
		debugger.text = "Render Extension set to " + (rext_drop.items[i] as string)
		setUserProp currentcam "RExt" (rext_drop.items[i])
		rendoutputfilename = ((getFilenamePath rendoutputfilename) + (getuserprop currentcam "RName" as string)+(getuserprop currentcam "RExt" as string))
		renderSceneDialog.update()		
		if (rext_drop.items[i]) == ".jpg" then (
			jpgio_box.visible = true
			jpgio1_spinner.visible = true
			jpgio2_spinner.visible = true
			pngio_box.visible = false
			pngio1_drop.visible = false
			pngio2_chk.visible = false
			pngio3_chk.visible = false
			exrio_box.visible = false
			exrio1_drop.visible = false
			exrio2_drop.visible = false
			exrio3_drop.visible = false
			exrio4_drop.visible = false
			exrio5_drop.visible = false
			exrio6_lbl.visible = false
			customio_box.visible = false
			customext_props.visible = false
			rfile_box.height = 116
			managerheight ()
			rrend_layout()
			credits_layout()
			if getUserProp currentcam "jpgio1" != undefined then (
				jpgio1_spinner.value = (getUserProp currentcam "jpgio1")
				jpegio.setQuality (getUserProp currentcam "jpgio1")
			)
			if getUserProp currentcam "jpgio2" != undefined then (
				jpgio2_spinner.value = (getUserProp currentcam "jpgio2")
				jpegio.setSmoothing (getUserProp currentcam "jpgio2")
			)
		)	
		if (rext_drop.items[i]) == ".png" then (
			jpgio_box.visible = false
			jpgio1_spinner.visible = false
			jpgio2_spinner.visible = false
			pngio_box.visible = true
			pngio1_drop.visible = true
			pngio2_chk.visible = true
			pngio3_chk.visible = true
			exrio_box.visible = false
			exrio1_drop.visible = false
			exrio2_drop.visible = false
			exrio3_drop.visible = false
			exrio4_drop.visible = false
			exrio5_drop.visible = false
			exrio6_lbl.visible = false
			customio_box.visible = false
			customext_props.visible = false
			rfile_box.height = 136
			managerheight ()
			rrend_layout()
			credits_layout()
			if getUserProp currentcam "pngio1" == undefined then (
					pngio1_drop.selection = 2
					pngio.setType #true24
			)
			if getUserProp currentcam "pngio1" == "#paletted" then (
					pngio1_drop.selection = 1
					pngio.setType #paletted
					pngio2_chk.checked = false
					pngio2_chk.enabled = false
			)
			if getUserProp currentcam "pngio1" == "#true24" then (
					pngio1_drop.selection = 2
					pngio.setType #true24
					pngio2_chk.enabled = true
			)
			if getUserProp currentcam "pngio1" == "#true48" then (
					pngio1_drop.selection = 3
					pngio.setType #true48
					pngio2_chk.enabled = true
			)
			if getUserProp currentcam "pngio1" == "#gray8" then (
					pngio1_drop.selection = 4
					pngio.setType #gray8
					pngio2_chk.enabled = true
			)
			if getUserProp currentcam "pngio1" == "#gray16" then (
					pngio1_drop.selection = 5
					pngio.setType #gray16
					pngio2_chk.enabled = true
			)
			if getUserProp currentcam "pngio2" == undefined then	(
				setUserProp currentcam "pngio2" 1
				pngio2_chk.checked = false
				pngio.setAlpha false
			)
			if getUserProp currentcam "pngio3" == undefined then  (
				setUserProp currentcam "pngio3" 0
				pngio3_chk.checked = true
				pngio.setInterlaced true
			)
			if getUserProp currentcam "pngio2" == 1 then  (
				pngio2_chk.checked = true
				pngio.setAlpha true
			)
			if getUserProp currentcam "pngio2" == 0 then	(
				pngio2_chk.checked = false
				pngio.setAlpha false
			)
			if getUserProp currentcam "pngio3" == 1 then  (
				pngio3_chk.checked = true
				pngio.setInterlaced true
			)
			if getUserProp currentcam "pngio3" == 0 then	(
				pngio3_chk.checked = false
				pngio.setInterlaced false
			)
		)	
		if (rext_drop.items[i]) == ".exr" then (
			jpgio_box.visible = false
			jpgio1_spinner.visible = false
			jpgio2_spinner.visible = false
			pngio_box.visible = false
			pngio1_drop.visible = false
			pngio2_chk.visible = false
			pngio3_chk.visible = false
-- 			exrio_box.visible = true
-- 			exrio1_drop.visible = true
-- 			exrio2_drop.visible = true
-- 			exrio3_drop.visible = true
-- 			exrio4_drop.visible = true
-- 			exrio5_drop.visible = true
-- 			exrio6_lbl.visible = true
	exrio_box.visible = false 
	exrio1_drop.visible = false  
	exrio2_drop.visible = false  
	exrio3_drop.visible = false 
	exrio4_drop.visible = false 
	exrio5_drop.visible = false 
	exrio6_lbl.visible = false 
			customio_box.visible = false
			customext_props.visible = false
			rfile_box.height = 116 --286
			managerheight ()
			rrend_layout()
			credits_layout()
			if getuserprop currentcam "exrio1" == undefined then (
				setUserProp currentcam "exrio1" 1
				fopenexr.setLayerOutputFormat 0 1	
				exrio1_drop.selection = 2
			)
			if getuserprop currentcam "exrio2" == undefined then (
				setUserProp currentcam "exrio2" 0
				fopenexr.setLayerOutputType 0 0
				exrio2_drop.selection = 1
			)
			if getuserprop currentcam "exrio3" == undefined then (
				setUserProp currentcam "exrio3" 2
				fopenexr.SetCompression 2
				exrio3_drop.selection = 3
			)
			if getuserprop currentcam "exrio4" == undefined then (
				setUserProp currentcam "exrio4" 0
				fopenexr.setSaveScanline  false
				exrio4_drop.selection = 2
			)
			if getuserprop currentcam "exrio5" == undefined then (
				setUserProp currentcam "exrio5" 0
				fopenexr.setSaveRegion  false
				exrio5_drop.selection = 1
			)--End of defaults
			if getuserprop currentcam "exrio1" == 0 then (
				fopenexr.setLayerOutputFormat 0 0	
				exrio1_drop.selection = 1
			)
			if getuserprop currentcam "exrio1" == 1 then (
				fopenexr.setLayerOutputFormat 0 1	
				exrio1_drop.selection = 2
			)
			if getuserprop currentcam "exrio1" == 2 then (
				fopenexr.setLayerOutputFormat 0 2	
				exrio1_drop.selection = 3
			)
			if getuserprop currentcam "exrio2" == 1 then (
				fopenexr.setLayerOutputType 0 0	
				exrio1_drop.selection = 1
			)
			if getuserprop currentcam "exrio2" == 2 then (
				fopenexr.setLayerOutputType 0 1	
				exrio1_drop.selection = 2
			)
			if getuserprop currentcam "exrio2" == 3 then (
				fopenexr.setLayerOutputType 0 2	
				exrio1_drop.selection = 3
			)
			if getuserprop currentcam "exrio3" == 0 then (
				fopenexr.SetCompression 0	
				exrio3_drop.selection = 1
			)
			if getuserprop currentcam "exrio3" == 1 then (
				fopenexr.SetCompression 1	
				exrio3_drop.selection = 2
			)
			if getuserprop currentcam "exrio3" == 2 then (
				fopenexr.SetCompression 2	
				exrio3_drop.selection = 3
			)
			if getuserprop currentcam "exrio3" == 3 then (
				fopenexr.SetCompression 3	
				exrio3_drop.selection = 4
			)
			if getuserprop currentcam "exrio3" == 4 then (
				fopenexr.SetCompression 4	
				exrio3_drop.selection = 5
			)
			if getuserprop currentcam "exrio3" == 5 then (
				fopenexr.SetCompression 5	
				exrio3_drop.selection = 6
			)
			if getuserprop currentcam "exrio3" == 6 then (
				fopenexr.SetCompression 6	
				exrio3_drop.selection = 7
			)
			if getuserprop currentcam "exrio3" == 7 then (
				fopenexr.SetCompression 7	
				exrio3_drop.selection = 8
			)
			if getuserprop currentcam "exrio4" == 0 then (
				fopenexr.setSaveScanline  false	
				exrio4_drop.selection = 2
			)
			if getuserprop currentcam "exrio4" == 1 then (
				fopenexr.setSaveScanline  true	
				exrio4_drop.selection = 1
			)
			if getuserprop currentcam "exrio5" == 0 then (
				fopenexr.setSaveRegion  false
				exrio4_drop.selection = 1
			)
			if getuserprop currentcam "exrio5" == 1 then (
				fopenexr.setSaveRegion  true
				exrio4_drop.selection = 2
			)
		)
		if (rext_drop.items[i]) == "Custom" then (
			jpgio_box.visible = false
			jpgio1_spinner.visible = false
			jpgio2_spinner.visible = false
			pngio_box.visible = false
			pngio1_drop.visible = false
			pngio2_chk.visible = false
			pngio3_chk.visible = false
			exrio_box.visible = false
			exrio1_drop.visible = false
			exrio2_drop.visible = false
			exrio3_drop.visible = false
			exrio4_drop.visible = false
			exrio5_drop.visible = false
			exrio6_lbl.visible = false
			customio_box.visible = true
			customext_props.visible = true
			rfile_box.height = 116
			managerheight ()
			rrend_layout()
			credits_layout()
		)			
)		

/* --FILE IO CONTROLS ///////////////////////////////////////////////////////////////////////////////////// */	
on jpgio1_spinner changed jpgio1_new do (
		setUserProp currentcam "jpgio1" jpgio1_spinner.value
		jpegio.setQuality (getUserProp currentcam "jpgio1")
		debugger.text = "Changed .jpg Output Quality to " + ((getUserProp currentcam "jpgio1") as string)
		renderSceneDialog.update()
)--End of Quality setup
on jpgio2_spinner changed jpgio2_new do (
		setUserProp currentcam "jpgio2" jpgio2_spinner.value
		jpegio.setSmoothing (getUserProp currentcam "jpgio2")
		debugger.text = "Changed .jpg Output Smoothing to " + ((getUserProp currentcam "jpgio2") as string)
		renderSceneDialog.update()	
)--End of Smoothing Setup	
on pngio1_drop selected i do (
		if (pngio1_drop.items[i]) == "Optimized (256)" then (
		setUserProp currentcam "pngio1" "#paletted"
		pngio.setType #paletted
		pngio2_chk.checked = false
		pngio2_chk.enabled = false
		debugger.text = "Changed .png Output Type to " + (getUserProp currentcam "pngio1") as string
		)
		if (pngio1_drop.items[i]) == "RGB 24bit" then (
		setUserProp currentcam "pngio1" "#true24"
		pngio.setType #true24
		pngio2_chk.enabled = true
		debugger.text = "Changed .png Output Type to " + (getUserProp currentcam "pngio1") as string
		)
		if (pngio1_drop.items[i]) == "RGB 48bit" then (
		setUserProp currentcam "pngio1" "#true48"
		pngio.setType #true48
		pngio2_chk.enabled = true
		debugger.text = "Changed .png Output Type to " + (getUserProp currentcam "pngio1") as string
		)
		if (pngio1_drop.items[i]) == "Grayscale 8bit" then (
		setUserProp currentcam "pngio1" "#gray8"
		pngio.setType #gray8
		pngio2_chk.enabled = true
		debugger.text = "Changed .png Output Type to " + (getUserProp currentcam "pngio1") as string
		)
		if (pngio1_drop.items[i]) == "Grayscale 16bit" then (
		setUserProp currentcam "pngio1" "#gray16"
		pngio.setType #gray16
		pngio2_chk.enabled = true
		debugger.text = "Changed .png Output Type to " + (getUserProp currentcam "pngio1") as string
		)
		renderSceneDialog.update()
)--End of Color Setup	
on pngio2_chk changed ckeck do (
		if pngio2_chk.checked == true then  (
			setUserProp currentcam "pngio2" 1
			pngio.setAlpha true
			renderSceneDialog.update()
		)
		if pngio2_chk.checked == false then	(
			setUserProp currentcam "pngio2" 0
			pngio.setAlpha false
			renderSceneDialog.update()
		)
)--End of Alpha Setup
on pngio3_chk changed ckeck do (
		if pngio3_chk.checked == true then  (
			setUserProp currentcam "pngio3" 1
			pngio.setInterlaced true
		)
		if pngio3_chk.checked == false then	(
			setUserProp currentcam "pngio3" 0
			pngio.setInterlaced false
		)
)--End of Interlacing Setup	
on exrio1_drop selected i do (
		if (exrio1_drop.items[i]) == "Full Float (32bit)" then (
			setUserProp currentcam "exrio1" 0
			fopenexr.setLayerOutputFormat 0 0
			debugger.text = "Changed .exr Output Format to Full Float (24bit)"
			renderSceneDialog.update()
		)
		if (exrio1_drop.items[i]) == "Half Float (16bit)" then (
			setUserProp currentcam "exrio1" 1
			fopenexr.setLayerOutputFormat 0 1	
			debugger.text = "Changed .exr Output Format to Half Float (16bit)"
			renderSceneDialog.update()
		)
		if (exrio1_drop.items[i]) == "Integer (32bit)" then (
			setUserProp currentcam "exrio1" 2
			fopenexr.setLayerOutputFormat 0 2	
			debugger.text = "Changed .exr Output Format to Integer (32bit)"
			renderSceneDialog.update()
		)
)--End of Format Setup	
on exrio2_drop selected i do (
		if (exrio2_drop.items[i]) == "RGBA" then (
		setUserProp currentcam "exrio2" 0
		fopenexr.setLayerOutputType 0 0
		debugger.text = "Changed .exr Output Type to RGBA"
		renderSceneDialog.update()
		)
		if (exrio2_drop.items[i]) == "RGB" then (
		setUserProp currentcam "exrio2" 1
		fopenexr.setLayerOutputType 0 1
		debugger.text = "Changed .exr Output Type to RGB"
		renderSceneDialog.update()
		)
		if (exrio2_drop.items[i]) == "Mono" then (
		setUserProp currentcam "exrio2" 2
		fopenexr.setLayerOutputType 0 2
		debugger.text = "Changed .exr Output Type to Mono"
		renderSceneDialog.update()
		)
)--End of Type Setup	
on exrio3_drop selected i do (
		if (exrio3_drop.items[i]) == "No compression" then (
			setUserProp currentcam "exrio3" 0
			fopenexr.SetCompression 0
			debugger.text = "Changed .exr Compression to None"
			renderSceneDialog.update()
		)
		if (exrio3_drop.items[i]) == "Run Lenght Encoding (RLE)" then (
		setUserProp currentcam "exrio3" 1
		fopenexr.SetCompression 1
		debugger.text = "Changed .exr Compression to RLE"
		renderSceneDialog.update()
		)
		if (exrio3_drop.items[i]) == "Zip Compression per Scanline (ZIPS)" then (
			setUserProp currentcam "exrio3" 2
			fopenexr.SetCompression 2
			debugger.text = "Changed .exr Compression to ZIPS"
			renderSceneDialog.update()
		)
		if (exrio3_drop.items[i]) == "Zip Compression per Scanline Band (ZIP)" then (
			setUserProp currentcam "exrio3" 3
			fopenexr.SetCompression 3
			debugger.text = "Changed .exr Compression to ZIP"
			renderSceneDialog.update()
		)
		if (exrio3_drop.items[i]) == "Piz-based Wavelet Compression (PIZ)" then (
			setUserProp currentcam "exrio3" 4
			fopenexr.SetCompression 4
			debugger.text = "Changed .exr Compression to PIZ"
			renderSceneDialog.update()
		)
		if (exrio3_drop.items[i]) == "Lossy 24bits Float Compression (PXR24)" then (
			setUserProp currentcam "exrio3" 5
			fopenexr.SetCompression 5
			debugger.text = "Changed .exr Compression to PXR24"
			renderSceneDialog.update()
		)
		if (exrio3_drop.items[i]) == "Lossy 4x4 Pixel Block Compression (fixed rate)(B44)" then (
			setUserProp currentcam "exrio3" 6
			fopenexr.SetCompression 6
			debugger.text = "Changed .exr Compression to B44"
			renderSceneDialog.update()
		)
		if (exrio3_drop.items[i]) == "Lossy 4x4 Pixel Block Compression (B44A)" then (
			setUserProp currentcam "exrio3" 7
			fopenexr.SetCompression 7
			debugger.text = "Changed .exr Compression to B44A"
			renderSceneDialog.update()
		)
)--End of Compression
on exrio4_drop selected i do (
		if (exrio4_drop.items[i]) == "Store Image as Scanlines" then (
			setUserProp currentcam "exrio4" 0
			fopenexr.setSaveScanline  true
		)
		if (exrio4_drop.items[i]) == "Store Image as Tiles" then (
			setUserProp currentcam "exrio4" 1
			fopenexr.setSaveScanline  false
		)
)--End of Storage Type Setup
on exrio5_drop selected i do (
		if (exrio5_drop.items[i]) == "Save Full Image" then (
			setUserProp currentcam "exrio5" 0
			fopenexr.setSaveRegion  false
		)
		if (exrio5_drop.items[i]) == "Save Region" then (
			setUserProp currentcam "exrio5" 1
			fopenexr.setSaveRegion  true
		)
)--End of Region Setup
on customext_props entered new_props do(
		setuserprop currentcam "RExt2" new_props
		rendoutputfilename = ((getFilenamePath rendoutputfilename) + (getuserprop currentcam "RName" as string)+(getuserprop currentcam "RExt2" as string))
)--End of Custom Extension

/* --CAMERA NAME  ////////////////////////////////////////////////////////////////////////////////// */
on name_props entered new_names do (
		basefile = (getFilenamePath rendoutputfilename)
		setUserProp currentcam "RName" new_names as string
		rendoutputfilename = ((getFilenamePath rendoutputfilename) + (getuserprop currentcam "RName" as string)+(getuserprop currentcam "RExt" as string))
		debugger.text = ("Output renamed to " + (new_names as string)+".")
		renderSceneDialog.update()
		--print "eureka!!"
		--camlist()
)

/* --ENVIRONMENT ///////////////////////////////////////////////////////////////////////////////////////// */	

on renv_map picked texmap do (
	
	environmentmap = texmap
	
	if classof environmentmap == Bitmaptexture then (
		rbitmap_vis()
		rbitmap_on()
		coronaoutput_inv()
		renv_box.height = 96
		rsun_layout()
		rfile_layout()
		jpgio_layout()
		pngio_layout()
		exrio_layout()
		customio_layout()
		rrend_layout()
		credits_layout()
		managerheight()
		setuserprop currentcam "REnv" environmentmap
		setuserprop currentcam "REnvClass" (classof environmentmap)
		setuserprop currentcam "RBitmap2" environmentmap.output.output_amount
		bitmap1_spinner.value = environmentmap.output.output_amount			
		if environmentmap.filename == undefined then (
			setuserprop currentcam "RBitmap1" ""
			renv_map.text = "None"
		)			
		if environmentmap.filename != undefined then (
			setuserprop currentcam "RBitmap1" environmentmap.filename
			renv_map.text = ((getFilenameFile environmentmap.filename) + (getFilenameType environmentmap.filename))
		)
	)	
	if classof environmentmap == CoronaOutput or classof environmentmap == CoronaColorCorrect then (
		rbitmap_vis()
		coronaoutput_vis()
		coronaoutput_on()
		renv_box.height = 220
		rsun_layout()
		rfile_layout()
		jpgio_layout()
		pngio_layout()
		exrio_layout()
		customio_layout()
		rrend_layout()
		credits_layout()
		managerheight()
		setuserprop currentcam "REnv" environmentmap
		setuserprop currentcam "REnvClass" (classof environmentmap)	
		setuserprop currentcam "CoronaOutput2" environmentmap.brightness
		coronaoutput2_spinner.value = environmentmap.brightness
		setuserprop currentcam "CoronaOutput3" environmentmap.saturation
		coronaoutput3_spinner.value = environmentmap.saturation
		setuserprop currentcam "CoronaOutput4" environmentmap.contrast
		coronaoutput4_spinner.value = environmentmap.contrast
		setuserprop currentcam "CoronaOutput5" environmentmap.gamma
		coronaoutput5_spinner.value = environmentmap.gamma
		setuserprop currentcam "CoronaOutput6" environmentmap.exposure
		coronaoutput6_spinner.value = environmentmap.exposure
		setuserprop currentcam "CoronaOutput7r" (environmentmap.tint.r as integer)
		setuserprop currentcam "CoronaOutput7g" (environmentmap.tint.g as integer)
		setuserprop currentcam "CoronaOutput7b" (environmentmap.tint.b as integer)
		coronaoutput7_pck.color = environmentmap.tint
		setuserprop currentcam "CoronaOutput8" environmentmap.affectedByColorMapping	
		if environmentmap.inputTexmap == undefined then (
			renv_map.text = "Corona Output"
			setuserprop currentcam "CoronaOutput1" ""
			coronaoutput1_name.text = "Undefined"
		)		
		if environmentmap.inputTexmap != undefined then (
			environmentmap.inputTexmap.coordinates.mappingtype = 1
			environmentmap.inputTexmap.coordinates.mapping = 0
			renv_map.text = ((getFilenameFile environmentmap.inputTexmap.filename) + (getFilenameType environmentmap.inputTexmap.filename))
			setuserprop currentcam "CoronaOutput1" environmentmap.inputTexmap.filename
			coronaoutput1_name.text = environmentmap.inputTexmap.filename
			setUserProp currentcam "RBitmap2" (environmentmap.inputTexmap.output.output_amount) 
			bitmap1_spinner.value = getUserProp currentcam "RBitmap2" 
		)
	)
	if classof environmentmap == Bitmaptexture then (
				paramWire.connect$CoronaSun001.rotation.controller[#Z_Rotation] environmentmap.coords[#U_Offset] "radTodeg Z_Rotation / 360.0"
			)
			if classof environmentmap == CoronaOutput then (
				paramWire.connect$CoronaSun001.rotation.controller[#Z_Rotation] environmentmap.inputTexmap.coords[#U_Offset] "radTodeg Z_Rotation / 360.0"
			)
			if classof environmentmap == CoronaColorCorrect then (
				paramWire.connect$CoronaSun001.rotation.controller[#Z_Rotation] environmentmap.inputTexmap.coords[#U_Offset] "radTodeg Z_Rotation / 360.0"
			)
			$CoronaSun001.rotation.z_rotation = (getuserprop currentcam "Sun") 
	
)

on bitmap1_spinner changed spinner_new do (
	if classof environmentmap == Bitmaptexture then (
		setUserProp currentcam "RBitmap2" bitmap1_spinner.value
		environmentmap.output.output_amount = (getuserprop currentcam "RBitmap2")
	)
	if classof environmentmap == CoronaOutput then (
		setUserProp currentcam "RBitmap2" bitmap1_spinner.value
		environmentmap.inputTexmap.output.output_amount = (getuserprop currentcam "RBitmap2")
	)
	if classof environmentmap == CoronaColorCorrect then (
		setUserProp currentcam "RBitmap2" bitmap1_spinner.value
		environmentmap.inputTexmap.output.output_amount = (getuserprop currentcam "RBitmap2")
	)
)

on coronaoutput2_spinner changed spinner_new do (
	setuserprop currentcam "CoronaOutput2" spinner_new
	environmentmap.brightness = spinner_new
)
on coronaoutput3_spinner changed spinner_new do (
	setuserprop currentcam "CoronaOutput3" spinner_new
	environmentmap.brightness = spinner_new
)
on coronaoutput4_spinner changed spinner_new do (
	setuserprop currentcam "CoronaOutput4" spinner_new
	environmentmap.contrast = spinner_new
)
on coronaoutput5_spinner changed spinner_new do (
	setuserprop currentcam "CoronaOutput5" spinner_new
	environmentmap.gamma = spinner_new
)
on coronaoutput6_spinner changed spinner_new do (
	setuserprop currentcam "CoronaOutput6" spinner_new
	environmentmap.exposure = spinner_new
)
on coronaoutput7_pck changed new_col do (
	setuserprop currentcam "CoronaOutput7r" (new_col.r as integer)
	setuserprop currentcam "CoronaOutput7g" (new_col.g as integer)
	setuserprop currentcam "CoronaOutput7b" (new_col.b as integer)
	environmentmap.tint = new_col
)
on coronaoutput8_chk changed ckeck do (
		if coronaoutput8_chk.checked == true then  (
			setUserProp currentcam "CoronaOutput8" true
			environmentmap.affectedByColorMapping = true
		)
		if coronaoutput8_chk.checked == false then	(
			setUserProp currentcam "CoronaOutput8" false
			environmentmap.affectedByColorMapping = false
		)	
)



	/* --DELETE PROPERTIES /////////////////////////////////////////////////////////////////////////// */
	on del_props pressed do (
			setUserPropBuffer currentcam ""
			cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string	
			debugger.text = "Cleared Properties of Camera Object " + (currentcam.name as string)
			select (getNodeByName cameralist.items[1])
	)

	/* --TIME OUTPUT ////////////////////////////////////////////////////////////////////////////////////////	 */	
	on rtime_drop selected i do (
			debugger.text = "Render Time set to " + (rtime_drop.items[i] as string)
			setUserProp currentcam "RTime" (rtime_drop.items[i])
			rarea_drop.items[i] = (getuserprop currentcam "RTime" as string)
			cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string
			renderSceneDialog.update()
				
			if (rtime_drop.items[i]) == "Single Frame" then (
				rendTimeType = 1	
				rtime_lbl.text = ("Frame " + ((currentTime as integer)/TicksPerFrame)as string)
				rtime_lbl.pos.x = (rtime_drop.pos.x+100)
				rtime_name.visible = false
				rstart_spinner.visible = false
				rstop_spinner.visible = false
				)	
			
			if (rtime_drop.items[i]) == "Active Time" then (
				rendTimeType = 2	
				rtime_lbl.text = ("Frames " + (animationRange.start as string) + " to" + (animationRange.end as string))
				rtime_lbl.pos.x = (rtime_drop.pos.x+100)
				rtime_name.visible = false
				rstart_spinner.visible = false
				rstop_spinner.visible = false
				)
			
			if (rtime_drop.items[i]) == "Custom Range" then (
				rendTimeType = 3	
				rtime_lbl.text = ("Frames " + (animationRange.start as string) + " to" + (animationRange.end as string))
				rtime_lbl.text = "From"
				rtime_lbl.pos.x = (rtime_drop.pos.x+100)
				rtime_name.visible = false
				rstart_spinner.visible = true
				rstop_spinner.visible = true
				)
			
			if (rtime_drop.items[i]) == "Specific" then (
				rendTimeType = 4	
				rtime_lbl.text = ("Frames " + (animationRange.start as string) + " to" + (animationRange.end as string))
				rtime_lbl.text = "Frames:"
				rtime_lbl.pos.x = (rtime_drop.pos.x+100)
				rtime_name.visible = true
				rstart_spinner.visible = false
				rstop_spinner.visible = false
				)
	)		
	on rtime_name entered rtime_new do (
			setUserProp currentcam "RFrames" rtime_new as string
			rendPickupFrames  = (getuserprop currentcam "RFrames")
			renderSceneDialog.update()
	)	

	/* -- CUSTOM RANGE/////////////////////////////////////////////////////////////////////////////////// */
	on rstart_spinner changed rstart_new do (
			setUserProp currentcam "RStart" rstart_spinner.value
			rendStart = getuserprop currentcam "RStart"as time
			debugger.text = "Changed Starting frame to " + ((getuserprop currentcam "RStart") as string)
			renderSceneDialog.update()
			
			if rstop_spinner.value < rstart_spinner.value then (
				rstop_spinner.value = rstart_spinner.value
				setUserProp currentcam "RStop" rstop_spinner.value
				rendEnd = getuserprop currentcam "RStop"as time
			)
	)	
	on rstop_spinner changed rstop_new do (
			setUserProp currentcam "RStop" rstop_spinner.value
			rendEnd = getuserprop currentcam "RStop"as time
			debugger.text = "Changed Stop frame to " + ((getuserprop currentcam "RStop") as string)
			renderSceneDialog.update()
			
			if rstop_spinner.value < rstart_spinner.value then (
				rstart_spinner.value = rstop_spinner.value
				setUserProp currentcam "RStart" rstart_spinner.value
				rendStart = getuserprop currentcam "RStart"as time
			)
	)	

	/* --OPEN CLOSE DEBUGGER //////////////////////////////////////////////////////////////////////// */
	on debug_button pressed do (

				CameraManager.width = (UI_colwidth*3+UI_yseam)
				debugger.text = "Debugger Opened"
				debug_button.visible = false			
				debug_button2.visible = true

	)

	on debug_button2 pressed do (

				debugging = 0
				CameraManager.width = (UI_colwidth*1)
				debugger.text = "Debugger Closed" 
				debug_button2.visible = false
				debug_button.visible = true
		
	)
	
	
	on update_button pressed do (
		persistent global pos1 = GetDialogPos CameraManager
		destroyDialog CameraManager
		fileIn ("Z:\06 Tests\Scripts\Camera Lister\CameraListerLatest.ms")
		messageBox ("Updated!")
	)

	on cam_props_drop selected i do (
		cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string
	)

	on cam_props entered i do (
		
		currentprop = cam_props_drop.selected as string
		setUserProp currentcam currentprop i
	)

	on show_props pressed do (
		
		actionMan.executeAction 0 "40472"
		print (getuserpropbuffer currentcam)	
	)




	/* --NETWORK RENDER  /////////////////////////////////////////////////////////////////////////////// */
	on render_button pressed do (
			macros.run "Render" "RenderButtonMenu_Submit_to_Network_Rendering"	
			setclipboardText (getuserprop currentcam "RName")
			--renderSceneDialog.update()	
	)



	/* -- SCRIPTS  /////////////////////////////////////////////////////////////////////////////// */
	on script_in entered  i do (		
		setUserProp currentcam "Script_In" i 
		clearlistener()
		lawl = getUserProp currentcam "Script_In"
		print lawl
		--execute i
	)

	on notes_in changed  i do (
		
		format i
		
		setUserProp currentcam "Notes_In" (i as string)
		--execute i
	)

	/* -- PROXY  /////////////////////////////////////////////////////////////////////////////// */

	on corona_prox1_btn pressed do (
		for o in objects where classOf o == CProxy do (
			if o.layer.on == false or o.ishidden == true then (
				setuserprop o "originalfile" (o.filename)
				o.filename = ""
			)
		)
	)


	on corona_prox2_btn pressed do (
		for o in objects where classOf o == CProxy do (
			if o.layer.on == true and o.filename == ("" as string) and o.ishidden == false then (
				o.filename = (getuserprop o "originalfile" as string)
			)
		)
	)
	
	/* -- UTILITIES  /////////////////////////////////////////////////////////////////////////////// */
	on getenv pressed do (
		
		try (
			fn camfilt o = (superClassOf o == camera)
			cama = pickObject rubberBand:currentcam.pos filter:camfilt
			envtable = #("Renv","REnvClass","RBitmap1","RBitmap2","CoronaOutput1","CoronaOutput2",
			"CoronaOutput3","CoronaOutput4","CoronaOutput5","CoronaOutput6","CoronaOutput7r",
			"CoronaOutput7g","CoronaOutput7b","CoronaOutput8")
			
			for item in envtable do (
				setuserprop currentcam item (getuserprop cama item)
				
				bitmap1_spinner.value = 0	
				renv_map.text = "updated"
				coronaoutput1_name.text = "updated"
				coronaoutput2_spinner.value = getuserprop currentcam "CoronaOutput2"
				coronaoutput3_spinner.value = getuserprop currentcam "CoronaOutput3"
				coronaoutput4_spinner.value = getuserprop currentcam "CoronaOutput4" 
				coronaoutput5_spinner.value = getuserprop currentcam "CoronaOutput5"
				coronaoutput6_spinner.value = getuserprop currentcam "CoronaOutput6"
				coronaoutput7_pck.color = (color (getuserprop currentcam "CoronaOutput7r" as integer) (getuserprop currentcam "CoronaOutput7g" as integer) (getuserprop currentcam "CoronaOutput7b" as integer)) 
				if getuserprop currentcam "CoronaOutput8" == true then (
					environmentmap.affectedByColorMapping = true
					coronaoutput8_chk.checked = true
				)
				if getuserprop currentcam "CoronaOutput8" == false then (
					environmentmap.affectedByColorMapping = false
					coronaoutput8_chk.checked = false
				)
			)

		)
		catch()
	)
	
	on tocoronacam pressed do (
		filein ("Z:\MaxScript\Projects\ArqRenderZ CameraLister\Utilities\\tocorona3cam.ms")
		--newcurrentcam.name = (currencam.name as string + "[Corona]") 
	)
	on tocoronacam2 pressed do (
		select newcurrentcam
		filein ("Z:\MaxScript\Projects\ArqRenderZ CameraLister\Utilities\\tocoronacam_anim_cam.ms")
	)
	on tocoronacam3 pressed do (
		select newcurrentcamtarget
		filein ("Z:\MaxScript\Projects\ArqRenderZ CameraLister\Utilities\\tocoronacam_anim_trgt.ms")
	)

	/* --CLOCK TICK ////////////////////////////////////////////////////////////////////////////////////////// */
	on clock tick do (	
		
		if $CoronaSun001 != undefined then (
			--print "corona sun defined"
			if $ == $CoronaSun001 then (
				setuserprop currentcam "Sun" $CoronaSun001.rotation.z_rotation
				sun_azimuth.value = $CoronaSun001.rotation.z_rotation
			)
		)
		
		if isvalidnode currentcam == false do (
			--print "currentcam is not valid node!"
			--print "DELETED!!!!"
			currentcam = $
			camlist = #()
			for o in cameras where superclassof o == camera do (
				c1 = o.name
				print c1
				append camlist c1
			)
			camlist = sort camlist 
			cameralist.items = camlist
			cameralist.selection = 1
			if cameras.count > 1 do (
				select (getNodeByName cameralist.items[1])
			)
		)
		
		if currentcam == undefined then (
				--print "currentcam is not defined!"
				currentcam = "lol"
				camlist = #()
				for o in cameras where superclassof o == camera do (
					c1 = o.name
					print c1
					append camlist c1
				)
			camlist = sort camlist 
			cameralist.items = camlist
			cameralist.selection = 1
			if cameras.count > 1 do (
				select (getNodeByName cameralist.items[1])
			)
		)
		
		if currentcam != undefined do (
			--print "currentcam is  defined "
			if isvalidnode currentcam == true do (
				--print "currentcam is  valid"
				if SuperClassOf currentcam != camera do (
					--Locks
					lockson = falsec
					--UI
					rcam_off ()
					rtime_off ()
					rarea_off ()
					rlay_off ()
					rsize_off ()
					renv_off ()
					rsun_off()
					rbitmap_off ()
					coronaoutput_off ()
					rfile_off ()
					--rrend_off ()
				)
				if currentcam.name != cam_name.text do (
					--print "currentcam's name doesn't coincide"
					--cameralist.items = for o in cameras where classof o != TargetObject collect o.name
					--cam_name.text = currentcam.name
				)
			)
		)
			
		if isvalidnode currentcam == true do (	
			if SuperClassOf currentcam == camera then (
					setRendImageAspect = (getuserprop currentcam "RAspect")
					activeview = viewport.activeViewport	
					--cam_props.text = (getUserProp currentcam (cam_props_drop.selected as string)) as string
				if rarea_pck.state == on then (
					if  (getuserprop currentcam "RArea" as string) == "Region" then (
							setuserprop currentcam "RCropX" ((((viewport.getRegionRect viewport.activeViewport).x)as float)/renderWidth)
							setuserprop currentcam "RCropY" ((((viewport.getRegionRect viewport.activeViewport).y)as float)/renderHeight)
							setuserprop currentcam "RCropW" ((((viewport.getRegionRect viewport.activeViewport).w)as float)/renderWidth)
							setuserprop currentcam "RCropH" ((((viewport.getRegionRect viewport.activeViewport).h)as float)/renderHeight)
					)
					if  (getuserprop currentcam "RArea" as string) == "Crop" then (
							setuserprop currentcam "RCropX" ((((viewport.getRegionRect viewport.activeViewport).x)as float)/renderWidth)
							setuserprop currentcam "RCropY" ((((viewport.getRegionRect viewport.activeViewport).y)as float)/renderHeight)
							setuserprop currentcam "RCropW" ((((viewport.getRegionRect viewport.activeViewport).w)as float)/renderWidth)
							setuserprop currentcam "RCropH" ((((viewport.getRegionRect viewport.activeViewport).h)as float)/renderHeight)
					)
					if  (getuserprop currentcam "RArea" as string) == "Blowup" then (
							setuserprop currentcam "RBlowX" ((((viewport.getBlowupRect viewport.activeViewport).x)as float)/renderWidth)
							setuserprop currentcam "RBlowY" ((((viewport.getBlowupRect viewport.activeViewport).y)as float)/renderHeight)
							setuserprop currentcam "RBlowW" ((((viewport.getBlowupRect viewport.activeViewport).w)as float)/renderWidth)
							setuserprop currentcam "RBlowH" ((((viewport.getBlowupRect viewport.activeViewport).h)as float)/renderHeight)
					)
				)
			)
		)
			
			--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			--CLOSE ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
		if keyboard.escPressed do (
			persistent global pos1 = GetDialogPos CameraManager
			destroyDialog CameraManager
		)
		
	)--End of clock tick

)--End of Rollout CameraManager



	
		--[ Dialogs]--!!	
	
	fn createdialogCameraManager = (
		if dontopendialog == false then (
			createdialog CameraManager width:(UI_colwidth*1 + UI_yseam/2 - UI_yseam/2 ) height:800 --style:#(#style_titlebar, #style_border, #style_sysmenu,#style_resizing,#style_maximizebox,#style_minimizebox) 
		)
	)
	
	
createdialogCameraManager()

)--[ End Dialog CameraManager ]--
)--End Script