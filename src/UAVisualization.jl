module UAVisualization
using Makie, GLVisualize, GeometryTypes, Colors
using Geodesy, MAT

export testscene, rgbaxis

datafile = "/Users/pat/testdata-local/omega/staging/foo.mat"

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
	t = vars["t"]
	lat = vars["lat"]
	lon = vars["lon"]
	alt = vars["alt"]
	lla = LLA.(lat, lon, alt)
	trans = ENUfromLLA(lla[1], wgs84)
	enu = Point3f0.(trans.(lla))
	lines(enu[:], color=:blue, linewidth=2)
end

function testscene()
	scene = Scene(resolution = (500, 500))
	mesh(GLVisualize.loadasset("cat.obj"))
	r = linspace(-10, 10, 100)
	a = axis(scene, r, r)
	rgbaxis(scene, 0, 0, 0)
	loaddata()
	center!(scene)
	scene
end

# package code goes here

end # module
