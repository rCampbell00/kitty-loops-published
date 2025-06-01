extends TownAction

# Testing fame idea
func _init() -> void:
	self.town_number = Utility.Terra_Towns.BEGINNERSVILLE
	self.world_number = Utility.Worlds.TERRA
	self.town_values_count = 1
	self.town_segments_count = 9
	self.visibility_action = "wander"
	# post action function to reduce fame by 1
	self.post_action_functions = [{"resource": "gold", "function": [5,100]}]
	# segment functions would be 9 functions that calculate the value based on the count of fame
	self.segment_functions = [[5,100],[],[],[5,10],[],[],[],[],[]]
	self.segment_stats = ["Str","Str","Str","Str","Str","Str","Str","Str","Str"]
	self.segment_max = [100,100,100,100,100,100,100,100,100]
