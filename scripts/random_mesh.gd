extends MeshInstance3D

# This will store a list of meshinstances that will be exposed for setup in the editor
# On ready it will pick from a random instance and assign it to the MeshInstance3D which is a child
# It will also store a list of hex values for random colors
# On ready it will pick one of the random hex values and assign it as the albeto of the material

# This will be the list of meshinstances
@export var meshes: Array[Mesh] = []
# This toggles the random color assignment
@export var random_color = false
# This will be the list of colors
@export var colors: Array[Color] = []
# This allows you to have the object randomly rotated at spawn
@export var random_rotate_degrees = 0
# This restricts the random rotation to increments of this value
@export var random_rotate_increment_degrees = 0
# This allows you to have the object randomly mirrored at spawn
@export var random_mirror = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Pick a random mesh instance from the list
	if meshes.size() > 0:
		var random_mesh = meshes[randi() % meshes.size()]
		# Assign the random mesh instance to the MeshInstance3D child
		mesh = random_mesh
	# Pick a random color from the list
	# if colors.size() == 0:
	# 	printerr("No colors found")
	# 	return
	if random_color:
		# var random_color = colors[randi() % colors.size()]
		var hue = randf_range(0, 1)
		var saturation = 0.6
		var value = randf_range(0.8, 1)
		var random_color = Color.from_hsv(hue, saturation, value)

		# check how many materials there are on the mesh so you can iterate through them and color each one
		var material_count = get_surface_override_material_count()
		print("material_count for "+ get_parent().name + ": " + str(material_count))
		# Assign the random color to the material
		for i in range(material_count):
			var material = get_surface_override_material(i).duplicate()
			material.albedo_color = Color(random_color)
			set_surface_override_material(i, material)

	# Randomly rotate the object
	if random_rotate_degrees > 0:
		var final_rotation = randf_range(0, random_rotate_degrees)
		if random_rotate_increment_degrees > 0:
			final_rotation = int(final_rotation / random_rotate_increment_degrees) * random_rotate_increment_degrees
			get_parent().rotate(Vector3(0, 1, 0),deg_to_rad(final_rotation))

	# Randomly mirror the object along the x and z axis
	if random_mirror:
		var random_mirror_x = randf_range(0, 1)
		var random_mirror_z = randf_range(0, 1)
		if random_mirror_x > 0.5:
			get_parent().scale.x = -1
		if random_mirror_z > 0.5:
			get_parent().scale.z = -1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
