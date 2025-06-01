extends ScalingLevel
class_name CappedLevel

var level_cap := 100

func add_exp(new_exp: int, player: PlayerData) -> bool:
	if self.level >= level_cap:
		return false
	var did_level = super(new_exp, player)
	if self.level >= self.level_cap:
		self.level = self.level_cap
		self.experience = 0
	return did_level

func set_level(new_level: int, new_exp: int, player: PlayerData) -> void:
	if new_level > self.level_cap:
		new_level = self.level_cap
	super(new_level, new_exp, player)

func set_level_cap(new_cap: int) -> void:
	self.level_cap = new_cap

func check_capped() -> bool:
	return self.level >= self.level_cap

func get_level_cap() -> int:
	return self.level_cap
