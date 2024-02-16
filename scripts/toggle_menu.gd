# this script takes in an exported list of buttons and an exported list of menus, along with a universal back button, and a main menu
# by default the back button is hidden at the start
# when one of the buttons is clicked, the corresponding menu with the same name is set to visible, the main menu is hidden, the menu buttons are hidden, and the back button is visible
# when the back button is clicked, the menu is hidden, the menu buttons are visible, and the back button is hidden

extends Node

# export a list of node paths for the buttons
@export var buttons_container_path: NodePath
var buttons: Array[Button]

# export a list of node paths for the buttons
@export var menus_container_path: NodePath
var menus: Array[Control]

@export var animation_player_path: NodePath
var animation_player

# this is the current menu
@export var first_menu_name = ""
var current_menu_name = ""

func _ready():
	# get the menus
	var menus_container = get_node(menus_container_path)
	for child in menus_container.get_children():
		menus.append(child as Control)
	
	# get the buttons
	var buttons_container = get_node(buttons_container_path)
	for child in buttons_container.get_children():
		buttons.append(child as Button)
	
	# connect the buttons to each menu
	for button in buttons:
		var destination = _get_destination_name(button.name)
		for menu in menus:
			# if it corresponds to a menu, link the pressed method to the menu
			if destination == menu.name:
				button.pressed.connect(_on_button_pressed.bind(destination))
				break

	# hide everything
	for menu in menus:
		menu.hide()
	for button in buttons:
		button.hide()
	
	# set the current menu
	current_menu_name = first_menu_name
	animation_player = get_node(animation_player_path)
	# animation_player.play("transition")
	_refresh_current_menu()

func _get_menu_name(full_name: String) -> String:
	var split_name = full_name.split("-")
	return split_name[0]

func _get_destination_name(full_name: String) -> String:
	var split_name = full_name.split("-")
	return split_name[1]

func _refresh_current_menu():
	# hide all the buttons except the buttons for the first menu
	for button in buttons:
		if _get_menu_name(button.name) == current_menu_name:
			button.show()
		else:
			button.hide()

	# hide all the menus except the first one
	for menu in menus:
		if menu.name == current_menu_name:
			menu.show()
		else:
			menu.hide()

	# highlight the first visible button
	for b in buttons:
		if b.is_visible():
			b.grab_focus()
			break

func _on_button_pressed(destination_name: String):
	current_menu_name = destination_name
	animation_player.play("transition")
