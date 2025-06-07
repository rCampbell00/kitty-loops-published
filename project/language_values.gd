extends Node
var version_number := "v0.01"

var stat_to_string_name := {"Cha": "Cha", "Con": "Con", "Int": "Int", "Str": "Str", "Spd": "Spd", "Dex": "Dex", "Per": "Per", "Soul": "Soul", "Luck": "Luck"}
var stat_to_long_name := {"Cha": "Charisma", "Con": "Constitution", "Int": "Intelligence", "Str": "Strength", "Spd": "Speed", "Dex": "Dexterity", "Per": "Perception", "Soul": "Soul", "Luck": "Luck"}
var stat_to_description := {"Cha": "Conversation is a battle.", "Con": "Just a little longer. Just a little more.", "Int": "Learning to learn.", 
							"Str": "Train your body.", "Spd": "Gotta go fast.", "Dex": "Know your body.", 
							"Per": "Look a little closer...", "Soul": "You are the captain.", "Luck": "Opportunity favours the fortunate."}
var stat_name := "Stats"
var stat_tool_tip_titles := ["Level: ", "Level EXP: ", "Talent: ", "Talent EXP: ", "Talent Mult: "]
var stat_main_tool_tip := "Each stat level increases relevant action's speed.\nTalent multiplies exp gained during a loop.\nTalent is not reset on loop end, while stat levels are.\nStat levels also improve progress on actions with stat bars."

var skill_id_to_string_name := {"pyromancy": "Pyromancy", "combat": "Combat", "base_magic": "Magic", "practical_magic": "Practical Magic"}
var buff_id_to_string_name := {"pyromancy": "Pyromancy", "dark_ritual": "Dark Ritual"}
var boon_id_to_string_name := {"holy_boon": "Sanctus's Blessing"}
var exploration_to_string_name := {"wander": "Explore"}
var base_skill_gain_text := "%s Exp:"
var base_buff_text := "Grants Buff: %s"
var base_boon_texts := ["Grants Boon: %s", "Level %d"]
var base_explore_text := "%s Progress Points:"
var skill_level_text := "Level Exp: "
var skill_container_name := "Skills"
var skill_combate_names := ["Self Combat", "Team Combat"]
var buff_container_name := "Buffs"
var boon_container_name := "Boons"
var boon_level_text := "Level %d"
var explore_progress_text := ["Progress: %s%%", " Explored\n", "%s/%s Progress Points to next %%."]
var lootable_check_new_text := "Check New First"
var lootable_resource_text := ["Available: ", "Unchecked: "]
var lootable_tooltip_text := [ "Remaining Good this loop: ", "Total Good Available: ","Total Found: ", "Total Checked: ", "Total Unchecked: "]
var multipart_segment_tooltip_text := ["Main Stat: ", "Progress: "]
var multipart_segment_boost_text := "Boost: "
var quality_tooltip_text := ["Boost: ","Boost on Quality Up: ", "Progress: "]

var changelog_title := "Changelog"
var changelog := [["Version 0.02 OOGA BOOOGAA LONG", "Testing version\nTest\nTEst\nHGHJGH"],["Version 0.01","This is the other text in the changelog.\nWill later change this to an XML file for all of the language code, but want game to work first, \neven if thats more effort in the long run."]]

var option_title := "Options"
var discord_text := "Discord Link"
var theme_text := "Theme"
var theme_names := ["Normal"]
var highlight_action_text := "Highlight New Actions"

var save_title := "Saving"
var save_manual_text := "Save Manually"
var export_import_words := ["Export", "Import"]
var save_subtitle_format := "%s/%s %s"
var save_other_words := ["Current List","Current Savefile","File"]
var save_warning := "Click Export to copy to clipboard (can ctrl-v elsewhere).\nPaste a save to import\nWARNING: Importing an invalid save WILL break the game.\nEmpty import will reset the game."
