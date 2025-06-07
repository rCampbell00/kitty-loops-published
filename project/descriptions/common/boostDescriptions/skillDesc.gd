extends BonusDesc
class_name SkillDesc

func get_bonus(skill_id: String, boost_id: String) -> float:
	return MainPlayer.get_skill_modifier(skill_id, boost_id)

func get_bonus_name() -> String:
	return LanguageValues.skill_id_to_string_name[self.bonus_id]
