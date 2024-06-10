extends Control

@onready var blackboard = get_node("/root/Blackboard")
@onready var no_data_label = get_node("no-data")
@onready var data_label = get_node("data")

@export var clear_confirm_button_path: NodePath
@onready var clear_confirm_button = get_node(clear_confirm_button_path)

@export var clear_button_path: NodePath
@onready var clear_button = get_node(clear_button_path)

# Called when the node enters the scene tree for the first time.
func _ready():

	# connect the clear button to the clear function
	clear_confirm_button.pressed.connect(_on_clear_confirm_button_pressed)

	if blackboard.saved_kvps.size() == 0:
		no_data_label.show()
		data_label.hide()
		clear_button.disabled = true
	
	no_data_label.hide()
	data_label.show()
	# clear_confirm_button.show()

	var title_labels = data_label.get_child(0).get_children()
	var value_labels = data_label.get_child(1).get_children()
	# check each label name in the blackboard.saved_kvps and set the value of the corresponding index in value labels
	if blackboard.saved_kvps.size() == 0:
		no_data_label.show()
		data_label.hide()
		return
	for i in title_labels.size():
		var title = title_labels[i].name
		if blackboard.saved_kvps.has(title):
			value_labels[i].text = str(round(blackboard.saved_kvps[title]))
		else:
			value_labels[i].set_text("0")

# # this is a weird workaround but whatever
# func _process(delta):
# 	if blackboard.saved_kvps.size() == 0:
# 		clear_button.hide()

func _on_clear_confirm_button_pressed():
	blackboard.clear_save()
	_ready()