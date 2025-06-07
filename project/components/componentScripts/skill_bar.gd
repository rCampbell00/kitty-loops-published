extends Control

var skill_description : SkillDesc
var tool_tip := preload("res://components/tool_tip.tscn")

func setup(new_skill_id: String) -> void:
	self.name = new_skill_id
	self.skill_description = Actions.skill_descriptions[new_skill_id]
	$SkillLabel.text = self.skill_description.get_bonus_name()

func update_values() -> void:
	var skill_data := MainPlayer.get_skill_data(self.name)
	$SkillProgress.max_value = skill_data.exp_needed
	$SkillProgress.value = skill_data.experience
	$SkillLevel.text = Utility.numberToSuffix(skill_data.level)
	self.visible = skill_data.level != 0

func create_tool_tip() -> void:
	if has_node("ToolTip"):
		return
	var tool_tip_instance = tool_tip.instantiate()
	var tool_tip_text := "\n".join([skill_description.get_desc(),skill_description.get_boost_text(),Utility.bb_bold(LanguageValues.skill_level_text)])
	var percentage : float = 100*($SkillProgress.value / $SkillProgress.max_value)
	tool_tip_text += "%s / %s  (%2.1f%%)" % [Utility.numberToSuffix($SkillProgress.value), Utility.numberToSuffix($SkillProgress.max_value), percentage]
	tool_tip_instance.update_text(tool_tip_text)
	add_child(tool_tip_instance)
	if has_node("ToolTip"):
		$ToolTip.show()

func free_tool_tip() -> void:
	if has_node("ToolTip"):
		$ToolTip.queue_free()


func _on_mouse_entered() -> void:
	self.create_tool_tip()


func _on_mouse_exited() -> void:
	self.free_tool_tip()


func _on_focus_entered() -> void:
	self.create_tool_tip()


func _on_focus_exited() -> void:
	self.free_tool_tip()
