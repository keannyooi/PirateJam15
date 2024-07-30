class_name Attributes
extends Resource

const BASIC = CardManager.CardType.BASIC
const BLOOD = CardManager.CardType.BLOOD
const FIRE = CardManager.CardType.FIRE
const EARTH = CardManager.CardType.EARTH
const WATER = CardManager.CardType.WATER
const AIR = CardManager.CardType.AIR
const SHADOW = CardManager.CardType.SHADOW

@export var hp: float = 0.0
@export var atk: float = 0.0
@export var def: float = 0.0
@export var mys: float = 0.0
@export var res: float = 0.0
@export var spd: float = 0.0
@export var hp_max: float = 0.0
@export var def_block: float = 0.0
@export var res_block: float = 0.0

func setAttributes(floor_level, egoArray):
	var total_ego = 0
	for ego in egoArray:
		total_ego += ego
	var base = floor_level + total_ego
	var shadow_value = 3 * egoArray[SHADOW]
	var basic_value = 3 * egoArray[BASIC]
	var total_value = 3 * total_ego
	hp_max = ((total_ego + egoArray[BLOOD] + base) * base) / (egoArray[SHADOW]+1)
	hp = hp_max
	atk = (egoArray[FIRE] + base + shadow_value) * base
	def = (egoArray[EARTH] + base) * base
	mys = (egoArray[WATER] + base) * base
	res = (egoArray[AIR] + base) * base
	spd = ((total_ego * base) + ((basic_value - total_value) / 2)) * (egoArray[BASIC]+1)
