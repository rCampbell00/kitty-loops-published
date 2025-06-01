extends Node
class_name PlayerData
### Data Needed ###
#Identifier of if this is the main player or a copy used for predictor
var main_player := true
# Dictionary of each worlds towns
var terra_towns := {}
var celestial_towns := {}
var shadow_towns := {}
# Array to store each world dictionary - use enum to index
var world_towns := [self.terra_towns, self.celestial_towns, self.shadow_towns]
# Dictionary of stats
#	Stat level, exp, exp to next, multiplier to action cost? - make it only calculate at new action if level increased?
#	Talent level, exp, exp to next, multiplier to exp gain
var stats := {}
# Dictionary of skills
#	Skill level, skill exp, exp needed for next level, effects?
var skills := {}
# Dictionary of buffs
var buffs := {}
# Dictionary of boons
var boons := {}
# Dictionary of current resources the player has
var resources := {}
var soul_stones := {"base": 0, "chunk": 0, "pristine": 0}
## Global buffs are effects that alter every action (if it can)
## Stored as {"resource/mana/skill_level": {"multiplier", "action count", "downside" {multiplier, count}}
#skill level is just for multipart actions that scale from skill level, mana is for base mana cost, resource is resource gain
var global_multipliers := {}
# Towns unlocked
#	array of arrays
var terra_towns_unlocked = [1]
var celestial_towns_unlocked = []
var shadow_towns_unlocked = []
var towns_unlocked := [self.terra_towns_unlocked, self.celestial_towns_unlocked, self.shadow_towns_unlocked]
var worlds_unlocked := [0]
var current_town := 1
var current_world := 0
var current_sub_town := 0
var current_team_member_combat := 0

var base_town = preload("res://data/common/baseTownData.gd")
var base_stat_level = preload("res://data/common/level/statLevel.gd")
var base_talent_level = preload("res://data/common/level/talentLevel.gd")
var base_boost_level = preload("res://data/common/level/boostLevel.gd")

func _init() -> void:
	for stat in Utility.stat_types:
		self.stats[stat] = {}
		self.stats[stat]["stat"] = base_stat_level.new()
		self.stats[stat]["stat"].set_stat(stat)
		self.stats[stat]["stat"].calc_next_exp(self)
		self.stats[stat]["talent"] = base_talent_level.new()
		self.stats[stat]["talent"].set_stat(stat)
		self.stats[stat]["talent"].calc_next_exp(self)
	for skill in Actions.skill_list:
		self.skills[skill] = base_boost_level.new()
		self.skills[skill].setup_action(self, Actions.skill_list[skill])
	for buff in Actions.buff_list:
		self.buffs[buff] = base_boost_level.new()
		self.buffs[buff].setup_action(self, Actions.buff_list[buff])
	for boon in Actions.boon_list:
		self.boons[boon] = base_boost_level.new()
		self.boons[boon].setup_action(self, Actions.boon_list[boon])
	for town in Utility.Terra_Towns:
		self.terra_towns[Utility.Terra_Towns[town]] = base_town.new()
		self.terra_towns[Utility.Terra_Towns[town]].connect_player(self)
	self.current_team_member_combat = 0
	self.global_multipliers = {}
	self.current_town = 1
	self.resources = {"mana": 250}

func reset_player() -> void:
	for stat in self.stats:
		self.stats[stat]["stat"].reset(self)
		self.stats[stat]["talent"].reset(self)
	for world in self.world_towns:
		for town in world:
			world[town].reset()
	self.current_team_member_combat = 0
	self.global_multipliers = {}
	self.current_town = 1
	self.resources = {"mana": 250}
	if self.main_player:
		var town_update := {}
		for world in range(len(self.world_towns)):
			for town in world_towns[world]:
				town_update[world*100+town] = true
		ViewHandler.request_update("update_town", town_update)


func stat_exp_mult(stat_name: String) -> float:
	return 1.0
func talent_exp_mult(stat_name: String) -> float:
	return 0.01

func add_stat_exp(stat_name: String, exp_gained: int) -> void:
	var stat_data : Dictionary = self.stats[stat_name]
	stat_data["stat"].add_exp(floor(exp_gained * self.stat_exp_mult(stat_name)), self)
	stat_data["talent"].add_exp(floor(exp_gained * self.talent_exp_mult(stat_name)), self)


#Take into account multipliers from buffs/talent - check exp_needed, recalc boost and add to talent
func add_exp(exp_gained: Dictionary) -> void:
	for stat in exp_gained:
		self.add_stat_exp(stat, exp_gained[stat])

func check_skill_level(skill: String, level: int) -> bool:
	return self.skills[skill].get_level() >= level

func check_buff_level(buff: String, level: int) -> bool:
	return self.buffs[buff].get_level() >= level

func check_boon_level(boon: String, level: int) -> bool:
	return self.boons[boon].get_level() >= level

func check_town_progress(explore_id: String, level: int) -> bool:
	return get_town_from_action(explore_id).get_explore_level(explore_id) >= level

func check_resource(resource: String, count: int) -> bool:
	if resource not in self.resources:
		return false

	return self.resources[resource] >= count

func check_town(town_num: int, sub_town_num: int, world_num: int) -> bool:
	# Split for readability
	if world_num != self.current_world:
		return false
	if town_num != self.current_town and town_num != 0:
		return false
	if sub_town_num != -1 and sub_town_num != self.current_sub_town:
		return false
	return true

func get_town_from_action(action_id: String) -> BaseTownData:
	var world_data : Array = Actions.action_to_world_town[action_id]
	return self.world_towns[world_data[0]][world_data[1]]
	

# Requires number of resources to exist
func remove_resource(resource: String, amount: int) -> void:
	if resource not in self.resources:
		return
	self.resources[resource] = self.resources[resource]-amount

func add_resource(resource: String, base_amount: int) -> void:
	var mult : float = self.global_multipliers["resource"]["multiplier"] if "resource" in self.global_multipliers else 1
	var amount = floor(base_amount*mult)
	if resource not in self.resources:
		self.resources[resource] = amount
	else:
		self.resources[resource] += amount

func calc_skill_effects(skill: String) -> void:
	if skill not in self.skills:
		return
	
	self.skills[skill].calc_boosts(self)

func calc_buff_effects(buff: String) -> void:
	if buff not in self.buffs:
		return
	
	self.buffs[buff].calc_boosts(self)

func calc_boon_effects(boon: String) -> void:
	if boon not in self.boons:
		return
	
	self.boons[boon].calc_boosts(self)

func add_skill(skill: String, xp_amount: int) -> void:
	if skill not in self.skills:
		return
	var did_level : bool = self.skills[skill].add_exp(xp_amount, self)
	if self.main_player:
		EventBus.skill_increase(skill, self, did_level)
	if did_level and skill in Actions.skill_to_lootable_flags:
		for action in Actions.skill_to_lootable_flags[skill]:
			self.world_towns[action.world_num][action.town_num].update_lootable_total(action.action_id)

func add_buff(buff: String, amount: int) -> void:
	if buff not in self.buffs:
		return
	var did_level : bool = self.buffs[buff].add_exp(amount, self)
	if self.main_player:
		EventBus.buff_increase(buff, self, did_level)
	if did_level and buff in Actions.buff_to_lootable_flags:
		for action in Actions.buff_to_lootable_flags[buff]:
			self.world_towns[action.world_num][action.town_num].update_lootable_total(action.action_id)

func add_boon(boon: String, amount: int) -> void:
	if boon not in self.boons:
		return
	var did_level : bool = self.boons[boon].add_exp(amount, self)
	if self.main_player:
		EventBus.boon_increase(boon, self, did_level)
	if did_level and boon in Actions.boon_to_lootable_flags:
		for action in Actions.boon_to_lootable_flags[boon]:
			self.world_towns[action.world_num][action.town_num].update_lootable_total(action.action_id)

func add_team_member(action_id: String, combat_value: int) -> void:
	self.current_team_member_combat += combat_value
	self.get_town_from_action(action_id).add_team_member(action_id, combat_value)
	if self.main_player:
		ViewHandler.request_update("update_team_members", {action_id: true})

func remove_team_member(action_id: String) -> void:
	var combat_value = self.get_town_from_action(action_id).remove_team_member(action_id)
	self.current_team_member_combat -= combat_value
	if self.main_player:
		ViewHandler.request_update("update_team_members", {action_id: false})

func add_town_progress(progress_id: String, xp_amount: int) -> void:
	self.get_town_from_action(progress_id).add_explore_exp(progress_id, xp_amount)

func add_soul_stone(type: String, amount: int) -> void:
	if type in self.soul_stones:
		self.soul_stones[type] += amount

func remove_soul_stone(type: String, amount: int) -> void:
	if type in self.soul_stones:
		self.soul_stones[type] -= amount

func add_global_multiplier(mult_name: String, multiplier: float, duration: int, 
							downside_mult: float = 0, downside_duration: int = 0) -> void:
	self.global_multipliers[mult_name] = {"multiplier": multiplier, "duration": duration}
	if downside_duration != 0:
		self.global_multipliers[mult_name]["downside"] = {"multiplier": downside_mult, "duration": downside_duration}

#TODO include these as a form of "resource" for visual info?
func decrement_globals() -> void:
	for mult in self.global_multipliers.keys():
		if self.global_multipliers[mult]["duration"] == 1:
			if "downside" in self.global_multipliers[mult]:
				self.global_multipliers[mult] = self.global_multipliers[mult]["downside"]
			else:
				self.global_multipliers.erase(mult)
		else:
			self.global_multipliers[mult]["duration"] -= 1

func get_stat_level(stat: String) -> int:
	return self.stats[stat]["stat"].get_level()

func get_talent_level(stat: String) -> int:
	return self.stats[stat]["talent"].get_level()

func get_town_progress(progress_id: String) -> int:
	return get_town_from_action(progress_id).get_explore_level(progress_id)

func get_skill_level(skill: String) -> int:
	if skill == "self_combat":
		return Actions.get_self_combat(self)
	if skill == "team_combat":
		return Actions.get_team_combat(self)
	return self.skills[skill].get_level()

func get_total_team_value() -> int:
	return self.current_team_member_combat

func get_skill_modifier(skill: String, modifier_id: String) -> float:
	return self.skills[skill].get_modifier(modifier_id)
	
func get_boon_modifier(boon: String, modifier_id: String) -> float:
	return self.boons[boon].get_modifier(modifier_id)

func get_boon_level(boon: String) -> int:
	return self.boons[boon].get_level()

func get_buff_modifier(buff: String, modifier_id: String) -> float:
	return self.buffs[buff].get_modifier(modifier_id)
	
func get_buff_level(buff: String) -> int:
	return self.buffs[buff].get_level()
	
func get_resource_count(resource: String) -> int:
	if resource not in self.resources:
		return 0
	return self.resources[resource]

func get_global_multiplier(multiplier: String) -> float:
	if multiplier in self.global_multipliers:
		return self.global_multipliers[multiplier]["multiplier"]
	return 1

func get_multipart_boost(action_id: String) -> float:
	return get_town_from_action(action_id).get_multipart_boost(action_id)

func get_quality_boost(action_id: String) -> float:
	return get_town_from_action(action_id).get_quality_boost(action_id)

func get_multipart_loop_cleared(action_id: String) -> int:
	return get_town_from_action(action_id).get_multipart_loops(action_id)

func get_multipart_data(action_id: String) -> MultipartData:
	return get_town_from_action(action_id).get_multipart_data(action_id)

func check_soul_stone(type: String, count: int) -> bool:
	return self.soul_stones[type] >= count

func check_town_lootable(action_id: String) -> bool:
	var good_loot : bool = get_town_from_action(action_id).finish_lootable(action_id)
	if self.main_player:
		EventBus.lootable_checked(action_id, self)
	return good_loot

func get_lootable_data(action_id: String) -> Dictionary:
	return self.get_town_from_action(action_id).get_lootable_data(action_id)

func change_town(town_number: int, world_number: int) -> void:
	self.current_town = town_number
	self.current_world = world_number
	self.current_sub_town = 0
	if self.main_player and not (town_number in self.towns_unlocked[world_number]):
		self.towns_unlocked[world_number].append(town_number)
		self.towns_unlocked[world_number].sort()

		ViewHandler.request_update("update_town_visibility", {world_number: town_number})

func unlock_world(world_number: int) -> void:
	if world_number in self.worlds_unlocked:
		return
	self.worlds_unlocked.append(world_number)
	self.worlds_unlocked.sort()
	if self.main_player:
		ViewHandler.request_update("update_world_visibility", {world_number: true})

func change_sub_town(sub_town_number: int) -> void:
	self.current_sub_town = sub_town_number

func get_town(world_number: int, town_number: int) -> BaseTownData:
	return self.world_towns[world_number][town_number]

func add_town_value(value_index: int, value: int, town: int) -> void:
	self.world_towns[self.current_world][town].add_town_value(value_index, value)

func get_town_value(value_index: int, town_number: int) -> int:
	return self.world_towns[self.current_world][town_number].get_town_value(value_index)

func add_town_segment_value(segment_index: int, value: int) -> void:
	self.world_towns[self.current_world][self.current_town].add_town_segment_value(segment_index, value)
	if self.main_player: #Might want to move this to main loop to reduce calls
		ViewHandler.request_update("update_town_action", {self.current_world*100+self.current_town: true})

func get_town_segment_cleared(segment_index: int, town_number: int) -> bool:
	return self.world_towns[self.current_world][town_number].get_town_segment_cleared(segment_index)

func get_town_total_segments_cleared(town_number: int) -> int:
	return self.world_towns[self.current_world][town_number].get_town_total_segments_cleared()

func check_town_unlocked(world_number: int, town_number: int) -> bool:
	return town_number in self.towns_unlocked[world_number]

# Player talent
# Player skills, buffs, boons
# Soul stones
# Towns and worlds unlocked
# Celestial/Shadow info #TODO
#	Save each town:
func get_save_dict() -> Dictionary:
	var save_dict := {}
	save_dict["talents"] = {}
	for stat in self.stats:
		save_dict["talents"][stat] = self.stats[stat]["talent"].get_save_dict()
	save_dict["skills"] = {}
	for skill in self.skills:
		save_dict["skills"][skill] = self.skills[skill].get_save_dict()
	save_dict["buffs"] = {}
	for buff in self.buffs:
		save_dict["buffs"][buff] = self.buffs[buff].get_save_dict()
	save_dict["boons"] = {}
	for boon in self.boons:
		save_dict["boons"][boon] = self.boons[boon].get_save_dict()
	save_dict["soulstones"] = self.soul_stones
	save_dict["worlds_unlocked"] = self.worlds_unlocked
	save_dict["towns_unlocked"] = self.towns_unlocked
	save_dict["towns"] = {}
	save_dict["towns"]["terra_towns"] = {}
	save_dict["towns"]["celestial_towns"] = {}
	save_dict["towns"]["shadow_towns"] = {}
	for town in self.terra_towns:
		save_dict["towns"]["terra_towns"][town] = self.terra_towns[town].get_save_dict()
	for town in self.celestial_towns:
		save_dict["towns"]["celestial_towns"][town] = self.celestial_towns[town].get_save_dict()
	for town in self.shadow_towns:
		save_dict["towns"]["shadow_towns"][town] = self.shadow_towns[town].get_save_dict()
	return save_dict

func load_save_dict(save_dict: Dictionary) -> void:
	for stat in self.stats:
		self.stats[stat]["stat"].reset(self)
	for world in self.world_towns:
		for town in world:
			world[town].reset()
	self.current_team_member_combat = 0
	self.global_multipliers = {}
	self.current_town = 1
	self.resources = {"mana": 250}
	if typeof(save_dict["talents"]) == TYPE_DICTIONARY:
		for stat in self.stats:
			if stat in save_dict["talents"]:
				self.stats[stat]["talent"].load_save_dict(save_dict["talents"][stat], self)
			else:
				self.stats[stat]["talent"].clear(self)
	if typeof(save_dict["skills"]) == TYPE_DICTIONARY:
		for skill in self.skills:
			if skill in save_dict["skills"]:
				self.skills[skill].load_save_dict(save_dict["skills"][skill], self)
			else:
				self.skills[skill].clear(self)
	if typeof(save_dict["buffs"]) == TYPE_DICTIONARY:
		for buff in self.buffs:
			if buff in save_dict["buffs"]:
				self.buffs[buff].load_save_dict(save_dict["buffs"][buff], self)
			else:
				self.buffs[buff].clear(self)
	if typeof(save_dict["boons"]) == TYPE_DICTIONARY:
		for boon in self.boons:
			if boon in save_dict["boons"]:
				self.boons[boon].load_save_dict(save_dict["boons"][boon], self)
			else:
				self.boons[boon].clear(self)
	self.soul_stones = {"base": 0, "chunk": 0, "pristine": 0}
	if typeof(save_dict["soulstones"]) == TYPE_DICTIONARY:
		self.soul_stones["base"] = int(save_dict["soulstones"]["base"])
		self.soul_stones["chunk"] = int(save_dict["soulstones"]["chunk"])
		self.soul_stones["pristine"] = int(save_dict["soulstones"]["pristine"])
	self.worlds_unlocked = []
	if typeof(save_dict["worlds_unlocked"]) == TYPE_ARRAY:
		for world in save_dict["worlds_unlocked"]:
			self.worlds_unlocked.append(int(world))
	if typeof(save_dict["towns_unlocked"]) == TYPE_ARRAY and len(save_dict["towns_unlocked"]) == len(self.towns_unlocked):
		self.terra_towns_unlocked = []
		self.celestial_towns_unlocked = []
		self.shadow_towns_unlocked = []
		self.towns_unlocked = [self.terra_towns_unlocked,self.celestial_towns_unlocked,self.shadow_towns_unlocked]
		for town in save_dict["towns_unlocked"][0]:
			self.terra_towns_unlocked.append(int(town))
		for town in save_dict["towns_unlocked"][1]:
			self.celestial_towns_unlocked.append(int(town))
		for town in save_dict["towns_unlocked"][2]:
			self.shadow_towns_unlocked.append(int(town))
	if typeof(save_dict["towns"]) == TYPE_DICTIONARY:
		for town in self.terra_towns:
			if str(town) in save_dict["towns"]["terra_towns"]:
				self.terra_towns[town].load_save_dict(save_dict["towns"]["terra_towns"][str(town)])
			else:
				self.terra_towns[town].clear()
		for town in self.celestial_towns:
			if str(town) in save_dict["towns"]["celestial_towns"]:
				self.celestial_towns[town].load_save_dict(save_dict["towns"]["celestial_towns"][str(town)])
			else:
				self.celestial_towns[town].clear()
		for town in self.shadow_towns:
			if str(town) in save_dict["towns"]["shadow_towns"]:
				self.shadow_towns[town].load_save_dict(save_dict["towns"]["shadow_towns"][str(town)])
			else:
				self.shadow_towns[town].clear()
