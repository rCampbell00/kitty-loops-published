extends Control
class_name TownSegmentDisplay

var action : TownAction
var town_data: BaseTownData
var tool_tip := preload("res://components/tool_tip.tscn")
var segment_node := preload("res://components/town_segment.tscn")

func update_progress(new_progress: Array[int]) -> void:
	var children = $Segments.get_children()
	if len(children) != len(new_progress):
		return
	for i in range(len(children)):
		children[i].update_progress(new_progress[i])

func setup_action(town: BaseTownData) -> void:
	self.delete_all_bar_segments()
	self.action = town.town_action
	self.town_data = town
	var action_data := self.town_data.town_segments
	var index := "town_action_%d_%d" % [self.town_data.world_number, self.town_data.town_number]
	self.name = index
	for i in range(self.action.town_segments_count):
		self.make_bar_segment(action_data.segment_max[i], action_data.segment_stats[i], "")
	self.reset_bar()

func update_visibility() -> void:
	if self.action.visibility_action != "":
		visible = self.town_data.town_actions[self.action.visibility_action].get_visible(MainPlayer)

func reset_bar() -> void:
	for child in $Segments.get_children():
		child.update_progress(0)

func make_bar_segment(max_val: int, stat: String, flavour: String) -> void:
	var new_segment := segment_node.instantiate()
	new_segment.assign_values(max_val, stat, flavour)
	$Segments.add_child(new_segment)

func delete_all_bar_segments() -> void:
	for child in $Segments.get_children():
		child.free()

func create_tool_tip() -> void:
	if has_node("ToolTip"):
		return
	var tool_tip_instance = tool_tip.instantiate()
	#TODO use story file to update text
	tool_tip_instance.update_text("")
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
