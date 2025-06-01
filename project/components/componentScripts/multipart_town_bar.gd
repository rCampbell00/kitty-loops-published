extends Control
class_name MultipartTownBar

@export var multi_part_name := ""
var stat_bar := preload("res://components/multipart_bar_section.tscn")
var action : MultipartActionData
var desc : MultipartDesc
var multipart_data : MultipartData
var hidden_val := false
var toggle_mode := false

func update_name() -> void:
	var display_name := self.desc.get_multipart_name()
	$MultipartName.text = Utility.bb_bold(display_name)
	$MultipartTotal.text = "[right]%s[/right]" % Utility.bb_bold(self.desc.totals_name)
	$MultipartTotalValue.text = "%s" % Utility.numberToSuffix(0) #TODO implement when totals implemented

func update_bar_progress(new_progress: Array[int]) -> void:
	var children = $StatSegments.get_children()
	#Prevent calls if segment bars got reset on the same frame as update is requested
	if len(children) != len(new_progress):
		return
		
	for i in range(len(children)):
		children[i].update_progress(new_progress[i])
	self.update_name()

func setup_action(new_action: MultipartActionData, town: BaseTownData) -> void:
	self.action = new_action
	self.name = action.action_id+"_multipart"
	self.desc = Actions.action_descs[self.action.action_id]
	self.multipart_data = town.get_multipart_data(new_action.action_id)
	self.desc.multipart_data = self.multipart_data
	self.reset_bar(self.multipart_data.segmentStats, self.multipart_data.segmentsProgress, self.multipart_data.segmentsMax)
	self.update_name()

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

func reset_bar(new_stats: Array[String], new_progress: Array[int], new_max: Array[int]) -> void:
	self.delete_all_bar_segments()
	self.make_bar_segments(new_stats, new_progress, new_max)
	self.update_name()

func make_bar_segments(new_stats: Array[String], new_progress: Array[int], new_max: Array[int]) -> void:
	var flavour_array := self.desc.get_loop_segment_flavours()
	for i in range(min(len(new_stats),len(new_max),len(new_progress), len(flavour_array))):
		make_bar_segment(new_progress[i], new_max[i], new_stats[i], flavour_array[i])

func make_bar_segment(progress: int, max_val: int, stat: String, flavour: String) -> void:
	var new_stat_segment = stat_bar.instantiate()
	new_stat_segment.assign_values(progress, max_val, stat, flavour)
	$StatSegments.add_child(new_stat_segment)

func delete_all_bar_segments() -> void:
	for child in $StatSegments.get_children():
		child.queue_free()

func update_hidden_status(hidden_status: bool) -> void:
	self.hidden_val = hidden_status
	modulate.a = 0.5 if self.hidden_val else 1.0
	$Eye.set_pressed_no_signal(self.hidden_val)

func _on_eye_toggled(toggled_on: bool) -> void:
	self.hidden_val = toggled_on
	self.town_visible_toggle(self.toggle_mode)
	EventBus.update_explore_toggle(self.action.action_id, "_multipart", toggled_on)
