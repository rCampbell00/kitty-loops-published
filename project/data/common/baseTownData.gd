extends Resource
class_name BaseTownData
#### DATA THAT IS NEEDED ####
### EXPLORATIONS
## Functions and value of exploration increase will be stored in the action itself
# Allows for overwriting the function if wanted (exponential or multiplicative?)
## Dictionary of explore progress
# Each needs a pair of values, current progress, exp towards next progress
# Needed to update values shown in text etc
var explore_progress := {}

### LOOTABLES
## Number of lootables available
# Total, number checked, current good, current used in the current loop
# Bool of if new are set to be checked or not
## Function to reset all of them (and visuals if main player) (Partly Stored in the action itself to handle checks)
var lootable_values := {}

###MULTIPART ACTIONS
## Current progress through current bars of action
## Number of complete bars you have cleared
## Multiplier(s) it gives
# Functions for calculating and resetting bars will be in the action itself
var multipart_values := {}

###LIMITED ACTIONS
## This will fit onto one of the tags for actions
#A count of how many of the action has been performed within the loop to check if allowed or not
var limited_action_count := {}

### GENERAL
# Town ID and Which world ID it is in
var town_number := 0
var world_number := 0
# Dictionary of every action in the town
var town_actions := {}
var lootable_actions := {}
var town_values := []
var town_segments := preload("res://data/multipart_data/townSegments.gd").new()
# Team members are "action_id": val" names will be gotten from story file
var town_team_members := {}
## Storage of stories unlocked for the actions of the town
# Store what actions have not completed as well for highlighting purposes later
var actions_completed := {}
# And stories not read that have been updated
var action_stories_not_read := {}
# And store what actions/explorations have been hidden
var explorations_hidden := {}
var actions_hidden := {}
## Data for stats if it isnt too much
# Data of how much you have done every action, how much mana spent on each action (?)
# How much of each resource gotten from each action?

var connected_player : PlayerData
var town_action : TownAction
var has_town_action := false
var capped_level := preload("res://data/common/level/cappedLevel.gd")
var multipart_data := preload("res://data/multipart_data/multipartData.gd")
var quality_data := preload("res://data/multipart_data/qualityData.gd")

#### FUNCTIONS NEEDED ####
# Function to call reset on every town variable (as needed)
#	This needs to reset info on each explore, limited, multipart, lootable
func reset() -> void:
	for lootable in self.lootable_values:
		self.lootable_values[lootable]["checked_good"] = 0
	for multipart in self.multipart_values:
		self.multipart_values[multipart].reset(connected_player)
	for limited in self.limited_action_count:
		self.limited_action_count[limited] = 0
	for val in range(len(self.town_values)):
		self.town_values[val] = 0
	self.town_segments.reset()
# Getter functions for data
func get_lootable_data(action_id: String) -> Dictionary:
	if action_id in self.lootable_values:
		return self.lootable_values[action_id]
	return {}

func update_lootable_total(action_id: String) -> void:
	var total = self.lootable_actions[action_id].calculate_total_lootables(self.connected_player)
	self.lootable_values[action_id]["total"] = total
	if connected_player.main_player:
		ViewHandler.request_update("town_lootable_collected", {action_id:true})

func change_check_new(lootable_id: String, value: bool) -> void:
	self.lootable_values[lootable_id]["check_new"] = value

func finish_lootable(action_id: String) -> bool:
	var lootable_data = self.lootable_values[action_id]
	
	# IF we are looking at new lootables first, or we have checked all good ones, and there are unchecked ones available
	if (lootable_data["check_new"] or lootable_data["good"] <= lootable_data["checked_good"]) and (lootable_data["total"] > lootable_data["checked"]):
		lootable_data["checked"] += 1
		if lootable_data["checked"] % self.town_actions[action_id].lootable_ratio == 0:
			lootable_data["good"] += 1
			lootable_data["checked_good"] += 1
			return true
		return false
	# If we have good ones remaining (and didnt choose to look at new ones first)
	if lootable_data["good"] > lootable_data["checked_good"]:
		lootable_data["checked_good"] += 1
		return true
	# If no good ones left, and no unchecked ones left
	return false

func get_explore_level(explore_id: String) -> int:
	return self.explore_progress[explore_id].get_level()

func get_explore_data(explore_id: String) -> Array:
	var explore : BaseLevel = self.explore_progress[explore_id]
	return [explore.get_level(), explore.get_exp(), explore.get_exp_needed()]

func get_explore_ids() -> Array:
	return self.explore_progress.keys()

func add_explore_exp(explore_id: String, experience: int) -> void:
	var did_level = self.explore_progress[explore_id].add_exp(experience, self.connected_player)
	if connected_player.main_player:
		EventBus.explore_increase(explore_id, connected_player, did_level)
	if did_level:
		for lootable in self.lootable_actions:
			self.update_lootable_total(self.lootable_actions[lootable].action_id)
		if connected_player.main_player:
			ViewHandler.request_update("update_town", {self.world_number*100+self.town_number: true})
	return

func get_multipart_loops_cleared(action_id: String) -> int:
	return self.multipart_values[action_id].loops_cleared
	
func get_multipart_segments_cleared(action_id: String) -> int:
	return self.multipart_values[action_id].segments_cleared
	
func get_multipart_data(action_id: String) -> MultipartData:
	return self.multipart_values[action_id]

func get_multipart_boost(action_id: String) -> float:
	return self.multipart_values[action_id].boost

func get_quality_boost(action_id: String) -> float:
	return self.multipart_values[action_id].quality_boost

func get_limited_count(action_id: String) -> int:
	if action_id in self.limited_action_count:
		return self.limited_action_count[action_id]
	return 0

func increment_limited(action_id: String) -> void:
	if action_id in self.limited_action_count:
		self.limited_action_count[action_id] += 1

func get_lootables_id() -> Array:
	return self.lootable_values.keys()

func get_multipart_ids() -> Array:
	return self.multipart_values.keys()

func add_team_member(action_id: String, combat_value: int) -> void:
	if not (action_id in self.town_team_members):
		self.town_team_members[action_id] = combat_value
	else:
		self.town_team_members[action_id] += combat_value

func remove_team_member(action_id: String) -> int:
	if not (action_id in self.town_team_members):
		return 0
	var combat_value = self.town_team_members[action_id]
	self.town_team_members.erase(action_id)
	return combat_value

func add_town_value(value_index: int, value: int) -> void:
	self.town_values[value_index] += value

func get_town_value(value_index: int) -> int:
	return self.town_values[value_index]

func add_town_segment_value(segment_index: int, value: int) -> void:
	self.town_segments.change_value(segment_index, value)

func get_town_segment_cleared(segment_index: int) -> bool:
	return self.town_segments.get_segment_cleared(segment_index)

func get_town_total_segments_cleared() -> int:
	return self.town_segments.get_total_cleared()

func get_town_segment_progress() -> Array[int]:
	return self.town_segments.segments_progress

## Construction function to create all of the variables and data for the list of zone/world actions
func setup_actions(actions: Array, world: int, town: int) -> void:
	self.world_number = world
	self.town_number = town
	for action in actions:
		self.town_actions[action.action_id] = action
		self.actions_completed[action.action_id] = false
		self.actions_hidden[action.action_id] = false
		self.action_stories_not_read[action.action_id] = false
		if "explore" in action.flags:
			self.explore_progress[action.action_id] = self.capped_level.new()
			self.explore_progress[action.action_id].setup_action(self.connected_player, action)
			self.explorations_hidden[action.action_id+"_explore"] = false
		if "limited" in action.flags:
			self.limited_action_count[action.action_id] = 0
		if action is LootableActionData:
			self.lootable_values[action.action_id] = {"check_new": true, "good": 0, "checked_good": 0, "total": 0, "checked": 0}
			self.lootable_actions[action.action_id] = action
			self.explorations_hidden[action.action_id+"_lootable"] = false
		if action is MultipartActionData:
			self.explorations_hidden[action.action_id+"_multipart"] = false
			if action is QualityActionData:
				self.multipart_values[action.action_id] = quality_data.new()
			else:
				self.multipart_values[action.action_id] = multipart_data.new()
			self.multipart_values[action.action_id].setup(action, self.connected_player)
	self.setup_town_action()

func setup_town_action() -> void:
	if not (self.town_number in Actions.town_actions[self.world_number]):
		return
	self.town_action = Actions.town_actions[self.world_number][self.town_number]
	self.has_town_action = true
	for i in range(self.town_action.town_values_count):
		self.town_values.append(0)
	self.town_segments.setup(self.town_action)


func get_action(action_id: String) -> BaseActionData:
	return self.town_actions[action_id]

func connect_player(new_player: PlayerData) -> void:
	self.connected_player = new_player
# Serialize/Deserialize function to take the needed town information and convert it into json for save/load
	# Totals  - #TODO
	#	Save each town which includes:
			#Explore progress (level, exp) of each explore
			#Lootable check_new, good, total, checked
			#Which actions have been completed
			#Which stories have not been read
			#Explorations which have been hidden
			#Actions which have been hidden
func get_save_dict() -> Dictionary:
	var save_dict := {}
	save_dict["explore_progress"] = {}
	for explore in self.explore_progress:
		save_dict["explore_progress"][explore] = self.explore_progress[explore].get_save_dict()
	save_dict["lootables"] = {}
	for lootable in self.lootable_values:
		var data : Dictionary = self.lootable_values[lootable]
		save_dict["lootables"][lootable] = {}
		save_dict["lootables"][lootable]["check_new"] = data["check_new"]
		save_dict["lootables"][lootable]["good"] = data["good"]
		save_dict["lootables"][lootable]["total"] = data["total"]
		save_dict["lootables"][lootable]["checked"] = data["checked"]
	save_dict["actions_completed"] = self.actions_completed
	save_dict["stories_unread"] = self.action_stories_not_read
	save_dict["explore_hidden"] = self.explorations_hidden
	save_dict["actions_hidden"] = self.actions_hidden
	return save_dict

func load_save_dict(save_dict: Dictionary) -> void:
	self.clear_data()
	if typeof(save_dict["explore_progress"]) == TYPE_DICTIONARY:
		for explore in self.explore_progress:
			if explore in save_dict["explore_progress"]:
				self.explore_progress[explore].load_save_dict(save_dict["explore_progress"][explore], self.connected_player)
	if typeof(save_dict["lootables"]) == TYPE_DICTIONARY:
		for lootable in self.lootable_values:
			if lootable in save_dict["lootables"]:
				var data : Dictionary = self.lootable_values[lootable]
				data["check_new"] = save_dict["lootables"][lootable]["check_new"]
				data["good"] = int(save_dict["lootables"][lootable]["good"])
				data["total"] = int(save_dict["lootables"][lootable]["total"])
				data["checked"] = int(save_dict["lootables"][lootable]["checked"])
	if typeof(save_dict["actions_completed"]) == TYPE_DICTIONARY:
		for action_id in self.actions_completed:
			if action_id in save_dict["actions_completed"]:
				self.actions_completed[action_id] = save_dict["actions_completed"][action_id]
	if typeof(save_dict["stories_unread"]) == TYPE_DICTIONARY:
		for action_id in self.action_stories_not_read:
			if action_id in save_dict["stories_unread"]:
				self.action_stories_not_read[action_id] = save_dict["stories_unread"][action_id]
	if typeof(save_dict["explore_hidden"]) == TYPE_DICTIONARY:
		for explore_id in self.explorations_hidden:
			if explore_id in save_dict["explore_hidden"]:
				self.explorations_hidden[explore_id] = save_dict["explore_hidden"][explore_id]
	if typeof(save_dict["actions_hidden"]) == TYPE_DICTIONARY:
		for action_id in self.actions_hidden:
			if action_id in save_dict["actions_hidden"]:
				self.actions_hidden[action_id] = save_dict["actions_hidden"][action_id]


func clear_data() -> void:
	for action_id in town_actions:
		self.actions_completed[action_id] = false
		self.actions_hidden[action_id] = false
		if "explore" in town_actions[action_id].flags:
			self.explore_progress[action_id].clear(self.connected_player)
			self.explorations_hidden[action_id+"_explore"] = false
		if town_actions[action_id] is LootableActionData:
			self.lootable_values[action_id] = {"check_new": true, "good": 0, "checked_good": 0, "total": 0, "checked": 0}
			self.explorations_hidden[action_id+"_lootable"] = false
		if town_actions[action_id] is MultipartActionData:
			self.explorations_hidden[action_id+"_multipart"] = false
	self.reset()
