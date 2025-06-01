extends Resource
class_name BaseActionData
#### DATA NEEDED ####
# Name and ID of action
var action_id := ""
# Town and realm it is part of
var town_num := 0
# 0 for terra, 1 for celestial, 2 for shadow (make an enum for this and town?)
var world_num := 0
# Sub-town information: is it part of the subtown, can it only be done outside of the subtown or both
#	0: Only in main zone, 1: Only in sub-zone 1 (2+ if we do more), -1: Can be done in and out of subtowns
var sub_town_status := 0
# Base EXP mult (and function to get that to be overridden if needed)
var experience_mult := 1
# Stat distribution of the action
var stat_dist := {}
# Total base mana cost of the action -- seperate from other items as can start actions without full mana needed
var base_mana_cost := 100
# Name of a main skill it relates to (if it has one) and the function code in data for its modifier
var main_skill := ""
# Name of a main buff it relates to (if it has one) and the function code in data for its modifier
var main_buff := ""
# Name of a main boon it relates to (if it has one) and the function code in data for its modifier
var main_boon := ""

# Dictionary of things that buff an action in some form and their base rate per item of it
## Format: {"resource_buffed": {"skills": [], "buffs": [], "boons": [], "town_progress":{}, "resources": {}, "multi_boost": [], "quality_boost": [], "custom": []}
## skills, buffs, boons are the list of names for the skill etc
## town_progress is form {"progress_name": multiplier}
## resource is form {"resource": multiplier}
var action_multipliers := {}
var action_additives := {}

var mult_functions := {
	"skills": self.calc_skill_mult,
	"buffs": self.calc_buff_mult,
	"boons": self.calc_boon_mult,
	"resources": self.calc_resource_mult,
	"multi_boost": self.calc_multi_boost_mult,
	"quality_boost": self.calc_quality_boost_mult,
	"custom_mult": self.calc_custom_mult
}
var add_functions := {
	"town_progress": self.calc_town_add
}
# Bonus image
var bonus_action_name := ""
# List of resources needed to start the action that are not spent - split into different catgories
## "skills": {}, "resources": {}, "buffs": {}, "boons": {}, "town_progress": {}, "extra_conditions": []
## Skills, resources, buffs, boons are form of {"name":count}
## town_progress is form {"progress_name": level_needed}
## Extra conditions is an array of function pointers that all take in player as a singular argument and return a bool
var required_items := {}
var visible_req := {}
var unlocked_req := {}
# Resources/Buffs/Town progress/etc that the action gives upon completion
## "skills": {}, "resources": {}, "buffs": {}, "boons": {}, "town_progress": {}, "skill_capped": {}, "team_member": [], "team_loss": id, "soul_stone"
## Skills, resources, town_progress are form of {"name":count}
## Buffs are "name": {"cap": max_level, "cap_func": custom cap (up to max, if not -1), "cost": {"soul_stone_type": amount}}
## Boons are "name": level
## skill_capped is {"name": {"cap_func": [], "cap": int, "exp": int}}
## sub_town is the sub-town number
## Soulstone is a {"type": count}
var completion_resources := {}
#buffs need a name, cap, cap_func, cost
var reward_functions := {
	"skills": self.add_skills,
	"resources": self.add_resources,
	"buffs": self.add_buffs,
	"boons": self.add_boons,
	"town_progress": self.add_town_progress,
	"skill_capped": self.add_skills_capped,
	"sub_town": self.change_sub_town,
	"team_member": self.add_team_member,
	"team_loss": self.remove_team_member,
	"town_variable": self.add_town_variable,
	"custom_rewards": self.add_custom_resources,
	"global_multiplier": self.add_global_multoplier,
	"soul_stone": self.add_soul_stones
}
# List of resources needed to finish the action (and therefore start) but are not removed until done (i.e. Soul stones)
var action_cost := {}
# Action limit - -1 is the default as allowed infinite
var action_limit := -1

var check_functions := {
	"skills": self.check_skill_levels,
	"boons": self.check_boon_levels,
	"buffs": self.check_buff_levels,
	"resources": self.check_resources,
	"extra_conditions": self.check_extra_condition,
	"town_progress": self.check_town_progress,
	"town_variable": self.check_town_variable
}
### FLAGS
var flags : Array[String] = []
# List of flags for the actions that can be used to generate identifiers for the actions
# Help with locating changes needed when a skill is unlocked or achievements need to be updated
## List of flags
# Limited action type
# Explore action - as certain other types can be explore actions
# team_members - flag to know which actions have team members (for story/resource identification)
# Skills/Boons used in the action - used to identify when actions should be unlocked/visible

#### FUNCTIONS NEEDED ####
# Visible, and unlocked check functions
func check_skill_levels(player: PlayerData, dict: Dictionary) -> bool:
	for skill in dict:
		if not player.check_skill_level(skill,dict[skill]):
			return false
	return true
	
func check_boon_levels(player: PlayerData, dict: Dictionary) -> bool:
	for boon in dict:
		if not player.check_buff_level(boon,dict[boon]):
			return false
	return true
	
func check_buff_levels(player: PlayerData, dict: Dictionary) -> bool:
	for buff in dict:
		if not player.check_boon_level(buff,dict[buff]):
			return false
	return true
	
func check_town_progress(player: PlayerData, dict: Dictionary) -> bool:
	for prog in dict:
		if not player.check_town_progress(prog, dict[prog]):
			return false
	return true

func check_town_variable(player: PlayerData, dict: Dictionary) -> bool:
	for town in dict:
		for variable in dict[town]:
			if player.get_town_value(variable["idx"], town) < variable["count"]:
				return false
	return true
	
func check_resources(player: PlayerData, dict: Dictionary) -> bool:
	for resource in dict:
		if not player.check_resource(resource, floor(dict[resource]*self.calculate_total_modifier(player, resource))):
			return false
	return true
	
func check_extra_condition(player: PlayerData, arr: Array) -> bool:
	return CustomActionInterpreter.handle_function(arr, self.action_id, player) == 1
	
func calc_town_add(player: PlayerData, additives: Dictionary) -> float:
	var add_mult = 0.0
	for prog in additives:
		add_mult += (additives[prog]*player.get_town_progress(prog))
	return add_mult

func calc_skill_mult(player: PlayerData, multipliers: Array) -> float:
	var mult := 1.0
	for skill in multipliers:
		mult *= player.get_skill_modifier(skill, self.action_id)
	return mult
	
func calc_buff_mult(player: PlayerData, multipliers: Array) -> float:
	var mult := 1.0
	for skill in multipliers:
		mult *= player.get_buff_modifier(skill, self.action_id)
	return mult

func calc_boon_mult(player: PlayerData, multipliers: Array) -> float:
	var mult := 1.0
	for boon in multipliers:
		mult *= player.get_boon_modifier(boon, self.action_id)
	return mult
	
func calc_resource_mult(player: PlayerData, multipliers: Dictionary) -> float:
	var mult = 1.0
	for res in multipliers:
		var count = player.get_resource_count(res)
		mult *= (count*multipliers[res] if count != 0 else 1)
	return mult

func calc_multi_boost_mult(player: PlayerData, multipliers: Array) -> float:
	var mult := 1.0
	for action in multipliers:
		mult *= player.get_multipart_boost(action)
	return mult

func calc_quality_boost_mult(player: PlayerData, multipliers: Array) -> float:
	var mult := 1.0
	for action in multipliers:
		mult *= player.get_quality_boost(action)
	return mult

func calc_custom_mult(player: PlayerData, custom_func: Array[int]) -> float:
	return CustomActionInterpreter.handle_function(custom_func, self.action_id, player)

func calculate_total_modifier(player: PlayerData, resource: String) -> float:
	var additives = self.action_additives[resource] if resource in self.action_additives else {}
	var multipliers = self.action_multipliers[resource] if resource in self.action_multipliers else {}
	var total_mult = 1.0
	
	for add in additives:
		total_mult += self.add_functions[add].call(player, additives[add])
	
	for mults in multipliers:
		total_mult *= self.mult_functions[mults].call(player, multipliers[mults])
	
	return total_mult


func calculate_non_resource_multiplier(player: PlayerData, resource: String) -> float:
	var additives = self.action_additives[resource] if resource in self.action_additives else {}
	var multipliers = self.action_multipliers[resource] if resource in self.action_multipliers else {}
	var total_mult = 1.0
	
	for add in additives:
		total_mult += self.add_functions[add].call(player, additives[add])
	
	for mults in multipliers:
		if mults != "resource":
			total_mult *= self.mult_functions[mults].call(player, multipliers[mults])
	
	return total_mult

func check_given_requirements(player: PlayerData, requirements: Dictionary) -> bool:
	for condition in requirements:
		if not self.check_functions[condition].call(player, requirements[condition]):
			return false
	return true

func get_visible(player: PlayerData) -> bool:
	return check_given_requirements(player, self.visible_req)

func get_unlocked(player: PlayerData) -> bool:
	return check_given_requirements(player, self.unlocked_req)

func check_buff_costs(player: PlayerData) -> bool:
	if not ("buffs" in self.completion_resources):
		return true
	for buff in self.completion_resources["buffs"]:
		var dict : Dictionary = self.completion_resources["buffs"][buff]
		if "cost" in dict:
			for type in dict["cost"]:
				if not player.check_soul_stone(type, ceil(dict["cost"][type]*self.calculate_total_modifier(player, "soul_stone_"+type))):
					return false
	return true

func check_town(player: PlayerData):
	return player.check_town(self.town_num, self.sub_town_status, self.world_num)
# Function to check if it can start an action
# Cannot make use of the limited flag here as it needs info from the action list
func can_start(player: PlayerData) -> bool:
	var result := (self.check_town(player)
				and check_given_requirements(player, self.required_items) 
				and check_resources(player, self.action_cost) 
				and check_buff_costs(player))

	return result
	
#Function to then return the reason(s) why it cannot for better error messages for users
#TODO Look into what are the different causes of being unable to do an action
#	In wrong town/subtown/world
#	Missing a resource/skill/etc to start the action
#	Already hit limit for the limited action
#	Action isn't unlocked
func action_fail_check(_player: PlayerData) -> String:
	return ""
# Simple function to allow overloading if needed
func remove_resources(player: PlayerData, resources: Dictionary) -> void:
	for res in resources:
		player.remove_resource(res, ceil(resources[res]*self.calculate_total_modifier(player, res)))

# Function to add resources at the end of action
func add_skills(player: PlayerData, skills: Dictionary) -> void:
	for skill in skills:
		player.add_skill(skill, floor(skills[skill]*self.calculate_total_modifier(player, skill)))

func add_skills_capped(player: PlayerData, skills: Dictionary) -> void:
	for skill in skills:
		var cap_mult := 1.0
		if "cap_func" in skills[skill]:
			cap_mult = CustomActionInterpreter.handle_function(skills[skill]["cap_func"], self.action_id, player)
		if player.get_skill_level(skill) < floor(skills[skill]["cap"]*cap_mult):
			player.add_skill(skill, floor(skills[skill]["exp"]*self.calculate_total_modifier(player, skill)))
		
func add_town_progress(player: PlayerData, town_progress: Dictionary) -> void:
	for prog in town_progress:
		var total_progress:int = floor(town_progress[prog]*self.calculate_total_modifier(player, prog))
		player.add_town_progress(prog, total_progress)
		
func add_resources(player: PlayerData, resources: Dictionary) -> void:
	for res in resources:
		player.add_resource(res, floor(resources[res]*self.calculate_total_modifier(player, res)))

## Buffs are "name": {"cap": max_level, "cap_func": custom cap (up to max, if not -1), "cost": {"soul_stone":...}}
func add_buffs(player: PlayerData, buffs: Dictionary) -> void:
	for buff in buffs:
		var custom_cap : int = buffs[buff]["cap"]
		if "custom_cap" in buffs[buff]:
			var potential_cap : int = floor(CustomActionInterpreter.handle_function(buffs[buff]["custom_cap"], self.action_id, player))
			custom_cap = min(custom_cap, potential_cap) if custom_cap != -1 else potential_cap
		if (player.get_buff_level(buff) < custom_cap) or custom_cap == -1:
			self.remove_soul_stones(player, buffs[buff]["cost"])
			player.add_buff(buff, 1)

func remove_soul_stones(player: PlayerData, ssDict: Dictionary) -> void:
	for type in ssDict:
		player.remove_soul_stone(type, ceil(ssDict[type]*self.calculate_total_modifier(player, "soul_stone_"+type)))

func add_boons(player: PlayerData, boons: Dictionary) -> void:
	for boon in boons:
		if player.get_boon_level(boon) < boons[boon]:
			player.add_boon(boon, 1)

func add_team_member(player: PlayerData, team_member_function: Array) -> void:
	var value : int = floor(CustomActionInterpreter.handle_function(team_member_function, self.action_id, player))
	player.add_team_member(self.action_id, value)

func remove_team_member(player: PlayerData, team_member_id: String) -> void:
	player.remove_team_member(team_member_id)

func add_town_variable(player: PlayerData, town_variables: Dictionary) -> void:
	for town_variable in town_variables:
		player.add_town_value(town_variable, floor(town_variables[town_variable]*self.calculate_total_modifier(player,"town_variable")), self.town_num)

func change_sub_town(player: PlayerData, sub_town_number: int) -> void:
	player.change_sub_town(sub_town_number)

func add_global_multoplier(player: PlayerData, global_multiplier: Dictionary) -> void:
	var multi : float = global_multiplier["multiplier"]*self.calculate_total_modifier(player, "global_mult")
	var duration: int = global_multiplier["duration"]*self.calculate_total_modifier(player, "global_duration")
	var downside_multi: float = 0.0
	var downside_duration: int = 0
	if "downside_multiplier" in global_multiplier:
		downside_multi = global_multiplier["downside_multiplier"]*self.calculate_total_modifier(player, "global_mult_downside")
		downside_duration = global_multiplier["downside_duration"]*self.calculate_total_modifier(player, "global_duration_downside")
	player.add_global_multiplier(global_multiplier["name"], multi, duration, downside_multi, downside_duration)

func add_soul_stones(player: PlayerData, soul_stone_dict: Dictionary) -> void:
	for type in soul_stone_dict:
		player.add_soul_stone(type, floor(soul_stone_dict[type]*self.calculate_total_modifier(player, "soul_stone_"+type)))

func add_rewards(player: PlayerData, rewards: Dictionary) -> void:
	for reward in rewards:
		self.reward_functions[reward].call(player, rewards[reward])

func add_custom_resources(player: PlayerData, custom_rewards: Dictionary) -> void:
	for reward in custom_rewards:
		var count : int = floor(CustomActionInterpreter.handle_function(custom_rewards[reward], self.action_id, player))
		if custom_rewards[reward]["resource"]:
			player.add_resource(reward, count)
		else:
			player.add_town_progress(reward, count)

func start(player: PlayerData) -> void:
	self.remove_resources(player, self.action_cost)

func finish(player: PlayerData) -> void:
	self.add_rewards(player, self.completion_resources)
# Function to get the base mana cost of the action, exp mult, stat distribution

#Mana cost rather than mana as mana can be added as a separate resource
func get_mana_cost(player: PlayerData) -> int:
	return ceil(self.base_mana_cost*self.calculate_total_modifier(player, "mana_cost"))

func get_experience_mult(player: PlayerData) -> float:
	return self.experience_mult*self.calculate_total_modifier(player, "experience_mult")

func get_stat_distribution() -> Dictionary:
	return self.stat_dist

#Override for actions that require it
func get_action_limit(player: PlayerData) -> int:
	return floor(self.action_limit*self.calculate_total_modifier(player, "limit"))

var level_function : Array[int] = [5,1]
func calc_action_level_cost(player: PlayerData, level: int) -> int:
	return floor(CustomActionInterpreter.handle_function(level_function, self.action_id, player, level))

#Array of Dictionaries: {"function", "ids"}
var boost_functions := []
func calc_level_boost(player: PlayerData, level: int) -> Dictionary:
	var total_boosts := {}
	for dict in boost_functions:
		var boost := CustomActionInterpreter.handle_function(dict["function"], self.action_id, player, level)
		for id in dict["ids"]:
			total_boosts[id] = boost
	return total_boosts
