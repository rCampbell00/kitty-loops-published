extends Control

var tool_tip := preload("res://components/tool_tip.tscn")

func _ready() -> void:
	$StatTitlePanel/StatTitle.text = LanguageValues.stat_name

func create_tool_tip() -> void:
	if has_node("ToolTip"):
		return
	var tool_tip_instance = tool_tip.instantiate()
	var tool_tip_text := LanguageValues.stat_main_tool_tip
	tool_tip_instance.update_text(tool_tip_text)
	add_child(tool_tip_instance)
	if has_node("ToolTip"):
		$ToolTip.show()

func free_tool_tip() -> void:
	if has_node("ToolTip"):
		$ToolTip.queue_free()

func _on_stat_title_panel_focus_entered() -> void:
	self.create_tool_tip()


func _on_stat_title_panel_focus_exited() -> void:
	self.free_tool_tip()


func _on_stat_title_panel_mouse_entered() -> void:
	self.create_tool_tip()


func _on_stat_title_panel_mouse_exited() -> void:
	self.free_tool_tip()
