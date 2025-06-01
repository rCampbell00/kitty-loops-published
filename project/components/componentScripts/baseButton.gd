extends Control
class_name ActionButton

@export var title: String
@export var image: Texture2D 
@export var bonus_image: Texture2D
@export var story_resource: BaseActionDesc
@export var action_resource: BaseActionData
var action_view_mode := true
var hidden_val := false
var toggle_mode := false
var tool_tip := preload("res://components/actionPopup.tscn")
var story_tip := preload("res://components/storyLabel.tscn")

func update_button_look() -> void:
	$Action/ActionName.text = title
	$Action/ActionImage.texture = image
	$Story/StoryImage.texture = image
	$Story/ActionName.text = title
	if bonus_image:
		$Action/ActionBonus.texture = bonus_image

#TODO Handle story data being added
func setup_action(action: BaseActionData) -> void:
	self.action_resource = action
	self.name = action.action_id
	self.image = Actions.action_images[action.action_id]
	self.story_resource = Actions.action_descs[action.action_id]
	self.story_resource.action_data = action
	self.title = self.story_resource.action_name
	if action.bonus_action_name != "":
		self.bonus_image = Actions.action_images[action.bonus_action_name]
	self.update_button_look()
	self.update_visibility()

func create_tool_tip() -> void:
	if has_node("ActionToolTip"):
		return
	var tool_tip_instance = tool_tip.instantiate()
	if story_resource:
		tool_tip_instance.update_flavour(story_resource.generate_flavour_text())
		tool_tip_instance.update_effect(story_resource.generate_effects_text())
		tool_tip_instance.update_stats(story_resource.generate_stats_text())
	add_child(tool_tip_instance)
	if has_node("ActionToolTip"):
		$ActionToolTip.show()

func free_tool_tip() -> void:
	if has_node("ActionToolTip"):
		$ActionToolTip.queue_free()

func town_switch(action_view: bool):
	self.action_view_mode = action_view
	if action_view:
		$Story.hide()
		$Action.show()
	else:
		$Action.hide()
		$Story.show()
	self.update_visibility()

func create_story_tool_tip() -> void:
	if has_node("StoryLabel"):
		if has_node("story_label_time_out"):
			$story_label_time_out.stop()
		return
	var story_tip_instance = story_tip.instantiate()
	if story_resource:
		story_tip_instance.set_story_text(story_resource.generate_story_text())
	add_child(story_tip_instance)
	story_tip_instance.mouse_in.connect(_story_hover)
	story_tip_instance.mouse_out.connect(free_story_tool_tip)
	if has_node("StoryLabel"):
		$StoryLabel.show()

func _story_hover() -> void:
	if has_node("story_label_time_out"):
		$story_label_time_out.stop()

func free_story_tool_tip() -> void:
	if has_node("StoryLabel"):
		$StoryLabel.queue_free()
	if has_node("story_label_time_out"):
		$story_label_time_out.queue_free()

func start_free_story_tool_tip() -> void:
	if has_node("story_label_time_out"):
		$story_label_time_out.start(0.2)
		return
	var timer := Timer.new()
	timer.one_shot = true
	timer.name = "story_label_time_out"
	timer.timeout.connect(free_story_tool_tip)
	self.add_child(timer)
	timer.start(0.2)

func update_visibility() -> void:
	$Action.disabled = not action_resource.get_unlocked(MainPlayer)
	visible = action_resource.get_visible(MainPlayer)
	if self.action_view_mode and hidden_val and (not self.toggle_mode):
		visible = false

func remove_highlight() -> void:
	$Action/Exclamation.hide()

func set_action_complete(action_complete: bool) -> void:
	$Action/Exclamation.visible = not action_complete

func add_story_highlight(all_stories: bool) -> void:
	$Story/Exclamation.show()
	if all_stories:
		$Story.theme_type_variation = "StoryPanelComplete"

func set_story_highlight(unread: bool, all_stories: bool) -> void:
	$Story/Exclamation.visible = unread
	if all_stories:
		$Story.theme_type_variation = "StoryPanelComplete"
	else:
		$Story.theme_type_variation = "StoryPanel"

func town_visible_toggle(toggle_bool: bool) -> void:
	self.toggle_mode = toggle_bool
	$Action/Eye.visible = toggle_bool
	if not toggle_bool:
		self.update_visibility()
		return
	if not action_resource.get_visible(MainPlayer):
		return
	visible = true
	$Action.modulate.a = 0.5 if self.hidden_val else 1.0

func _on_action_mouse_entered() -> void:
	create_tool_tip()

func _on_action_mouse_exited() -> void:
	free_tool_tip()

func _on_action_focus_entered() -> void:
	create_tool_tip()

func _on_action_focus_exited() -> void:
	free_tool_tip()

func _on_story_mouse_entered() -> void:
	$Story/Exclamation.hide()
	EventBus.story_viewed(self.name)
	create_story_tool_tip()

func _on_story_mouse_exited() -> void:
	start_free_story_tool_tip()

func _on_story_focus_entered() -> void:
	$Story/Exclamation.hide()
	EventBus.story_viewed(self.name)
	create_story_tool_tip()

func _on_story_focus_exited() -> void:
	start_free_story_tool_tip()

func update_status(hidden_status: bool, action_complete: bool, story_unread: bool, all_stories: bool) -> void:
	self.hidden_val = hidden_status
	$Action.modulate.a = 0.5 if self.hidden_val else 1.0
	$Action/Eye.set_pressed_no_signal(self.hidden_val)
	self.set_story_highlight(story_unread, all_stories)
	self.set_action_complete(action_complete)
	

func _on_eye_toggled(toggled_on: bool) -> void:
	self.hidden_val = toggled_on
	self.town_visible_toggle(self.toggle_mode)
