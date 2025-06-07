extends Resource
class_name BonusDesc
# Needs a dynamic text
# Needs name of the skill/buff/boon

var desc_text : String
var bonus_id : String

# Dynamic description text of the different boosts given
# Each value in the array is another array containing: 
#	the base text
#	condition for showing it 
#	boost value to grab from the player (if any)
# Conditon Types can be: "skill", "buff", "boon", "action_visible", "town_unlocked"
# skill is just "type": skill, "level": x, "skill": restoration
# Buff and boon are the same
# "town_unlocked" is "world": int, "town": int
# "action_visible" "action": action_id
var dynamic_boost_text := []

func get_bonus(_bonus_id: String, _boost_id: String) -> float:
	return 0.0

func compose_dynamic_text(info_array: Array) -> String:
	var final_text : String = info_array[0]
	var condition : Dictionary = info_array[1]
	var boost_id : String = info_array[2]
	var add_value := true
	match condition["type"]:
		"skill":
			add_value = MainPlayer.check_skill_level(condition["skill"], condition["level"])
		"buff":
			add_value = MainPlayer.check_buff_level(condition["buff"], condition["level"])
		"boon":
			add_value = MainPlayer.check_skill_level(condition["boon"], condition["level"])
		"town_unlocked":
			add_value = MainPlayer.check_town_unlocked(condition["world"], condition["town"])
		"action_visible":
			add_value = Actions.all_actions[condition["action"]].get_visible(MainPlayer)
	if not add_value:
		return ""
	if boost_id != "":
		final_text = final_text % self.get_bonus(bonus_id, boost_id)
	return final_text

func get_bonus_name() -> String:
	return ""

func get_desc() -> String:
	return self.desc_text

func get_boost_text() -> String:
	var boost_text := ""
	for boost in self.dynamic_boost_text:
		var boost_string := self.compose_dynamic_text(boost)
		if boost_string != "":
			boost_text += "• " + boost_string + "\n"
	return boost_text
