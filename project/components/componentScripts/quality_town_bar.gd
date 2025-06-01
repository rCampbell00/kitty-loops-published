extends Control
var quality_flavour := ""
var action : MultipartActionData
var desc : QualityDesc
var tool_tip := preload("res://components/tool_tip.tscn")

var hidden_val := false
var toggle_mode := false

func update_name() -> void:
	self.get_child(1).update_name()

func update_bar_progress(new_progress: Array[int]) -> void:
	self.get_child(1).update_bar_progress(new_progress)

func setup_action(new_action: MultipartActionData, town: BaseTownData) -> void:
	self.name = new_action.action_id+"_multipart"
	self.action = new_action
	self.desc = Actions.action_descs[self.action.action_id]
	self.get_child(1).setup_action(new_action, town)

func update_visibility() -> void:
	if hidden_val and (not self.toggle_mode):
		visible = false
	else:
		visible = action.get_visible(MainPlayer)

func town_visible_toggle(toggle_bool: bool) -> void:
	self.toggle_mode = toggle_bool
	$Eye.visible = toggle_bool
	if not toggle_bool:
		self.update_visibility()
		return
	if not action.get_visible(MainPlayer):
		return
	visible = true
	modulate.a = 0.5 if self.hidden_val else 1.0

func reset_bar(new_stats: Array[String], new_progress: Array[int], 
			new_max: Array[int], new_flavour: Array[String],) -> void:
	self.get_child(1).reset_bar(new_stats, new_progress, new_max, new_flavour)

func update_quality(quality_prog: int, quality_max: int) -> void:
	$QualityBar.max_value = quality_max
	$QualityBar.value = quality_prog

func update_hidden_status(hidden_status: bool) -> void:
	self.hidden_val = hidden_status
	modulate.a = 0.5 if self.hidden_val else 1.0
	$Eye.set_pressed_no_signal(self.hidden_val)

func create_tool_tip() -> void:
	if has_node("ToolTip"):
		return
	var quality_effects := self.desc.get_quality_boost()
	var tool_tip_instance = tool_tip.instantiate()
	var tool_tip_text = self.desc.quality_text
	tool_tip_text += "\n%s %s" % [Utility.bb_bold(LanguageValues.quality_tooltip_text[0]),quality_effects[0]]
	tool_tip_text += "\n%s %s" % [Utility.bb_bold(LanguageValues.quality_tooltip_text[1]),quality_effects[1]]
	tool_tip_text += "\n%s" % Utility.bb_bold(LanguageValues.quality_tooltip_text[2])
	tool_tip_text += "%s / %s" % Utility.numbersToSuffix([floor($QualityBar.value), floor($QualityBar.max_value)])
	tool_tip_instance.update_text(tool_tip_text)
	add_child(tool_tip_instance)
	if has_node("ToolTip"):
		$ToolTip.show()

func free_tool_tip() -> void:
	if has_node("ToolTip"):
		$ToolTip.queue_free()


func _on_quality_bar_mouse_entered() -> void:
	create_tool_tip()


func _on_quality_bar_mouse_exited() -> void:
	free_tool_tip()


func _on_quality_bar_focus_entered() -> void:
	create_tool_tip()


func _on_quality_bar_focus_exited() -> void:
	free_tool_tip()


func _on_eye_toggled(toggled_on: bool) -> void:
	self.hidden_val = toggled_on
	self.town_visible_toggle(self.toggle_mode)
	EventBus.update_explore_toggle(self.action.action_id, "_multipart", toggled_on)
