extends ProgressBar
class_name TownSegment

var flavour_text := ""
var main_stat := ""

var tool_tip := preload("res://components/tool_tip.tscn")

func assign_values(maximum: int, stat: String, flavour: String) -> void:
	if stat in Utility.stat_types:
		self.theme_type_variation = "Progress"+stat
		self.main_stat = stat
	self.max_value = maximum
	self.value = 0
	self.flavour_text = flavour

func update_progress(progress: int) -> void:
	self.value = progress

func create_tool_tip() -> void:
	if has_node("ToolTip"):
		return
	var tool_tip_instance = tool_tip.instantiate()
	var tool_tip_text := "%s\n%s: " % [self.flavour_text, Utility.bb_bold("Progress")]
	tool_tip_text = tool_tip_text+"%s / %s" % Utility.numbersToSuffix([floor(self.value), floor(self.max_value)])
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
