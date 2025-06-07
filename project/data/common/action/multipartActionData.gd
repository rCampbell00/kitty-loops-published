extends BaseActionData
class_name MultipartActionData

# Length of the bars (function to get custom ones too)
var multipart_length := 3
# Divisor to use on main stat of multipart for calculation of tick progress
var main_stat_fraction := 100

func get_multipart_length() -> int:
	return self.multipart_length
# Stats loop - can be longer if its going through multiple over multiple bars
var stats_loop := []

func get_loop_stats(player: PlayerData) -> Array[String]:
	var loop_data := player.get_multipart_data(self.action_id)
	var start_segment := (loop_data.loops_cleared*self.multipart_length)
	var cur_loop_stats :Array[String]= []
	for i in range(self.multipart_length):
		cur_loop_stats.append(self.stats_loop[(start_segment+i)%len(stats_loop)])
	return cur_loop_stats

var segment_cost_func : Array[int]

# Kinds of cost in base game - fib, exponential (though small), linear
func get_loop_costs(player: PlayerData) -> Array[int]:
	var loop_data := player.get_multipart_data(self.action_id)
	var start_segment := loop_data.loops_cleared*self.multipart_length
	var loop_costs : Array[int] = []
	for i in range(self.multipart_length):
		var segment_cost := int(floor(CustomActionInterpreter.handle_function(segment_cost_func, self.action_id, player, start_segment+i)))
		loop_costs.append(segment_cost)
	return loop_costs

# Max limit of complete cycles - dungeons/DR etc - Have a way to alter this from celestial buffs? or just overload
var max_loops := -1
func hit_max_loops(player: PlayerData) -> bool:
	if max_loops == -1:
		return false
	return player.get_multipart_loop_cleared(self.action_id) >= max_loops

# Progress points
var tick_function : Array[int]
func tick_progress(player: PlayerData) -> int:
	return floor(CustomActionInterpreter.handle_function(tick_function, self.action_id, player))
# Reward per segment complete - follows same format as other reward schema
var segment_reward := {}
func segment_completed(player: PlayerData) -> void:
	player.get_multipart_data(self.action_id).segment_cleared(player)
	self.add_rewards(player, segment_reward)

var loop_reward := {}
func loop_completed(player: PlayerData) -> void:
	#Do not auto call update loop cost as may have hit end of loops
	player.get_multipart_data(self.action_id).loop_cleared(player)
	self.add_rewards(player, loop_reward)
	
##CAUTION - Never have multiple sources of buffs with the same soul stone type as a cost, does not keep a rolling total
# If changing this functionality, need to edit baseaction code too
func check_buff_costs(player: PlayerData) -> bool:
	if not super(player):
		return false
	if not ("buffs" in self.loop_reward):
		return true
	for buff in self.loop_reward["buffs"]:
		var dict : Dictionary = self.loop_reward["buffs"][buff]
		if "cost" in dict and (not player.get_buff_level(buff) >= dict["cap"]):
			for type in dict["cost"]:
				if not player.check_soul_stone(type, ceil(dict["cost"][type]*self.calculate_total_modifier(player, "soul_stone_"+type))):
					return false
	return true

func can_start(player: PlayerData) -> bool:
	return (not self.hit_max_loops(player)) and super(player)

var has_boost := false
var multipart_boost_function : Array[int]
func get_boost_multiplier(segments: int, player: PlayerData) -> float:
	return CustomActionInterpreter.handle_function(multipart_boost_function, self.action_id, player, segments)
