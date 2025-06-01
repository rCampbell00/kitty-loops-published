extends LootableActionData

func _init() -> void:
	self.action_id = "smash_pots"
	self.world_num = Utility.Worlds.TERRA
	self.town_num = Utility.Terra_Towns.BEGINNERSVILLE
	self.stat_dist = {"Per": 0.2, "Spd": 0.6, "Str": 0.2}
	self.base_mana_cost = 50
	self.looted_resources = {"mana": 100}
	#TODO multiply mana gain and mana cost by the relevant skills
	self.action_multipliers = {}
	self.lootable_total_multipliers = {"town_progress": {"wander": 5}}
	self.lootable_flags = []
	self.flags = []
