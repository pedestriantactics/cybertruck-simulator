extends HSlider

@onready var globals = $"/root/Globals"
@onready var audio_player = $"./AudioStreamPlayer"

# random sound effects to choose from
var sounds: Array

var current_step: int

# Called when the node enters the scene tree for the first time.
func _ready():
	min_value = 0
	max_value = 1
	step = 0.1
	value = globals.master_volume
	current_step = int(value * 10)
	value_changed.connect(_on_value_changed)

	for i in range(1, 8):
		sounds.append(load("res://sounds/car-crash-" + str(i) + ".wav"))

func _on_value_changed(new_value: float) -> void:
	var next_step = int(new_value * 10)
	if next_step != current_step:
		current_step = next_step
		globals.master_volume = new_value
		
		# pick a random sound effect
		audio_player.stream = sounds[randi() % sounds.size()]
		audio_player.play()
