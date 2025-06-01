extends MultipartData
class_name QualityData

var quality_level := 0
var quality_progress := 0
var quality_progress_needed := 100
var quality_boost := 1.0


func reset(player: PlayerData) -> void:
	super(player)
	self.quality_level = 0
	self.quality_progress = 0
	self.quality_boost = self.action.calc_quality_boost(player, self.quality_level)
	self.quality_progress_needed = self.action.calc_quality_cost(self.quality_level)

func calculate_boost(player: PlayerData) -> void:
	super(player)
	self.quality_boost = self.action.calc_quality_boost(player, self.quality_level)

func add_quality_progress(player: PlayerData, amount: int) -> void:
	self.quality_progress += amount
	while self.quality_progress >= self.quality_progress_needed:
		self.quality_progress -= self.quality_progress_needed
		self.quality_level += 1
		self.quality_progress_needed = self.action.calc_quality_cost(player, self.quality_level)

func segment_cleared(player: PlayerData) -> void:
	super(player)
	var quality_gained : int = self.action.quality_segment_progress(player)
	self.add_quality_progress(player, quality_gained)
	
func loop_cleared(player: PlayerData) -> void:
	super(player)
	var quality_gained : int = self.action.quality_loop_progress(player)
	self.add_quality_progress(player, quality_gained)
	
