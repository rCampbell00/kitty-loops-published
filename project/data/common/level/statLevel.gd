extends BaseLevel
class_name StatLevel

var boost := 1.0
var stat := ""

#TODO update with actual checks needed
func calc_next_exp(_player: PlayerData) -> void:
	self.exp_needed = 100

func calc_boost(_player: PlayerData) -> float:
	self.boost = 1.0
	return self.boost

func set_stat(stat_name: String) -> void:
	self.stat = stat_name

#TODO change reset function to take into account base level
func reset(player: PlayerData) -> void:
	self.experience = 0
	self.level = 0
	self.calc_next_exp(player)
