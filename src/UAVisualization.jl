module UAVisualization
using GLVisualize, GeometryTypes, Colors
import GLVisualize: mm, Screen, labeled_slider, play_slider, center!
using Geodesy, MAT

export testscene, rgbaxis, loaddata

datafile = Pkg.dir("UAVisualization" * "/tools/data.mat")

function rgbaxis(scene, x, y, z)
	scale = 10
	origin = Point3f0(0, 0, 0)
	ptx = origin + Point3f0(scale, 0, 0)
	pty = origin + Point3f0(0, scale, 0)
	ptz = origin + Point3f0(0, 0, scale)
	for (pt, color) in ((ptx, :red), (pty, :green), (ptz, :blue))
		linesegment([origin, pt], color=color, linewidth=4)
	end
end

function loaddata()
	vars = matread(datafile)
	alt = vars["alt"]
	#@show length(alt)
	alt_nans = isnan(alt)
	alt = alt[.!alt_nans]
	#@show length(alt)
	t = vars["t"][.!alt_nans]
	lat = rad2deg(vars["lat"][.!alt_nans])
	lon = rad2deg(vars["lon"][.!alt_nans])
	lla = LLA.(lat, lon, alt)
	trans = ENUfromLLA(lla[1], wgs84)
	enu = trans.(lla)
	return t - t[1], enu
end

function testscene()
	window = glscreen("UAVisualization")

	t, enu = loaddata()
	# @show t
	# @show enu

	pos = i -> begin
		foo = Point3f0(enu[i]...)
	end

	iconsize = 8mm
	editarea, viewarea = x_partition_abs(window.area, round(Int, 8.2 * iconsize))
	edit_screen = Screen(window, area = editarea)
	view_screen = Screen(window, area = viewarea)
	#cubecamera(view_screen)

    time_viz, time_value = labeled_slider(1:1:length(t), edit_screen)

	play_viz, slider_value = play_slider(edit_screen, iconsize, 1:1:length(t))
	pos_animation = map(slider_value) do i
		#pos(Int(i))
		#Sphere{Float32}(Point3f0(0.0), 1f0)
		[pos(i)]
	end

	controls = Pair["play" => play_viz, "time" => time_viz]

	vehmarker = visualize((Sphere{Float32}(Point3f0(0.0), 1f0), pos_animation), color=RGBA(1f0,0f0,0f0,1f0))
	enutraj = visualize(Point3f0.(enu)[:], :lines, thickness=2f0, line=4.0)

	_view(vehmarker, view_screen, camera = :perspective)
	_view(visualize(controls, text_scale = 4mm, width = 8*iconsize), edit_screen, camera = :fixed_pixel)
	_view(enutraj, view_screen, camera = :perspective)

	center!(view_screen, :perspective)
	renderloop(window)
end

end # module
