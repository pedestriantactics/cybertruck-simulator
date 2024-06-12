extends Label

@export var goals_path: NodePath
@onready var goals_node = get_node(goals_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var children = goals_node.get_children()
	for child in children:
		if child.visible:
			text = child.name
			return
