extends Label

@export var goal_manager_node_path: NodePath
@onready var goal_manager_node = get_node(goal_manager_node_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_text = goal_manager_node.current_goal_text
	if new_text != text:
		text = new_text
