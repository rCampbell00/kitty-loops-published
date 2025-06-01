extends BaseActionDesc
class_name MultipartDesc

var multipart_data : MultipartData
var multipart_story_conditions := []
var multipart_story_strings := []
## Main bar information
# Name (can change)
var multipart_names := []
var totals_name := ""
# Multiplier value that has currently been achieved (if it exists)
# Name of the totals stat next to it
##Segment information
# Some small Dialogue for each segment (Can be longer than segment length if we want ones that loop like fight monsters)
var segment_flavour := []

func get_multipart_name() -> String:
	var index := self.multipart_data.loops_cleared % len(self.multipart_names)
	var display_name : String = self.multipart_names[index]
	if self.action_data.has_boost:
		if multipart_data.boost >= 10:
			display_name += ", %.0fx" % multipart_data.boost
		else:
			display_name += ", %.2fx" % multipart_data.boost
	return display_name

func get_loop_segment_flavours() -> Array:
	var loop_index : int = (self.multipart_data.loops_cleared * self.action_data.multipart_length)
	var flavour_arr := []
	var segments_prior : int = self.multipart_data.loops_cleared * self.action_data.multipart_length
	for i in range(self.action_data.multipart_length):
		var seg_indx := (loop_index + i) % len(self.segment_flavour)
		var index_flavour : String = self.segment_flavour[seg_indx]
		if self.action_data.has_boost:
			index_flavour += Utility.bb_bold("\n"+LanguageValues.multipart_segment_boost_text)
			var boost = self.action_data.get_boost_multiplier(segments_prior+i, MainPlayer)
			if boost >= 10:
				index_flavour += "%.0fx" % boost
			else:
				index_flavour += "%.2fx" % boost
		flavour_arr.append(index_flavour)
	return flavour_arr

func calculate_effects_text() -> Array:
	var effect_arr := super()
	if "loop_resources" in self.base_effects_text:
		var base_string : String = self.base_effects_text["loop_resources"]["base"]
		var resource_gain := []
		var loop_resources : Dictionary = self.action_data.loop_reward["resources"]
		for res in self.base_effects_text["loop_resources"]["res_order"]:
			resource_gain.append(floor(loop_resources[res]*self.action_data.calculate_non_resource_multiplier(MainPlayer, res)))
		base_string = base_string % resource_gain
		effect_arr.append(base_string)
	if "segment_resources" in self.base_effects_text:
		var base_string : String = self.base_effects_text["segment_resources"]["base"]
		var resource_gain := []
		var segment_resources : Dictionary = self.action_data.segment_reward["resources"]
		for res in self.base_effects_text["segment_resources"]["res_order"]:
			resource_gain.append(floor(segment_resources[res]*self.action_data.calculate_non_resource_multiplier(MainPlayer, res)))
		base_string = base_string % resource_gain
		effect_arr.append(base_string)
	if "loop_buff_cost" in self.base_effects_text:
		var base_string : String = self.base_effects_text["loop_buff_cost"]["base"]
		var buff_costs := []
		for buff in self.base_effects_text["loop_buff_cost"]["buff_order"]:
			for type in self.base_effects_text["loop_buff_cost"]["ss_order"]:
				if type in self.action_data.loop_reward["buffs"][buff]["cost"]:
					var base_cost : int = self.action_data.loop_reward["buffs"][buff]["cost"][type]
					buff_costs.append(ceil(base_cost*self.action_data.calculate_non_resource_multiplier(MainPlayer, "soul_stone_"+type)))
		base_string = base_string % buff_costs
		effect_arr.append(base_string)
	if "segment_buff_cost" in self.base_effects_text:
		var base_string : String = self.base_effects_text["segment_buff_cost"]["base"]
		var buff_costs := []
		for buff in self.base_effects_text["segment_buff_cost"]["buff_order"]:
			for type in self.base_effects_text["segment_buff_costff_cost"]["ss_order"]:
				if type in self.action_data.segment_reward["buffs"][buff]["cost"]:
					var base_cost : int = self.action_data.segment_reward["buffs"][buff]["cost"][type]
					buff_costs.append(ceil(base_cost*self.action_data.calculate_non_resource_multiplier(MainPlayer, "soul_stone_"+type)))
		base_string = base_string % buff_costs
		effect_arr.append(base_string)
	return effect_arr

func generate_effects_text() -> String:
	var effect_str := super()
	effect_str += self.handle_skill_town_exp(self.action_data.segment_reward)
	effect_str += self.handle_skill_town_exp(self.action_data.loop_reward)
	return effect_str



func generate_story_text() -> String:
	var story_strings := [self.completion_story_strings, self.multipart_story_strings, self.fail_story_strings,
							self.skill_story_strings, self.buff_story_strings,
							self.boon_story_strings, self.talent_story_strings]
	return combine_story_texts(story_strings,EventBus.get_incomplete_stories(self.action_data.action_id))
