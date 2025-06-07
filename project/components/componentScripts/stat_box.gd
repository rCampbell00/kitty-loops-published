extends Panel
@export var stat_type := ""
var tool_tip := preload("res://components/tool_tip.tscn")

func _ready() -> void:
	$LevelBar.theme_type_variation = "Progress"+stat_type
	$StatName.text = LanguageValues.stat_to_string_name[stat_type]

func _process(_delta: float) -> void:
	var stat_data := MainPlayer.get_stat_data(stat_type)
	$LevelBar.max_value = stat_data["stat"].get_exp_needed()
	$LevelBar.value = stat_data["stat"].get_exp()
	$StatLevel.text = Utility.numberToSuffix(stat_data["stat"].get_level())
	$TalentBar.max_value = stat_data["talent"].get_exp_needed()
	$TalentBar.value = stat_data["talent"].get_exp()
	$TalentLevel.text = Utility.numberToSuffix(stat_data["talent"].get_level())

func create_tool_tip() -> void:
	if has_node("ToolTip"):
		return
	var tool_tip_instance = tool_tip.instantiate()
	var stat_percentage : float = 100*($LevelBar.value/$LevelBar.max_value)
	var stat_level_string := "%s/%s (%2.1f%%)" % [Utility.numberToSuffix($LevelBar.value), Utility.numberToSuffix($LevelBar.max_value), stat_percentage]
	var talent_percentage : float = 100*($TalentBar.value/$TalentBar.max_value)
	var talent_level_string := "%s/%s (%2.1f%%)" % [Utility.numberToSuffix($TalentBar.value), Utility.numberToSuffix($TalentBar.max_value), talent_percentage]
	var talent_boost := MainPlayer.get_talent_boost(self.stat_type)
	var talent_boost_text := ""
	if talent_boost > 100:
		talent_boost_text = "x"+Utility.numberToSuffix(floori(talent_boost))
	else:
		talent_boost_text = "x%.2f" % talent_boost
	var tool_tip_text := "\n".join([Utility.bb_bold(LanguageValues.stat_to_long_name[stat_type]),
								LanguageValues.stat_to_description[stat_type], 
								Utility.bb_bold(LanguageValues.stat_tool_tip_titles[0])+$StatLevel.text,
								Utility.bb_bold(LanguageValues.stat_tool_tip_titles[1])+stat_level_string,
								Utility.bb_bold(LanguageValues.stat_tool_tip_titles[2])+$TalentLevel.text,
								Utility.bb_bold(LanguageValues.stat_tool_tip_titles[3])+talent_level_string,
								Utility.bb_bold(LanguageValues.stat_tool_tip_titles[4])+talent_boost_text])
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
	free_tool_tip()


func _on_mouse_entered() -> void:
	self.create_tool_tip()


func _on_mouse_exited() -> void:
	free_tool_tip()
