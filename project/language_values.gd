extends Node

var stat_to_string_name := {"Cha": "Cha", "Con": "Con", "Int": "Int", "Str": "Str", "Spd": "Spd", "Dex": "Dex", "Per": "Per", "Soul": "Soul", "Luck": "Luck"}
var skill_id_to_string_name := {"pyromancy": "Pyromancy", "combat": "Combat", "base_magic": "Magic", "practical_magic": "Practical Magic"}
var buff_id_to_string_name := {"pyromancy": "Pyromancy"}
var boon_id_to_string_name := {"pyromancy": "Pureomancy"}
var exploration_to_string_name := {"wander": "Explore"}
var base_skill_gain_text := "%s Exp:"
var base_buff_text := "Grants Buff: %s"
var base_boon_texts := ["Grants Boon: %s", "Level %d"]
var base_explore_text := "%s Progress Points:"

var explore_progress_text := ["Progress: %s%%", " Explored\n", "%s/%s Progress Points to next %%."]
var lootable_check_new_text := "Check New First"
var lootable_tooltip_text := ["Total Found: ", "Total Checked: "]
var multipart_segment_tooltip_text := ["Main Stat: ", "Progress: "]
var multipart_segment_boost_text := "Boost: "
var quality_tooltip_text := ["Boost: ","Boost on Quality Up: ", "Progress: "]
