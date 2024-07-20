class_name NarrationSystem
extends Control

@export var opening_narration_key: String
@export var closing_narration_key: String

@onready var narration_box: VBoxContainer = %Narration
@onready var narration_timer: Timer = $NarrationTimer
@onready var narration_key_dict: Dictionary = {
	"opening": opening_narration_key,
	"closing": closing_narration_key
}
@onready var scroll_bar: VScrollBar = $MarginContainer/ScrollContainer.get_v_scroll_bar()
@onready var scroll_bar_set_timer: Timer = $ScrollBarSetTimer

const NARRATION_FILE_PATH: String = "res://events/dialogs/narration.json"
const LINE_ANIM_TIME: float = 0.5

var narration_dict: Dictionary


func _ready():
	if not FileAccess.file_exists(NARRATION_FILE_PATH):
		push_error("ERROR: narration file doesn't exist at filepath " \
			+ NARRATION_FILE_PATH)
		return
	
	var narration_file = FileAccess.open(NARRATION_FILE_PATH, FileAccess.READ)
	# convert FileAccess object to Dictionary
	narration_dict = JSON.parse_string(narration_file.get_as_text())
	narration_file.close()
	
	# initialize whitespace for scrolling effect
	%Whitespace.custom_minimum_size.y = $MarginContainer.size.y
	

func end_narration() -> void:
	print("end of narration, should either pop up card selection or load the next event")
	

func next_line(narration_array: Array, index: int) -> void:
	# check if the narration array has ended
	if index >= len(narration_array):
		end_narration()
		return
	
	# add new label to narration list
	var label = Label.new()
	label.text = narration_array[index]
	label.modulate.a = 0
	narration_box.add_child(label)
	
	# tiny wait just so the scroll bar can properly set itself
	scroll_bar_set_timer.start()
	await scroll_bar_set_timer.timeout
	scroll_bar.ratio = 1.0
	
	# give it a little fade-in
	var tween = create_tween().set_ease(Tween.EASE_OUT) \
	.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(label, "modulate:a", 1, LINE_ANIM_TIME)
	
	# wait
	narration_timer.start()
	await narration_timer.timeout
	
	next_line(narration_array, index + 1)
	

func start_narration(key: String) -> void:
	if key not in narration_key_dict:
		push_error("ERROR: invalid narration key \"%s\"" % key)
		return
	
	next_line(narration_dict[narration_key_dict[key]], 0)
