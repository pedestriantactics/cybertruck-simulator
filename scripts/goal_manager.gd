extends Node

# this will pull the current day from the blackboard save file and determine which set of current_day_goals to show
# the direct children of this node are the days available
# the children of the days are the current_day_goals for that day
# the name of each goal is the name of the goal node
# if all of the current_day_goals for the day are completed, the new day is saved to the blackboard

var current_day_goals = []
var current_goal_index = 0
var current_goal_area = null
# for possible reference by other scripts
var current_goal_text = ""

@export var checkpoint_audio_stream: AudioStream
@export var all_checkpoints_audio_stream: AudioStream

@onready var blackboard = get_node("/root/Blackboard")
@onready var audio_stream_player = get_child(0)

var completed_goal_timer = 0.0
var completed_goal_seconds = 5.0

func _ready():
	# turn off all the children
	for child in get_children():
		if child is Node and child.get_child_count() > 0:
			# turn off all the goals within the child
			for child_goal in child.get_children():
				child_goal.visible = false
			
	# get the day from the blackboard
	var day = 1
	if blackboard.saved_kvps.has("days_completed"):
		day = int(blackboard.saved_kvps["days_completed"]) + 1
	# show the current day
	var current_day_node = get_child(day)
	# if there is an actual day and you haven't completed all of them
	if (current_day_node) != null:
		blackboard.kvps["day_completed"] = 0
		# get the goals
		current_day_goals = current_day_node.get_children()
		# set the current goal text
		set_new_current_goal(current_goal_index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if completed_goal_timer > 0:
		completed_goal_timer -= delta
		if completed_goal_timer - delta <= 0:
			current_goal_text = ""
			set_process(false)
		return
	if current_goal_area == null:
		return
	# if there are no more goals left
	if !current_goal_area.visible:
		return
	# if there is nothing inside the goal
	if !current_goal_area.has_overlapping_bodies():
		return
	print("something is in the current goal")
	# at this point there's something inside the current goal
	for body in current_goal_area.get_overlapping_bodies():
		if body is VehicleBody3D:
			# play the sound
			audio_stream_player.stream = checkpoint_audio_stream
			audio_stream_player.play()
			current_goal_area.visible = false
			# check if it's the last goal, if not, complete it and set the next goal
			if current_goal_index < current_day_goals.size() - 1:
				set_new_current_goal(current_goal_index + 1)
			else:
				audio_stream_player.stream = all_checkpoints_audio_stream
				audio_stream_player.play()
				# save the new day to the blackboard
				blackboard.kvps["day_completed"] = 1
				current_goal_text = "All daily goals completed!"
				completed_goal_timer = completed_goal_seconds
			break

func set_new_current_goal(index):
	current_goal_index = index
	current_goal_text = current_day_goals[current_goal_index].name
	current_goal_area = current_day_goals[current_goal_index]
	current_goal_area.visible = true

