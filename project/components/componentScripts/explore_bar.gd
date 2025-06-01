extends Control
class_name ExploreBar

@export var explore_action_name: String = ""#Name of explore data in town
@export var explore_name: String = ""
#Data such as progress will all be stored in the town and delegated to the bar as needed
var tool_tip := preload("res://components/tool_tip.tscn")
var main_progress_val := 0
var sub_exp := 0
var sub_exp_need := 0
var hidden_val := false
var toggle_mode := false
var action : BaseActionData
var desc: BaseActionDesc

func update_name(new_explore_name: String) -> void:
	self.explore_name = new_explore_name
	$ExploreName.text = Utility.bb_bold(self.explore_name)

func update_progess(new_main: int, new_sub_exp: int, new_sub_exp_need: int) -> void:
	self.main_progress_val = new_main
	self.sub_exp = new_sub_exp
	self.sub_exp_need = new_sub_exp_need
	$ExplorePercent.text = str(main_progress_val)+"%"
	$MainProgress.value = main_progress_val
	$SubProgress.value = sub_exp
	$SubProgress.max_value = new_sub_exp_need

func setup_action(new_action: BaseActionData) -> void:
	self.action = new_action
	self.desc = Actions.action_descs[new_action.action_id]
	self.update_name(self.desc.explore_name)
	self.name = action.action_id+"_explore"
	self.update_progess(0, 0, action.calc_action_level_cost(MainPlayer, 0))

func create_tool_tip() -> void:
	if has_node("ToolTip"):
		return
	var tool_tip_instance = tool_tip.instantiate()
	var tool_tip_text : String = ("\n"+Utility.bb_bold(LanguageValues.explore_progress_text[0])+LanguageValues.explore_progress_text[1]) % main_progress_val
	if main_progress_val < 100:
		tool_tip_text += LanguageValues.explore_progress_text[2] % Utility.numbersToSuffix([sub_exp, sub_exp_need])
	tool_tip_text = self.desc.explore_desc+tool_tip_text
	tool_tip_instance.update_text(tool_tip_text)
	add_child(tool_tip_instance)
	if has_node("ToolTip"):
		$ToolTip.show()

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

func free_tool_tip() -> void:
	if has_node("ToolTip"):
		$ToolTip.queue_free()

func _on_mouse_entered() -> void:
	create_tool_tip()


func _on_mouse_exited() -> void:
	free_tool_tip()


func _on_focus_entered() -> void:
	create_tool_tip()
	
func _on_focus_exited() -> void:
	free_tool_tip()

func update_hidden_status(hidden_status: bool) -> void:
	self.hidden_val = hidden_status
	modulate.a = 0.5 if self.hidden_val else 1.0
	$Eye.set_pressed_no_signal(self.hidden_val)

func _on_eye_toggled(toggled_on: bool) -> void:
	self.hidden_val = toggled_on
	self.town_visible_toggle(self.toggle_mode)
	EventBus.update_explore_toggle(self.action.action_id, "_explore", toggled_on)
