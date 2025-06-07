extends Control

var boon_description : BoonDesc
var tool_tip := preload("res://components/tool_tip.tscn")

func setup(new_boon_id: String) -> void:
	self.name = new_boon_id
	self.boon_description = Actions.boon_descriptions[new_boon_id]
	$BoonName.text = self.boon_description.get_bonus_name()
	$BoonImage.texture = Actions.action_images[Actions.boon_list[new_boon_id].action_id]
	
func update_values() -> void:
	var boon_level := MainPlayer.get_boon_level(self.name)
	self.visible = boon_level != 0
	if boon_level > 1:
		$BoonName.text = self.boon_description.get_bonus_name() +" "+ (LanguageValues.boon_level_text % boon_level)


func create_tool_tip() -> void:
	if has_node("ToolTip"):
		return
	var tool_tip_instance = tool_tip.instantiate()
	var tool_tip_text := "\n".join([boon_description.get_desc(),boon_description.get_boost_text()])
	tool_tip_instance.update_text(tool_tip_text)
	add_child(tool_tip_instance)
	if has_node("ToolTip"):
		$ToolTip.show()

func free_tool_tip() -> void:
	if has_node("ToolTip"):
		$ToolTip.queue_free()


func _on_focus_entered() -> void:
	self.create_tool_tip()


func _on_focus_exited() -> void:
	self.free_tool_tip()


func _on_mouse_entered() -> void:
	self.create_tool_tip()


func _on_mouse_exited() -> void:
	self.free_tool_tip()
