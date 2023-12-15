extends MeshInstance3D

# This will store a list of meshinstances that will be exposed for setup in the editor
# On ready it will pick from a random instance and assign it to the MeshInstance3D which is a child
# It will also store a list of hex values for random colors
# On ready it will pick one of the random hex values and assign it as the albeto of the material

# This will be the list of meshinstances
@export var meshes: Array[Mesh] = []
# This will be the list of colors
@export var colors: Array[Color] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Pick a random mesh instance from the list
	if meshes.size() == 0:
		printerr("No mesh instances found")
		return
	var random_mesh = meshes[randi() % meshes.size()]
	# Assign the random mesh instance to the MeshInstance3D child
	mesh = random_mesh
	# Pick a random color from the list
	# if colors.size() == 0:
	# 	printerr("No colors found")
	# 	return
	# var random_color = colors[randi() % colors.size()]
	var hue = randf_range(0, 1)
	var saturation = 0.6
	var value = randf_range(0.5, 1)
	var random_color = Color.from_hsv(hue, saturation, value)

	# Assign the random color to the material
	# but make a copy of the material so that it isn't linked to the original
	var material = get_surface_override_material(0).duplicate()
	material.albedo_color = Color(random_color)
	set_surface_override_material(0, material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
