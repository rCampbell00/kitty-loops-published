extends Control
class_name LootableVisual
signal check_unexplored(name: String, state: bool)

var available := 0
var total_good := 0
var unexplored := 0
var explored := 0
var total := 0
var hidden_val := false
var toggle_mode := false
var explore_name := ""
var action : LootableActionData
var desc: LootableDesc
var tool_tip := preload("res://components/tool_tip.tscn")

func _ready() -> void:
	$CheckButton.text = LanguageValues.lootable_check_new_text

func update_name(new_explore_name: String) -> void:
	self.explore_name = new_explore_name
	$LootableName.text = Utility.bb_bold(self.explore_name)

#TODO setup the text from story data
func setup_action(new_action: LootableActionData) -> void:
	self.action = new_action
	self.desc = Actions.action_descs[self.action.action_id]
	self.update_name(self.desc.lootable_name)
	self.name = action.action_id+"_lootable"
	self.update_lootables(0, 0, 0, 0)

func update_lootables(checked_good: int, new_total_good: int, new_total: int, new_total_checked: int) -> void:
	self.available = new_total_good-checked_good
	self.total_good = new_total_good
	self.unexplored = new_total-new_total_checked
	self.explored = new_total_checked
	self.total = new_total
	var lootable_count_text := Utility.bb_bold(LanguageValues.lootable_resource_text[0])
	lootable_count_text += ("%s/%s" % Utility.numbersToSuffix([self.available, self.total_good]))
	$LootableCount.text = lootable_count_text
	var lootable_unchecked_text := Utility.bb_bold(LanguageValues.lootable_resource_text[1])
	lootable_unchecked_text += ("%s" % Utility.numberToSuffix(self.unexplored))
	$LootableUnchecked.text = lootable_unchecked_text

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

func create_tool_tip() -> void:
	if has_node("ToolTip"):
		return
	var tool_tip_instance = tool_tip.instantiate()
	var language_values := LanguageValues.lootable_tooltip_text
	var tool_tip_text := "%s %d\n%s %d\n%s %d\n%s %d\n%s %d\n" % [
		Utility.bb_bold(language_values[0]), self.available, Utility.bb_bold(language_values[1]), self.total_good,
		Utility.bb_bold(language_values[2]), self.total, Utility.bb_bold(language_values[3]), self.explored,
		Utility.bb_bold(language_values[4]), self.unexplored
	]
	tool_tip_instance.update_text(tool_tip_text)
	add_child(tool_tip_instance)
	if has_node("ToolTip"):
		$ToolTip.show()

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


func _on_check_button_toggled(toggled_on: bool) -> void:
	check_unexplored.emit(self.action.action_id, toggled_on)

func update_hidden_status(hidden_status: bool) -> void:
	self.hidden_val = hidden_status
	modulate.a = 0.5 if self.hidden_val else 1.0
	$Eye.set_pressed_no_signal(self.hidden_val)

func update_check_new(check_val: bool) -> void:
	$CheckButton.set_pressed_no_signal(check_val)

func _on_eye_toggled(toggled_on: bool) -> void:
	self.hidden_val = toggled_on
	self.town_visible_toggle(self.toggle_mode)
	EventBus.update_explore_toggle(self.action.action_id, "_lootable", toggled_on)
