module UAVisualization
using Makie, GLVisualize

export testscene

function testscene()
	scene = Scene(resolution = (500, 500))
	mesh(GLVisualize.loadasset("cat.obj"))
	r = linspace(-0.1, 1, 4)
	center!(scene)
	scene
end

# package code goes here

end # module
