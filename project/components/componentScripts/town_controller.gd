extends Control
var current_town = 1
var action_view_mode := true
var explore_toggle_mode := false
var action_button_toggle_mode := false
var world_index : int

var base_town := preload("res://components/base_town.tscn")

func setup_actions(actions: Dictionary, world_number: int) -> void:
	self.world_index = world_number
	for index in actions:
		var new_town := base_town.instantiate()
		new_town.add_to_group("towns"+str(world_index))
		$Towns.add_child(new_town)
		new_town.setup_actions(actions[index], self.world_index, index)
	self.reset_town_options()

func change_town(town_chose: int):
	current_town = town_chose
	get_tree().call_group("towns"+str(world_index), "hide")
	var town := $Towns.get_node(str(town_chose))
	town.show()
	var index = $Headers/TownHeader/TownOptions.get_item_index(town_chose)
	$Headers/TownHeader/TownOptions.select(index)
	hide_arrows()
	town.swap_action_functionality(action_view_mode)
	town.swap_explore_visibility_toggle(explore_toggle_mode)
	town.swap_buttons_visibility_toggle(action_button_toggle_mode)

func check_in_first_town() -> bool:
	return current_town == $Headers/TownHeader/TownOptions.get_item_id(0)

func check_in_last_town() -> bool:
	var last_index = $Headers/TownHeader/TownOptions.item_count - 1
	return current_town == $Headers/TownHeader/TownOptions.get_item_id(last_index)

func hide_arrows() -> void:
	$Headers/TownHeader/LeftArrow.show()
	$Headers/TownHeader/RightArrow.show()
	if $Headers/TownHeader/TownOptions.item_count == 1:
		$Headers/TownHeader/LeftArrow.hide()
		$Headers/TownHeader/RightArrow.hide()
		return
	if check_in_first_town():
		$Headers/TownHeader/LeftArrow.hide()
		return
	if check_in_last_town():
		$Headers/TownHeader/RightArrow.hide()
	

func _town_left() -> void:
	if not check_in_first_town():
		var index = $Headers/TownHeader/TownOptions.get_item_index(current_town)
		change_town($Headers/TownHeader/TownOptions.get_item_id(index-1))

func _town_right() -> void:
	if not check_in_last_town():
		var index = $Headers/TownHeader/TownOptions.get_item_index(current_town)
		change_town($Headers/TownHeader/TownOptions.get_item_id(index+1))

func _on_town_options_item_selected(index: int) -> void:
	change_town($Headers/TownHeader/TownOptions.get_item_id(index))

#Function for when a new town unlocks
func reset_town_options(town_index : int = 1) -> void:
	$Headers/TownHeader/TownOptions.clear()
	for town in MainPlayer.towns_unlocked[self.world_index]:
		$Headers/TownHeader/TownOptions.add_item(Utility.town_names[self.world_index][town], town)
	self.make_option_button_items_non_radio_checkable($Headers/TownHeader/TownOptions)
	self.hide_arrows()
	self.change_town(town_index)

func make_option_button_items_non_radio_checkable(option_button: OptionButton) -> void:
	var pm: PopupMenu = option_button.get_popup()
	for i in pm.get_item_count():
		if pm.is_item_radio_checkable(i):
			pm.set_item_as_radio_checkable(i, false)


func _open_actions() -> void:
	$Towns.get_node(str(current_town)).swap_action_functionality(true)
	$Headers/TownSubHeader/LeftArrow.hide()
	$Headers/TownSubHeader/RightArrow.show()
	$Headers/TownSubHeader/Stories.hide()
	$Headers/TownSubHeader/Options.show()
	action_view_mode = true


func _open_stories() -> void:
	$Towns.get_node(str(current_town)).swap_action_functionality(false)
	$Headers/TownSubHeader/LeftArrow.show()
	$Headers/TownSubHeader/RightArrow.hide()
	$Headers/TownSubHeader/Stories.show()
	$Headers/TownSubHeader/Options.hide()
	action_view_mode = false

func _on_header_eye_toggled(toggled_on: bool) -> void:
	self.explore_toggle_mode = toggled_on
	$Towns.get_node(str(current_town)).swap_explore_visibility_toggle(toggled_on)


func _on_sub_header_eye_toggled(toggled_on: bool) -> void:
	self.action_button_toggle_mode = toggled_on
	$Towns.get_node(str(current_town)).swap_buttons_visibility_toggle(toggled_on)

func reset_world_view() -> void:
	for town in $Towns.get_children():
		town.reset_town_view()
	self.reset_town_options()
	self._open_actions()
	
func reset_action_highlights() -> void:
	for town in $Towns.get_children():
		town.reset_action_highlights()
