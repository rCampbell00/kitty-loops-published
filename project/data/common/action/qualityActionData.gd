extends MultipartActionData
class_name QualityActionData

var quality_func : Array[int]
func calc_quality_cost(player: PlayerData, level: int) -> int:
	return floor(CustomActionInterpreter.handle_function(quality_func, self.action_id, player, level))

var quality_loop_func : Array[int]
func quality_loop_progress(player: PlayerData) -> int:
	return floor(CustomActionInterpreter.handle_function(quality_loop_func, self.action_id, player))

var quality_segment_func : Array[int]
func quality_segment_progress(player: PlayerData) -> int:
	return floor(CustomActionInterpreter.handle_function(quality_segment_func, self.action_id, player))

var quality_boost_func : Array[int]
func calc_quality_boost(player: PlayerData, level: int) -> float:
	return floor(CustomActionInterpreter.handle_function(quality_boost_func, self.action_id, player, level))
