extends Node

var stat_types = ["Cha", "Con", "Int", "Str", "Spd", "Dex", "Per", "Soul", "Luck"]

var terra_town_names := {Terra_Towns.GLOBAL: "Global Actions", 
						Terra_Towns.BEGINNERSVILLE: "Beginnersville", 
						Terra_Towns.FOREST_PATH: "Forest Path", 
						Terra_Towns.MERCHANTON: "Metchanton", 
						Terra_Towns.MT_OLYMPUS: "Mt Olympus"}

var celestial_town_names := {}
var shadow_town_names := {}
var town_names := [terra_town_names,celestial_town_names,shadow_town_names]

enum Terra_Towns {
	GLOBAL = 0,
	BEGINNERSVILLE = 1,
	FOREST_PATH = 2,
	MERCHANTON = 3,
	MT_OLYMPUS = 4
}

enum Worlds {
	TERRA = 0,
	CELESTIAL = 1,
	SHADOW = 2
}

var si = ["","K","M","B","T","Qa","Qi","Sx","Sp","Oc"];

func round2DP(number: float) -> float:
	return snapped(number, 0.01)

func numberToSuffix(number: float) -> String:
	if abs(number) < 1000:
		return str(floor(number))
	var suffix_pos := (str(abs(round(number))).length()-1)/3
	var suffix_size := (str(abs(round(number))).length()-1)%3
	var short_hand_num := number / pow(1000, suffix_pos)
	if round(abs(short_hand_num)) >= pow(10,suffix_size+1):
		suffix_size = (suffix_size+1) % 3
		suffix_pos += 1 if suffix_size == 0 else 0
		short_hand_num /= 1000 if suffix_size == 0 else 1
	
	if suffix_pos >= si.size():
		return "%.0f%s" % [number / pow(1000, si.size()-1), si[-1]]
	return "%.*f%s" % [2-suffix_size,short_hand_num, si[suffix_pos]]

func numbersToSuffix(numbers: Array[int]) -> Array[String]:
	var new_arr: Array[String] = []
	for number in numbers:
		new_arr.append(numberToSuffix(number))
	return new_arr

#Code to set the bold text as default [b] auto assigns too much weight
func bb_bold(text: String) -> String:
	return "[font otv='wght=600']"+text+"[/font]"

func colourText(text: String, colour: String) -> String:
	return "[color="+colour+"]"+bb_bold(text)+"[/color]"

func bb_cha(text: String) -> String:
	return colourText(text, "B86582")

func bb_con(text: String) -> String:
	return colourText(text, "b06f37")

func bb_dex(text: String) -> String:
	return colourText(text, "748A24")

func bb_int(text: String) -> String:
	return colourText(text, "2659B9")

func bb_luck(text: String) -> String:
	return colourText(text, "25B536")

func bb_per(text: String) -> String:
	return colourText(text, "41A0A4")

func bb_soul(text: String) -> String:
	return colourText(text, "663399")

func bb_spd(text: String) -> String:
	return colourText(text, "918000")

func bb_str(text: String) -> String:
	return colourText(text, "D70037")
	
func bb_stat(text: String) -> String:
	var stat_functions := {"cha": bb_cha, "int": bb_int, "str": bb_str, "spd": bb_spd, "dex": bb_dex, "luck": bb_luck, "soul": bb_soul, "per": bb_per, "con": bb_con}
	if text.to_pascal_case() in stat_types:
		return stat_functions[text.to_lower()].call(text)
	return text

func comma_seperate(number: int) -> String:
	var result := ""
	if number < 0:
		result += "-"
		number *= -1
	var num_string := str(number)
	var place_pos = len(num_string) % 3
	var last_index = len(num_string) -1
	for index in range(len(num_string)):
		result += num_string[index]
		if (index +1) % 3 == place_pos and index != last_index:
			result += ","
	return result

var fibonaccis := [1]
func fibonacci(n) -> int:
	if (n == 0):
		return 1
	if (len(fibonaccis) >= n):
		return fibonaccis[n-1]
	fibonaccis.append(fibonacci(n - 1) + fibonacci(n - 2))
	return fibonaccis[n-1]
