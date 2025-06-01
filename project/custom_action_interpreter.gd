extends Node


enum instruction {
	ADD,
	MULTIPLY,
	DIVIDE,
	POW,
	FIB,
	LIT,
	EXTRA_VAL,
	SKILL_MOD,
	BUFF_MOD,
	STAT_VAL,
	MUL_BOOST,
	QUAL_BOOST,
	TOWN_LEVEL,
	BOON_LEVEL,
	BUFF_LEVEL,
	SKILL_LEVEL,
	RESOURCE_COUNT,
	MUL_LOOPS,
	EQUALS,
	NOT_EQUALS,
	LESS_THAN,
	GREATER_THAN,
	GREATER_EQUAL,
	LESS_EQUAL,
	JUMP,
	TOWN_VARIABLE,
	TOWN_SEGMENT_COMPLETE,
	TOWN_SEGMENTS_COMPLETE
}

#TODO - Later swap this with a generated list ordering of each enum to match with code generation
enum resources {
	mana,
	gold,
	reputation,
	glasses,
	herb,
	soul_stone,
	supplies,
	hide,
	sold_potion,
	troll_blood,
	mana_potion
}

enum skills {
	self_combat,
	team_combat,
	combat,
	magic,
	practical_magic,
	alchemy,
	dark_magic,
	crafting,
	chronomancy,
	pyromancy
}

enum buffs {
	dark_ritual,
	imbue_body
}

enum boons {
	celestial
}

enum multi_part {
	fight_monsters
}

enum explore_actions {
	wander
}

enum stat {
	Cha, 
	Con, 
	Int, 
	Str, 
	Spd, 
	Dex, 
	Per, 
	Soul, 
	Luck
}
### Instructions for custom functions (not base one like add resource):
## Values
# Get resource count
# Get Level of skill
# Get level of boon
# Get town progress level
# Get value of multipart boost/quality
# Get value of a stat
# Get a skill's modifier
# Literal value
## Operations
# Add - val 1 + val 2
# Multiply - val 1 * val 2
# Divide - val 1 / val 2
# Power - val 1 ^ val 2
# Fibonnaci - done
## Conditionals
# IF statement
# 	==, >=, <=, !=  val1, val2 for all of them
#	Code to perform if true

func handle_function(code_data: Array, action_id: String, player: PlayerData, extra_val: int = 0) -> float:
	var stack : Array[float] = []
	var pointer := 0
	while pointer < len(code_data):
		var next_instruction : int = code_data[pointer]
		match next_instruction:
			instruction.ADD:
				stack.append(stack.pop_back()+stack.pop_back())
			instruction.DIVIDE:
				stack.append(stack.pop_back() / stack.pop_back())
			instruction.MULTIPLY:
				stack.append(stack.pop_back() * stack.pop_back())
			instruction.POW:
				stack.append(pow(stack.pop_back(), stack.pop_back()))
			instruction.FIB:
				stack.append(Utility.fibonacci(stack.pop_back()))
			instruction.LIT:
				pointer += 1
				stack.append(code_data[pointer])
			instruction.EXTRA_VAL:
				stack.append(extra_val)
			instruction.SKILL_MOD:
				pointer += 1
				var skill : String = skills.keys()[code_data[pointer]]
				stack.append(player.get_skill_modifier(skill, action_id))
			instruction.BUFF_MOD:
				pointer += 1
				var buff : String = buffs.keys()[code_data[pointer]]
				stack.append(player.get_buff_modifier(buff, action_id))
			instruction.STAT_VAL:
				pointer += 1
				var stat_type : String = stat.keys()[code_data[pointer]]
				stack.append(player.get_stat_level(stat_type))
			instruction.MUL_BOOST:
				pointer += 1
				var mul : String = multi_part.keys()[code_data[pointer]]
				stack.append(player.get_multipart_boost(mul))
			instruction.QUAL_BOOST:
				pointer += 1
				var mul : String = multi_part.keys()[code_data[pointer]]
				stack.append(player.get_quality_boost(mul))
			instruction.TOWN_LEVEL:
				pointer += 1
				var explore : String = explore_actions.keys()[code_data[pointer]]
				stack.append(player.get_town_progress(explore))
			instruction.BOON_LEVEL:
				pointer += 1
				var boon : String = boons.keys()[code_data[pointer]]
				stack.append(player.get_boon_level(boon))
			instruction.BUFF_LEVEL:
				pointer += 1
				var buff : String = buffs.keys()[code_data[pointer]]
				stack.append(player.get_buff_level(buff))
			instruction.SKILL_LEVEL:
				pointer += 1
				var skill : String = skills.keys()[code_data[pointer]]
				stack.append(player.get_skill_level(skill))
			instruction.RESOURCE_COUNT:
				pointer += 1
				var res : String = resources.keys()[code_data[pointer]]
				stack.append(player.get_resource_count(res))
			instruction.MUL_LOOPS:
				pointer += 1
				var mul : String = multi_part.keys()[code_data[pointer]]
				stack.append(player.get_multipart_loop_cleared(mul))
			instruction.EQUALS:
				pointer += 1
				if stack.pop_back() == stack.pop_back():
					pointer = code_data[pointer]
			instruction.NOT_EQUALS:
				pointer += 1
				if stack.pop_back() != stack.pop_back():
					pointer = code_data[pointer]
			instruction.GREATER_THAN:
				pointer += 1
				if stack.pop_back() > stack.pop_back():
					pointer = code_data[pointer]
			instruction.GREATER_EQUAL:
				pointer += 1
				if stack.pop_back() >= stack.pop_back():
					pointer = code_data[pointer]
			instruction.LESS_THAN:
				pointer += 1
				if stack.pop_back() < stack.pop_back():
					pointer = code_data[pointer]
			instruction.LESS_EQUAL:
				pointer += 1
				if stack.pop_back() <= stack.pop_back():
					pointer = code_data[pointer]
			instruction.JUMP:
				pointer = code_data[pointer+1]
			instruction.TOWN_VARIABLE:
				pointer += 1
				var index_number = code_data[pointer]
				pointer += 1
				var town_number = code_data[pointer]
				stack.append(player.get_town_value(index_number, town_number))
			instruction.TOWN_SEGMENT_COMPLETE:
				pointer += 1
				var index_number = code_data[pointer]
				pointer += 1
				var town_number = code_data[pointer]
				stack.append(player.get_town_segment_cleared(index_number, town_number))
			instruction.TOWN_SEGMENTS_COMPLETE:
				pointer += 1
				var town_number = code_data[pointer]
				stack.append(player.get_town_total_segments_cleared(town_number))
		pointer += 1
	if stack == []:
		return 0
	return stack.pop_back()
