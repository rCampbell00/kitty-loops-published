extends BonusDesc
class_name BoonDesc

func get_bonus(boon_id: String, boost_id: String) -> float:
	return MainPlayer.get_boon_modifier(boon_id, boost_id)

func get_bonus_name() -> String:
	return LanguageValues.boon_id_to_string_name[self.bonus_id]
