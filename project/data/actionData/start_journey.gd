extends TransitionActionData

func _init() -> void:
	self.action_id = "start_journey"
	self.world_num = Utility.Worlds.TERRA
	self.town_num = Utility.Terra_Towns.BEGINNERSVILLE
	self.stat_dist = {"Con": 0.4, "Spd": 0.3, "Per": 0.3}
	self.base_mana_cost = 100
	self.action_limit = 1
	self.flags = ["limited"]
	self.town_changes = {0: [2]}
	#self.action_end_cost = {"supplies": 1}
	self.visible_req = {"town_progress": {"wander": 1}}
	self.unlocked_req = {"town_progress": {"wander": 1}}
