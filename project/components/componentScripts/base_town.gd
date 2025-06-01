extends Panel
class_name BaseTown

var action_button := preload("res://components/actionButton.tscn")
var transition_button := preload("res://components/transition_action_button.tscn")
var explore_node := preload("res://components/exploreBar.tscn")
var lootable_node := preload("res://components/lootable.tscn")
var multipart_node := preload("res://components/multipart_town_bar.tscn")
var quality_node := preload("res://components/quality_town_bar.tscn")
var town_segment_node := preload("res://components/town_segment_display.tscn")
var world_index : int
var town_index : int
var group_index : String
var town_action_id : String
var town_data : BaseTownData

func _ready() -> void:
	self.position.x = 0
	self.position.y = 0

func setup_actions(actions: Array, world_number: int, town_number: int) -> void:
	self.name = str(town_number)
	self.world_index = world_number
	self.theme_type_variation = "panelTown"+str(town_number)
	self.town_index = town_number
	self.group_index = "_%d_%d" % [world_number, town_number]
	self.town_data = MainPlayer.get_town(world_number, town_number)
	self.town_data.setup_actions(actions, world_number, town_number)
	EventBus.add_town(self)
	if town_data.has_town_action and town_data.town_action.town_segments_count > 0:
		self.setup_town_action()
	for action in actions:
		if action is TransitionActionData:
			self.add_transition_action(action)
		else:
			self.add_action(action)
	self.update_all_visibility()

func setup_town_action() -> void:
	var new_town_segment = town_segment_node.instantiate()
	self.town_action_id = "town_action_%d_%d" % [self.town_data.world_number, self.town_data.town_number]
	new_town_segment.setup_action(self.town_data)
	new_town_segment.add_to_group("town_explores"+self.group_index)
	$TownExplorations/M/S/V.add_child(new_town_segment)

func add_transition_action(action: TransitionActionData):
	var new_transition_button = transition_button.instantiate()
	new_transition_button.setup_action(action)
	new_transition_button.add_to_group("town_actions"+self.group_index)
	$TransitionActions/M/S/H.add_child(new_transition_button)

func make_new_explore(action: BaseActionData) -> void:
	var new_explore = explore_node.instantiate()
	new_explore.setup_action(action)
	new_explore.add_to_group("town_explores"+self.group_index)
	$TownExplorations/M/S/V.add_child(new_explore)

func make_new_lootable(action: BaseActionData) -> void:
	var new_lootable = lootable_node.instantiate()
	new_lootable.setup_action(action)
	new_lootable.add_to_group("town_explores"+self.group_index)
	$TownExplorations/M/S/V.add_child(new_lootable)
	new_lootable.check_unexplored.connect(_update_looting)

func make_new_multipart(action: BaseActionData) -> void:
	var new_multipart : Control
	if action is QualityActionData:
		new_multipart = quality_node.instantiate()
	else:
		new_multipart = multipart_node.instantiate()
	new_multipart.setup_action(action, self.town_data)
	new_multipart.add_to_group("town_explores"+self.group_index)
	$TownExplorations/M/S/V.add_child(new_multipart)


func add_action(action: BaseActionData) -> void:
	var new_action_button = action_button.instantiate()
	new_action_button.setup_action(action)
	new_action_button.add_to_group("town_actions"+self.group_index)
	$TownActions/M/S/H.add_child(new_action_button)
	if "explore" in action.flags:
		self.make_new_explore(action)
	if action is LootableActionData:
		self.make_new_lootable(action)
	if action is MultipartActionData:
		self.make_new_multipart(action)


func update_all_visibility() -> void:
	get_tree().call_group("town_actions"+self.group_index, "update_visibility")
	get_tree().call_group("town_explores"+self.group_index, "update_visibility")
	

func swap_action_functionality(action_view: bool) -> void:
	get_tree().call_group("town_actions"+self.group_index, "town_switch", action_view)

func swap_explore_visibility_toggle(toggle_mode: bool) -> void:
	get_tree().call_group("town_explores"+self.group_index,"town_visible_toggle", toggle_mode)

func swap_buttons_visibility_toggle(toggle_mode: bool) -> void:
	get_tree().call_group("town_actions"+self.group_index,"town_visible_toggle", toggle_mode)

func remove_action_highlight(action_id: String) -> void:
	$TownActions/M/S/H.get_node(action_id).remove_highlight()

func add_story_highlight(action_id: String, all_stories: bool) -> void:
	$TownActions/M/S/H.get_node(action_id).add_story_highlight(all_stories)

func update_action(action_id: String) -> void:
	var action := self.town_data.get_action(action_id)
	if town_data.has_town_action and town_data.town_action.town_segments_count > 0:
		$TownExplorations/M/S/V.get_node(self.town_action_id).update_visibility()
	if action is TransitionActionData:
		$TransitionActions/M/S/H.get_node(action_id).update_visibility()
	else:
		$TownActions/M/S/H.get_node(action_id).update_visibility()
		if action is LootableActionData:
			$TownExplorations/M/S/V.get_node(action_id+"_lootable").update_visibility()
		if "explore" in action.flags:
			$TownExplorations/M/S/V.get_node(action_id+"_explore").update_visibility()
		if action is MultipartActionData:
			$TownExplorations/M/S/V.get_node(action_id+"_multipart").update_visibility()
			

func update_explore(explore_id: String) -> void:
	var explore_data := self.town_data.get_explore_data(explore_id)
	$TownExplorations/M/S/V.get_node(explore_id+"_explore").update_progess(explore_data[0], explore_data[1], explore_data[2])
	
func update_lootable(lootable_id: String) -> void:
	var lootable_data := self.town_data.get_lootable_data(lootable_id)
	var node := $TownExplorations/M/S/V.get_node(lootable_id+"_lootable")
	node.update_lootables(lootable_data["checked_good"],lootable_data["good"],lootable_data["total"],lootable_data["checked"])

func update_multipart(action_id: String) -> void:
	var node := $TownExplorations/M/S/V.get_node(action_id+"_multipart")
	var data := self.town_data.get_multipart_data(action_id)
	node.update_bar_progress(data.segmentsProgress)
	if data is QualityData:
		node.update_quality(data.quality_progress, data.quality_progress_needed)

func reset_multipart(action_id: String) -> void:
	var node := $TownExplorations/M/S/V.get_node(action_id+"_multipart")
	var data := self.town_data.get_multipart_data(action_id)
	node.reset_bar(data.segmentStats, data.segmentsProgress, data.segmentsMax)
	if data is QualityData:
		node.update_quality(data.quality_progress, data.quality_progress_needed)

func update_town_action() -> void:
	if town_data.has_town_action and town_data.town_action.town_segments_count > 0:
		$TownExplorations/M/S/V.get_node(town_action_id).update_progress(self.town_data.get_town_segment_progress())
	

func update_town() -> void:
	var loot_data := self.town_data.get_lootables_id()
	for loot_id in loot_data:
		self.update_lootable(loot_id)
	var explore_data := self.town_data.get_explore_ids()
	for explore_id in explore_data:
		self.update_explore(explore_id)
	var multipart_data := self.town_data.get_multipart_ids()
	for multipart_id in multipart_data:
		self.reset_multipart(multipart_id)
	self.update_all_visibility()

func update_hidden_explore(action_id: String, explore_type: String) -> void:
	var node := $TownExplorations/M/S/V.get_node(action_id+explore_type)
	node.update_hidden_status(self.town_data.explorations_hidden[action_id+explore_type])

func update_lootable_check(action_id: String) -> void:
	var node := $TownExplorations/M/S/V.get_node(action_id+"_lootable")
	node.update_check_new(self.town_data.lootable_values[action_id]["check_new"])

func update_hidden_completion_action(action_id: String) -> void:
	var action := self.town_data.get_action(action_id)
	var hidden_status : bool = self.town_data.actions_hidden[action_id]
	var action_complete_status : bool = self.town_data.actions_completed[action_id]
	var action_story_unread : bool = self.town_data.action_stories_not_read[action_id]
	var all_stories : bool = EventBus.get_all_stories_check(action_id)
	if action is TransitionActionData:
		$TransitionActions/M/S/H.get_node(action_id).update_status(hidden_status, action_complete_status, action_story_unread, all_stories)
	else:
		$TownActions/M/S/H.get_node(action_id).update_status(hidden_status, action_complete_status, action_story_unread, all_stories)

func reset_town_view() -> void:
	var loot_data := self.town_data.get_lootables_id()
	for loot_id in loot_data:
		self.update_lootable(loot_id)
		self.update_hidden_explore(loot_id, "_lootable")
		self.update_lootable_check(loot_id)
	var explore_data := self.town_data.get_explore_ids()
	for explore_id in explore_data:
		self.update_explore(explore_id)
		self.update_hidden_explore(explore_id, "_explore")
	var multipart_data := self.town_data.get_multipart_ids()
	for multipart_id in multipart_data:
		self.reset_multipart(multipart_id)
		self.update_hidden_explore(multipart_id, "_multipart")
	for action_id in self.town_data.town_actions:
		self.update_hidden_completion_action(action_id)
	self.update_all_visibility()

func _update_looting(lootable_id: String, state: bool) -> void:
	if state == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	self.town_data.change_check_new(lootable_id, state)
