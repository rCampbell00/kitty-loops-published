extends BonusDesc
class_name BuffDesc

func get_bonus(buff_id: String, boost_id: String) -> float:
	return MainPlayer.get_buff_modifier(buff_id, boost_id)


func get_bonus_name() -> String:
	return LanguageValues.buff_id_to_string_name[self.bonus_id]
