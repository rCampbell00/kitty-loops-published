extends BaseActionDesc

func _init() -> void:
	self.action_name = "Wander"
	self.explore_name = "Explored"
	self.explore_desc = "Explore the town to find more stuff and new actions.\nEvery time you reach the progress points needed, one % is gained, until 100% is reached."
	self.base_flavour_text = "Explore the town, look for hidden areas and treasures."
	self.base_effects_text = {"constants": ["Gains 2x progress from wearing glasses."]}
	self.completion_story_strings = [["test_1","Completed the action"], ["test_2", "Completed with a team member"], ["test_3","Completed with some glasses"], ["test_4","Completed with 1% explored"], ["test_5", "Completed with a town variable at 1"]]
	self.completion_story_conditions = [{"type": "complete"}, {"type": "team_member", "power": 10}, {"type": "resource", "resource": "glasses", "count": 2, "condition": "<="}, {"type": "explore", "id": "wander", "level": 1}, {"type": "town_variable", "town_id": 1, "index": 0, "count": 1, "condition": ">="}]
	self.skill_story_strings = [["test_skill", "Got 1 pyromancy"]]
	self.skill_story_conditions = [{"skill": "pyromancy", "level": 1}]
