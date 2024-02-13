extends ColorRect  # or whatever node type your object is

var time_passed = 0.0
var interval_seconds = .01

func _process(delta):
	time_passed += delta
	if time_passed > interval_seconds:
		time_passed = 0
		# set the shader param offset to be a random between two numbers
		material.set_shader_parameter("offset", Vector2(randf_range(0,1), randf_range(0,1)))
