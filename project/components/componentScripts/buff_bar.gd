extends Control

var buff_description : BuffDesc
var buff_cap : int
var current_cap : int
var tool_tip := preload("res://components/tool_tip.tscn")

func setup(new_buff_id: String) -> void:
	self.name = new_buff_id
	self.buff_description = Actions.buff_descriptions[new_buff_id]
	$BuffName.text = self.buff_description.get_bonus_name()
	$BuffImage.texture = Actions.action_images[Actions.buff_list[new_buff_id].action_id]
	var buff_data : BaseActionData = Actions.buff_list[new_buff_id]
	if buff_data is MultipartActionData:
		if "buffs" in buff_data.loop_reward and new_buff_id in buff_data.loop_reward["buffs"]:
			self.buff_cap = buff_data.loop_reward["buffs"][new_buff_id]["cap"]
		else:
			self.buff_cap = buff_data.completion_resources["buffs"][new_buff_id]["cap"]
	else:
		self.buff_cap = buff_data.completion_resources["buffs"][new_buff_id]["cap"]
	self.current_cap = self.buff_cap
	$BuffCap.text = str(self.buff_cap)

func update_values() -> void:
	var buff_level := MainPlayer.get_buff_level(self.name)
	$BuffLevel.text = Utility.numberToSuffix(buff_level)
	self.visible = buff_level != 0


func create_tool_tip() -> void:
	if has_node("ToolTip"):
		return
	var tool_tip_instance = tool_tip.instantiate()
	var tool_tip_text := "\n".join([buff_description.get_desc(),buff_description.get_boost_text()])
	tool_tip_instance.update_text(tool_tip_text)
	add_child(tool_tip_instance)
	if has_node("ToolTip"):
		$ToolTip.show()

func free_tool_tip() -> void:
	if has_node("ToolTip"):
		$ToolTip.queue_free()

func set_buff_cap(new_cap: int) -> void:
	self.current_cap = clampi(new_cap, 0, self.buff_cap)

func _on_buff_cap_text_changed(new_text: String) -> void:
	if new_text == "":
		self.current_cap = 0
		EventBus.change_bus_cap(self.name, self.current_cap)
	elif new_text.is_valid_int():
		self.current_cap = clampi(int(new_text), 0, self.buff_cap)
		$BuffCap.text = str(self.current_cap)
		$BuffCap.set_caret_column(len($BuffCap.text))
		EventBus.change_bus_cap(self.name, self.current_cap)
	else:
		$BuffCap.text = str(self.current_cap)
		$BuffCap.set_caret_column(len($BuffCap.text))


func _on_focus_entered() -> void:
	self.create_tool_tip()


func _on_focus_exited() -> void:
	self.free_tool_tip()


func _on_mouse_entered() -> void:
	self.create_tool_tip()


func _on_mouse_exited() -> void:
	self.free_tool_tip()
