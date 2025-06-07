extends BaseActionDesc
class_name LootableDesc

var lootable_name := ""
var lootable_story_conditions := []
var lootable_story_strings := []

func calculate_effects_text() -> Array:
	var effect_arr := []
	if "looted_resource" in self.base_effects_text:
		var base_string : String = self.base_effects_text["looted_resource"]["base"]
		var resource_gain := []
		var action_resources : Dictionary = self.action_data.looted_resources
		for res in self.base_effects_text["looted_resource"]["res_order"]:
			resource_gain.append(floor(action_resources[res]*self.action_data.calculate_non_resource_multiplier(MainPlayer, res+"_looted")))
		base_string = base_string % resource_gain
		effect_arr.append(base_string)
	effect_arr.append_array(super())
	return effect_arr

func generate_story_text() -> String:
	var story_strings := [self.completion_story_strings, self.lootable_story_strings, self.fail_story_strings,
							self.skill_story_strings, self.buff_story_strings,
							self.boon_story_strings, self.talent_story_strings]
	return combine_story_texts(story_strings,EventBus.get_incomplete_stories(self.action_data.action_id))
