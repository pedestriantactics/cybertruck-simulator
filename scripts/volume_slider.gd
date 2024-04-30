extends HSlider

@onready var globals = $"/root/Globals"

# Called when the node enters the scene tree for the first time.
func _ready():
	min_value = 0
	max_value = 1
	step = 0.001
	value = globals.master_volume
	value_changed.connect(_on_value_changed)

func _on_value_changed(new_value: float) -> void:
	globals.master_volume = new_value
