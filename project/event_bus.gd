extends Node

# Main source of events will be passed to here for the main player
# For each event, the different listeners will be stored and respectively called
# This currently would include: Tutorials, view handler, story text unlocking, maybe totals?
## Skill_name: [Action_id,Action_id]
var skill_subscriptions := {}
var buff_subscriptions := {}
var boon_subscriptions := {}
var talent_subscriptions := {}

var terra_towns := {}
var celestial_towns := {}
var shadow_towns := {}
var town_index_to_node = [self.terra_towns, self.celestial_towns, self.shadow_towns]
var world_controller : Control
var story_handler := preload("res://story_handler.gd").new()
var save_handler := preload("res://save.gd").new()

func _init() -> void:
	for skill in Actions.skill_list:
		skill_subscriptions[skill] = []
	for buff in Actions.buff_list:
		buff_subscriptions[buff] = []
	for boon in Actions.boon_list:
		boon_subscriptions[boon] = []
	for talent in Utility.stat_types:
		talent_subscriptions[talent] = []
	self.setup_action_subscriptions()

func _ready() -> void:
	story_handler.setup_story_tracking()

func add_town(town: BaseTown) -> void:
	self.town_index_to_node[town.world_index][town.town_index] = town

func add_world_controller(controller: Control) -> void:
	self.world_controller = controller

func setup_action_subscriptions() -> void:
	for action in Actions.all_actions:
		for flag in Actions.all_actions[action].flags:
			if flag in self.skill_subscriptions:
				skill_subscriptions[flag].append(Actions.all_actions[action].action_id)
			elif flag in self.buff_subscriptions:
				buff_subscriptions[flag].append(Actions.all_actions[action].action_id)
			elif flag in self.boon_subscriptions:
				boon_subscriptions[flag].append(Actions.all_actions[action].action_id)
			elif flag in self.talent_subscriptions:
				talent_subscriptions[flag].append(Actions.all_actions[action].action_id)

func update_explore_toggle(action_id: String, explore_kind: String, toggle_val: bool) -> void:
	var world_town : Array = Actions.action_to_world_town[action_id]
	var town : BaseTownData = self.town_index_to_node[world_town[0]][world_town[1]].town_data
	town.explorations_hidden[action_id+explore_kind] = toggle_val

func update_action_toggle(action_id: String, toggle_val: bool) -> void:
	var world_town : Array = Actions.action_to_world_town[action_id]
	var town : BaseTownData = self.town_index_to_node[world_town[0]][world_town[1]].town_data
	town.actions_hidden[action_id] = toggle_val

func get_incomplete_stories(action_id: String) -> Array:
	return story_handler.get_incomplete_stories(action_id)

func get_all_stories_check(action_id: String) -> bool:
	return story_handler.check_all_stories_complete(action_id)

## Action ! system:
# Have a dictionary of actions completed or not
# All actions start in the dict as false (not completed)
# When an action is done, set it to complete
# If it wasn't complete before: request a call to view handler to remove it (event doesn't need this info)
#	View handler also checks town controller arrows to update ! for if there is an action in a town not seen (and town selector)
# Stories also need to be handled

#Might need more info later
func action_completed(action_id: String, player: PlayerData) -> void:
	if not player.main_player:
		return
	var world_town : Array = Actions.action_to_world_town[action_id]
	var town := player.get_town(world_town[0], world_town[1])
	var prev_complete_state : bool = town.actions_completed[action_id]
	if not prev_complete_state:
		town.actions_completed[action_id] = true
		ViewHandler.request_update("remove_alert", {action_id: true})
	self.story_handler.update_action_completion_stories(action_id)
	pass #TODO rest of the action complete code for tutorial

func action_failed(action_id: String, player:PlayerData) -> void:
	if not player.main_player:
		return
	self.story_handler.update_action_fail_stories(action_id)
	

func skill_increase(skill_id: String, player: PlayerData, did_level: bool)-> void:
	if not player.main_player:
		return
	if did_level:
		self.story_handler.update_skill_stories(skill_id)
	ViewHandler.request_update("skill_increase", {skill_id: did_level})

func buff_increase(buff_id: String, player: PlayerData, did_level: bool)-> void:
	if not player.main_player:
		return
	if did_level:
		self.story_handler.update_buff_stories(buff_id)
	ViewHandler.request_update("buff_increase", {buff_id: did_level})

func boon_increase(boon_id: String, player: PlayerData, did_level: bool)-> void:
	if not player.main_player:
		return
	if did_level:
		self.story_handler.update_boon_stories(boon_id)
	ViewHandler.request_update("boon_increase", {boon_id: did_level})

func talent_increase(talent_id: String, player: PlayerData, did_level: bool)-> void:
	if not player.main_player:
		return
	if did_level:
		self.story_handler.update_talent_stories(talent_id)

func explore_increase(explore_id: String, player: PlayerData, did_level: bool) -> void:
	if not player.main_player:
		return
	if did_level:
		self.story_handler.update_explore_action_stories(explore_id)
	ViewHandler.request_update("town_progress_increase", {explore_id: did_level})

func story_viewed(action_id: String) -> void:
	var town := MainPlayer.get_town_from_action(action_id)
	town.action_stories_not_read[action_id] = false

func lootable_checked(lootable_id: String, player: PlayerData) -> void:
	if not player.main_player:
		return
	self.story_handler.update_lootable_action_stories(lootable_id)
	ViewHandler.request_update("town_lootable_collected", {lootable_id: true})

func get_story_save_dict() -> Dictionary:
	return self.story_handler.get_save_dict()

func load_story_save_dict(save_dict: Dictionary) -> void:
	self.story_handler.load_save_dict(save_dict)

func save() -> void:
	save_handler.save_game()

func load_game() -> void:
	save_handler.load_game()
