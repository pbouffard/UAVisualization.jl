module UAVisualization
using GLVisualize, GeometryTypes, Colors
import GLVisualize: mm, Screen, labeled_slider, play_slider, center!, rotationmatrix_z
using Geodesy, MAT

export init, main

datafile = Pkg.dir("UAVisualization" * "/tools/data.mat")

function init()
	global window
	window = glscreen("UAVisualization")
	window
end

function rgbaxis(rot)
	scale = 10
	origin = Point3f0(0, 0, 0)
	ptx = origin + Point3f0(scale, 0, 0)
	pty = origin + Point3f0(0, scale, 0)
	ptz = origin + Point3f0(0, 0, scale)
	colors = RGBA{Float32}[
	RGBA{Float32}(1,0,0,1),
	RGBA{Float32}(1,0,0,1),
	
	RGBA{Float32}(0,1,0,1),
	RGBA{Float32}(0,1,0,1),
	
	RGBA{Float32}(0,0,1,1),
	RGBA{Float32}(0,0,1,1),
	]
	lines = [origin, ptx, origin, pty, origin, ptz]
	return visualize(lines, :linesegment, color=colors)
end

function loaddata()
	# TODO: if data file doesn't exist generate some fake data
	vars = matread(datafile)
	alt = vars["alt"]
	#@show length(alt)
	alt_nans = isnan.(alt)
	alt = alt[.!alt_nans]
	#@show length(alt)
	t = vars["t"][.!alt_nans]
	lat = rad2deg.(vars["lat"][.!alt_nans])
	lon = rad2deg.(vars["lon"][.!alt_nans])
	lla = LLA.(lat, lon, alt)
	trans = ENUfromLLA(lla[1], wgs84)
	hdg = vars["hdg"][.!alt_nans]
	enu = trans.(lla)
	return t - t[1], enu, hdg
end

function main()
	
	t, enu, hdg = loaddata()
	
	"Vehicle's position in ENU at a given index"
	function get_pos_enu(i)
		Point3f0(enu[i]...)
	end

	"Vehicle's rotatation at a given index"
	function get_rot(i)
		rotationmatrix_z(hdg[i])
	end

	
	iconsize = 8mm
	editarea, viewarea = x_partition_abs(window.area, round(Int, 8.2 * iconsize))
	edit_screen = Screen(window, area = editarea)
	view_screen = Screen(window, area = viewarea)
	#cubecamera(view_screen)
	
	time_viz, time_value = labeled_slider(1:1:length(t), edit_screen)
	
	# i_cur is the main Signal: Current index into data arrays using playback slider
	play_viz, i_cur = play_slider(edit_screen, iconsize, 1:1:length(t))
	
	cur_rot = map(get_rot, i_cur)
	curtime = map(i -> t[i], i_cur)
	curtime_s = map(t -> @sprintf("%.2f", t), curtime)
	pos_animation = map(i_cur) do i
		#pos(Int(i))
		#Sphere{Float32}(Point3f0(0.0), 1f0)
		[get_pos_enu(i)]
	end
	
	#mesh = loadasset(Pkg.dir("UAVisualization") * "/tools/Canopy_v2.STL")
	
	controls = Pair["playback" => play_viz, "time" => curtime_s]
	
	vehmarker = visualize((Sphere{Float32}(Point3f0(0.0), 1f0), pos_animation), color=RGBA(1f0,0f0,0f0,1f0))
	enutraj = visualize(Point3f0.(enu)[:], :lines, thickness=2f0, line=4.0)
	
	#_view(visualize(mesh), view_screen, camera = :perspective)
	_view(vehmarker, view_screen, camera = :perspective)
	_view(visualize(controls, text_scale = 4mm, width = 8*iconsize), edit_screen, camera = :fixed_pixel)
	_view(enutraj, view_screen, camera = :perspective)
	_view(rgbaxis(cur_rot), view_screen, camera = :perspective)
	
	push!(view_screen.cameras[:perspective].nearclip, 0.02f0)
	center!(view_screen, :perspective)
	renderloop(window)
end

end # module
