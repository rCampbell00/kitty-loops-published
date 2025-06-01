extends MultipartActionData

func _init() -> void:
	self.action_id = "fight_monsters"
	self.world_num = Utility.Worlds.TERRA
	self.town_num = Utility.Terra_Towns.BEGINNERSVILLE
	self.stat_dist = {"Str": 0.3, "Con": 0.3, "Spd": 0.3, "Luck": 0.1}
	self.base_mana_cost = 2000
	self.multipart_length = 3
	self.stats_loop = ["Spd","Spd","Spd","Str","Str","Str","Con","Con","Con"]
	self.segment_reward = {"resources": {"gold": 20}}
	self.segment_cost_func = [6,4,5,10000,1]
	#self.has_boost = true
	#self.multipart_boost_function = [6,5,100,5,5,2,5,1,0,3]
