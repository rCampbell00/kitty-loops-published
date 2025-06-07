extends BaseActionData

func _init() -> void:
	self.action_id = "wander"
	self.world_num = Utility.Worlds.TERRA
	self.town_num = Utility.Terra_Towns.BEGINNERSVILLE
	self.stat_dist = {"Con": 0.2, "Spd": 0.3, "Per": 0.2, "Luck": 0.1, "Cha": 0.2}
	self.base_mana_cost = 250#{"cap": max_level, "cap_func": custom cap (up to max, if not -1), "cost": {"soul_stone_type": amount}}
	self.completion_resources = {"town_progress": {"wander": 100}, "skills": {"pyromancy": 10}, "buffs": {"dark_ritual": {"cap": 666, "cost": {"base": 500}}}, "boons": {"holy_boon": 1}}
	self.flags = ["explore", "pyromancy"]
	self.action_multipliers = {"wander": {"resources": {"glasses": 2}}}
	self.level_function = [6,5,1,0,5,100,1]
	self.main_skill = "pyromancy"
	self.main_buff = "dark_ritual"
	self.main_boon = "holy_boon"
	self.boost_functions = []
	self.level_function = [5,100]
