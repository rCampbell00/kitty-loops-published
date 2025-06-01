extends Resource
class_name BaseActionDesc

var action_name := ""
var explore_name := ""
var explore_desc := ""
var base_flavour_text := ""
## Each dynamic text in the array is a array containing:
# The base text for this to include with a series of %s
# Array values to put in each %s in turn
# Array of conditions to meet to fill with the given value, "" if it does not
# Values can be: name of a skill/buff/boon, world_town number
#example: ["(Magic Skill) * (1 + Main Stat/100)%s", [" * (1 + Restoration)"], ["restoration"]]
var flavour_dynamic_text := []

# Dictionary of values for this part (and fills in result in this order)
# cost: Dict of: Base text, res_order (order resources are mentioned in the text)
# Dynamic: Stores an array of arrays of arrays (confusing yes)
# resources: same as cost
# town_variable Base text
# constants: a list of un changing information as well
# skill_cap: Stores the base text and skill_order
# action limit: Just the string to fill in with the value
# Skill and town progress is shown last
var base_effects_text := {}
var action_data: BaseActionData

func calculate_effects_text() -> Array:
	var effect_arr := []
	if "cost" in self.base_effects_text:
		var base_string : String = self.base_effects_text["cost"]["base"]
		var resource_costs := []
		for res in self.base_effects_text["cost"]["res_order"]:
			resource_costs.append(ceil(self.action_data.action_cost[res]*self.action_data.calculate_non_resource_multiplier(MainPlayer, res)))
		base_string = base_string % resource_costs
		effect_arr.append(base_string)
	if "buff_cost" in self.base_effects_text:
		var base_string : String = self.base_effects_text["buff_cost"]["base"]
		var buff_costs := []
		for buff in self.base_effects_text["buff_cost"]["buff_order"]:
			for type in self.base_effects_text["buff_cost"]["ss_order"]:
				if type in self.action_data.completion_resources["buffs"][buff]["cost"]:
					var base_cost : int = self.action_data.completion_resources["buffs"][buff]["cost"][type]
					buff_costs.append(ceil(base_cost*self.action_data.calculate_non_resource_multiplier(MainPlayer, "soul_stone_"+type)))
		base_string = base_string % buff_costs
		effect_arr.append(base_string)
	if "dynamic" in self.base_effects_text:
		effect_arr.append(self.compose_dynamic_text(self.base_effects_text["dynamic"]))
	if "resources" in self.base_effects_text:
		var base_string : String = self.base_effects_text["resources"]["base"]
		var resource_gain := []
		var action_resources : Dictionary = self.action_data.completion_resources["resources"]
		for res in self.base_effects_text["resources"]["res_order"]:
			resource_gain.append(floor(action_resources[res]*self.action_data.calculate_non_resource_multiplier(MainPlayer, res)))
		base_string = base_string % resource_gain
		effect_arr.append(base_string)
	if "town_variable" in self.base_effects_text:
		effect_arr.append(self.base_effects_text["town_variable"]) #TBD if more is needed
	if "constants" in self.base_effects_text:
		effect_arr.append_array(self.base_effects_text["constants"])
	if "skill_cap" in self.base_effects_text:
		var base_string : String = self.base_effects_text["skill_cap"]["base"]
		var skill_caps := []
		var capped_skills : Dictionary = self.action_data.completion_resources["skill_capped"]
		for skill in self.base_effects_text["resources"]["skill_order"]:
			var cap_mult := 1.0
			if "cap_func" in capped_skills[skill]:
				cap_mult = CustomActionInterpreter.handle_function(capped_skills[skill]["cap_func"], self.action_data.action_id, MainPlayer)
			skill_caps.append(floor(capped_skills[skill]["cap"]*cap_mult))
		base_string = base_string % skill_caps
		effect_arr.append(base_string)
	if "limit" in self.base_effects_text:
		effect_arr.append(self.base_effects_text["limit"] % self.action_data.get_action_limit(MainPlayer))
	return effect_arr

func compose_dynamic_text(info_array: Array) -> String:
	var final_text : String = info_array[0]
	var dynamic_text_array : Array = info_array[1]
	var text_conditions : Array = info_array[2]
	var dynamic_values := []
	for i in range(len(dynamic_text_array)):
		var add_value := false
		var condition : String = text_conditions[i]
		if condition in Actions.skill_list:
			add_value = MainPlayer.check_skill_level(condition, 1)
		elif condition in Actions.buff_list:
			add_value = MainPlayer.check_buff_level(condition, 1)
		elif condition in Actions.boon_list:
			add_value = MainPlayer.check_boon_level(condition, 1)
		else:
			var world_town := condition.split("_")
			if len(world_town) == 2:
				add_value = MainPlayer.check_town_unlocked(world_town[0].to_int(), world_town[1].to_int())
		var dynamic_value : String = dynamic_text_array[i] if add_value else ""
		dynamic_values.append(dynamic_value)
	final_text = final_text % dynamic_values
	return final_text

func generate_flavour_text() -> String:
	var final_text := base_flavour_text
	var final_composed_values = []
	for dynamic_text in flavour_dynamic_text:
		final_composed_values.append(self.compose_dynamic_text(dynamic_text))
	return final_text % final_composed_values

# Skills, town experience it should get their name and amount of exp
# Buffs it should be "Grants buff: x" (also needs to get their name)
# Boons it should be "Grants boon: y [level z if z > 1]"
func handle_skill_town_exp(data_source: Dictionary) -> String:
	var skill_town_string := ""
	if "town_progress" in data_source:
		for prog in data_source["town_progress"]:
			var explore_text : String = LanguageValues.base_explore_text % LanguageValues.exploration_to_string_name[prog]
			skill_town_string += "%s %d\n" % [Utility.bb_bold(explore_text), data_source["town_progress"][prog]]
	if "skills" in data_source:
		for skill in data_source["skills"]:
			var skill_data : int = data_source["skills"][skill]
			var name_text : String = LanguageValues.base_skill_gain_text % LanguageValues.skill_id_to_string_name[skill]
			skill_town_string += "%s %d\n" % [
				Utility.bb_bold(name_text), floor(skill_data*self.action_data.calculate_non_resource_multiplier(MainPlayer, skill)) ]
	if "skill_capped" in data_source:
		for skill in data_source["skill_capped"]:
			var skill_exp : int = data_source["skill_capped"][skill]["exp"]
			var name_text : String = LanguageValues.base_skill_gain_text % LanguageValues.skill_id_to_string_name[skill]
			skill_town_string += "%s %d\n" % [
				Utility.bb_bold(name_text), floor(skill_exp*self.action_data.calculate_non_resource_multiplier(MainPlayer, skill)) ]
	if "buffs" in data_source:
		for buff in data_source["buffs"]:
			var name_text : String = LanguageValues.base_buff_text % LanguageValues.buff_id_to_string_name[buff]
			skill_town_string += "%s\n" % [Utility.bb_bold(name_text)]
	if "boons" in data_source:
		for boon in data_source["boons"]:
			var level_string : String = ""  
			var name_text : String = LanguageValues.base_boon_texts[0] % LanguageValues.boon_id_to_string_name[boon]
			if data_source["boons"][boon] > 1: 
				level_string = LanguageValues.base_boon_texts[1] % data_source["boons"][boon]
			skill_town_string += "%s %s\n" % [Utility.bb_bold(name_text), Utility.bb_bold(level_string)]
	return skill_town_string

func generate_effects_text() -> String:
	var effect_string := ""
	var effects = self.calculate_effects_text()
	for effect in effects:
		effect_string += "• " + effect + "\n"
	effect_string += self.handle_skill_town_exp(self.action_data.completion_resources)
	return effect_string

# Will need to get data from the action and convert it into BBCode text
func generate_stats_text() -> String:
	var stat_text := ""
	stat_text += "%s: %s\n" % [Utility.bb_bold("Mana Cost"), Utility.comma_seperate(action_data.get_mana_cost(MainPlayer))]
	var stats := action_data.get_stat_distribution()
	for stat in stats:
		stat_text += "%s: %d%%; " % [Utility.bb_stat(stat), stats[stat]*100]
	stat_text += "\n%s: %d%%" % [Utility.bb_bold("Exp Multiplier"), action_data.get_experience_mult(MainPlayer)*100]
	return stat_text

func combine_story_texts(story_sets: Array, incomplete_story_indexes: Array) -> String:
	var connected_string := ""
	var found_incomplete := false
	for i in range(len(story_sets)):
		var stories : Array = story_sets[i]
		var incomplete_stories : Array = incomplete_story_indexes[i]
		for j in range(len(stories)):
			var story_pair : Array = stories[j]
			if j in incomplete_stories:
				if not found_incomplete:
					found_incomplete = true
					connected_string += Utility.bb_bold(story_pair[0])
				else:
					connected_string += Utility.bb_bold("???")
				connected_string += ": ???\n"
			else:
				connected_string += "%s: %s\n" % [Utility.bb_bold(story_pair[0]),story_pair[1]]
	return connected_string

#Will need code to check stories complete and write ??? otherwise
#And for first story not unlocked to show the unlock condition
func generate_story_text() -> String:
	var story_strings := [self.completion_story_strings, self.fail_story_strings,
							self.skill_story_strings, self.buff_story_strings,
							self.boon_story_strings, self.talent_story_strings]
	return combine_story_texts(story_strings,EventBus.get_incomplete_stories(self.action_data.action_id))


## String generation
# This is more for descriptions that change over time - i.e. skill descriptions or action tick functions
# Base text always there
#	Inside the base text, a series of %s
#	For each %s, there is a corresponding string stored and a condition with it
#	If condition is true, adds the string, otherwise ""
# Possible check values
#	Town unlocked
#	Skill/buff/boon unlocked
## Action effect filling in
# Array of points to explain
#	For each one, include a series of %s, which has an array of key names to parse into values
#		Stuff to parse: Resource, skill caps, town-variable, resource cost, action limit
#	Values to parse need to calc their total value (excluding changes from town variables/resources)
#	Also include: sub-town if in one (or if it will move your sub-town state)
#	Unlock requirements (can be hard-coded)
#	Add each skill experience/town exploration exp with bold text
#	If it gives a team member, mention the value
#	Any dynamic value
# -------
# Mana cost
# Stat distribution
# EXP multiplier
# --------
# Buffs/boons/skills should have the extra information about the skill (if they are the main action for it)
## Story information
### Might need to make the tooltip for these be sticky
#	Could be done via a short timer when mouseout it received, if timer ends, it closes the tooltip, but if the mouse enters the tooltip
#	it makes a signal to say "don't close" and when mouse out it gotten from it - then it frees it
# Array of paired story strings: ["unlock_texk", "Story"]
# Array of conditions
## Kinds of conditions needed
## Basic
var completion_story_conditions := []
var completion_story_strings := []
var fail_story_conditions := []
var fail_story_strings := []
var skill_story_conditions := []
var skill_story_strings := []
var buff_story_conditions := []
var buff_story_strings := []
var boon_story_conditions := []
var boon_story_strings := []
var talent_story_conditions := []
var talent_story_strings := []
# Action completed - All below can be within "on complete", base one just has no conditions
# Action failed - needs to be able to also check resources for specific fail conditions (basically same as complete but on fail)
# Action with team members (might need to make it be based on x strength)
# Action with resources
# Action with certain amount of a town's variable (needs be flexible to do >=, <=
# Action with % explored of an explore (mostly for its own but sometimes others)
# Total number of times action has been done - TODO
## Lootable
# x number of lootable that are considered good
# x number done in a single loop (might be able to merge these)
# --- This is only needed for lootables so could store in its own thing?
## Multipart Actions
# X segment reached
# X loops completed
# Total number of loops over all runs
# Quality of multipart
# --- Only needed for multipart actions
## Talent/Skill/Buff/Boon
# Reached x level with the relevant one - will need a check for this using a flag of some kind
