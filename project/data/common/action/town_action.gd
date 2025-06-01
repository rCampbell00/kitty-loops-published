extends Resource
class_name TownAction

# Edit/add to a specific town variable
# Multipart where each segment has its own function to set a value
# A post-action trigger to perform functions based on action done/mana spent/time spent
# Predictor needs to have the info available to show so people can check

# Empty bars for this segment should be white, not coloured? z10 starts full and decreases instead
# Will need a way to state what the colour of each bar is (just use the stats ones)

## 9 - FAME
# Every action completed (regardless of time) needs to add to fame stat by 1, some actions will add more themselves
# Multipart will have segments fill up one at a time based on the total fame, reaching a set segment level will change/unlock actions

## 10A - Demon Army
# Each segment will progress by utilising a specific town variable that needs to be setup on start
# Each action clear will progress each segment based on what has been done
# Actions will all fail after a set TIME has been reached (or when certain values reach 0?)

##11 - Desert temple
# Needs a counter for times sand is lowered
# Level of the sand limits what can be done
# Sand slowly reduces based on mana spent
# Should only show up after temple is opened

## 12 - Gems inlaid
# Need 4 gems from extra zones available
# When one is placed it should fill the corresponding segment to show it visually
# Certain actions are only available when a stone is inlaid
# Would want actions for a stone to only show up when inlaid the first time - could use a boon for this (that also gives a small bonus)
# Would want other zones to get harder when a stone is inlaid - need a way to get this info out of the zone


## Overall data needed
var town_number : int
var world_number : int
# An action to link the visibility of the multipart to
var visibility_action := ""
# List of values (don't have to be named in code)
var town_values_count := 0
# One "Multipart" Data used to store values (and also include their colour through stat)
#	Completing the multipart segments should still trigger segment cleared
var town_segments_count := 0
var segment_stats : Array[String]
var segment_max : Array[int]
# List of functions to perform after each action and a notifier of what extra variable is needed (i.e. time/mana)
#	This includes also updating the multipart values
var segment_functions := []
# Each post action function has the key as what it affect, and has an array for a custom function for multiplier, and a pointer to what to use as the bonus value
# {"town_variable": int, "resource": "res_name", "function": [], "bonus": "variable"} for each function
var post_action_functions := []
var town_time_multiplier : Array[int] = []
# Need a way to get a town variable in the custom action (including town variables from other towns)
# Base actions also need a way to check values of town variables and add to them directly, and get them for multipliers

func action_completed(player: PlayerData, mana_spent: int, total_time: int) -> void:
	var town_identifier := "town_action_%d_%d" % [self.world_number, self.town_number]
	for i in range(len(self.post_action_functions)):
		var function_data : Dictionary = self.post_action_functions[i]
		var function : Array = function_data["function"]
		var bonus_val := 0
		if "bonus" in function_data:
			if function_data["bonus"] == "mana_spent":
				bonus_val = mana_spent
			elif function_data["bonus"] == "total_time":
				bonus_val = total_time
		var count_add := CustomActionInterpreter.handle_function(function, town_identifier, player, bonus_val)
		if "town_variable" in function_data:
			player.add_town_value(function_data["town_variable"], floor(count_add), self.town_number)
		if "resource" in function_data:
			player.add_resource(function_data["resource"], floor(count_add))
	
	for i in range(len(segment_functions)):
		var count_add := CustomActionInterpreter.handle_function(segment_functions[i], town_identifier, player, mana_spent)
		player.add_town_segment_value(i, floor(count_add))

func get_town_time_multiplier(player: PlayerData) -> float:
	if town_time_multiplier == []:
		return 1
	var town_identifier := "town_action_%d_%d" % [self.world_number, self.town_number]
	return CustomActionInterpreter.handle_function(town_time_multiplier, town_identifier, player)

## StoryFile for the action
# Need a name and description for each multipart segment
# Need a description for the main name as a tooltip to describe what it represents
