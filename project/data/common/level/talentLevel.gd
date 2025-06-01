extends BaseLevel
class_name TalentLevel


var boost := 1.0
var stat := ""

#TODO update with actual checks needed
func calc_next_exp(_player: PlayerData) -> void:
	self.exp_needed = 100

func set_level(new_level: int, new_exp: int, player: PlayerData) -> void:
	super(new_level, new_exp, player)
	self.calc_boost(player)

func set_stat(stat_name: String) -> void:
	self.stat = stat_name

func calc_boost(_player: PlayerData) -> float:
	self.boost = 1.0
	return self.boost

func reset(player: PlayerData) -> void:
	pass #Nothing about talent should reset
