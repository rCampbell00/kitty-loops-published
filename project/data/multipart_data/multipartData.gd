extends Resource
class_name MultipartData

var segmentsProgress : Array[int] = []
var segmentsMax : Array[int] = []
var segmentStats : Array[String] = []
var segments_cleared := 0
var loops_cleared := 0
var boost := 1.0
var action: MultipartActionData
var has_boost := false

func setup(action_data: MultipartActionData, player: PlayerData) -> void:
	self.action = action_data
	self.has_boost = action.has_boost
	self.reset(player)

func reset(player: PlayerData) -> void:
	self.loops_cleared = 0
	self.segments_cleared = 0
	self.calculate_boost(player)
	self.segmentsMax = action.get_loop_costs(player)
	self.segmentsProgress = []
	for i in range(len(segmentsMax)):
		self.segmentsProgress.append(0)
	self.segmentStats = action.get_loop_stats(player)

## Boost is calculated when the action is completed by the loop code, rather than on segment clear to save calls
func calculate_boost(player: PlayerData) -> void:
	if self.has_boost:
		self.boost = action.get_boost_multiplier(self.segments_cleared, player)

## Update progress and costs called by loop code - used for visual code and memorising for later action calls
func update_progress(new_progress: Array[int]) -> void:
	self.segmentsProgress = new_progress

func update_segment_stats(new_stats: Array[String]) -> void:
	self.segmentStats = new_stats

func update_segment_costs(new_costs: Array[int]) -> void:
	self.segmentsMax = new_costs

func segment_cleared(_player: PlayerData) -> void:
	segments_cleared += 1

func loop_cleared(_player: PlayerData) -> void:
	loops_cleared += 1
