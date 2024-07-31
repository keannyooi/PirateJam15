class_name AttributesHUD
extends Control

@onready var hp_bar: ProgressBar = %HPBar
@onready var atk_value_label: Label = %ATKValueLabel
@onready var def_value_label: Label = %DEFValueLabel
@onready var mys_value_label: Label = %MYSValueLabel
@onready var res_value_label: Label = %RESValueLabel
@onready var spd_value_label: Label = %SPDValueLabel


func _ready() -> void:
	update_hud()
	

func update_hud() -> void:
	hp_bar.value = PlayerData.attributes.hp
	hp_bar.max_value = PlayerData.attributes.hp_max
	
	atk_value_label.text = type_convert(PlayerData.attributes.atk, TYPE_STRING)
	def_value_label.text = type_convert(PlayerData.attributes.def, TYPE_STRING)
	mys_value_label.text = type_convert(PlayerData.attributes.mys, TYPE_STRING)
	res_value_label.text = type_convert(PlayerData.attributes.res, TYPE_STRING)
	spd_value_label.text = type_convert(PlayerData.attributes.spd, TYPE_STRING)
	
