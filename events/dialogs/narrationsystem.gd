class_name NarrationSystem
extends Control

signal narration_finished

@export var opening_narration_key: String
@export var closing_narration_key: String

@onready var narration_box: VBoxContainer = %Narration
@onready var narration_timer: Timer = $NarrationTimer
@onready var narration_key_dict: Dictionary = {
	"opening": opening_narration_key,
	"closing": closing_narration_key
}
@onready var scroll_bar: VScrollBar = $MarginContainer/VBoxContainer/ScrollContainer.get_v_scroll_bar()
@onready var skip_button: Button = %SkipButton
@onready var tiny_timer: Timer = $TinyTimer
@onready var whitespace: MarginContainer = %Whitespace

const NARRATION_FILE_PATH: String = "res://events/dialogs/narration.json"
const LINE_ANIM_TIME: float = 0.5

var current_index: int = 0
var current_key: String = ""
var is_narrating: bool = false
var narration_dict: Dictionary


func _ready():
	skip_button.show()
	
	# load narration.json
	if not FileAccess.file_exists(NARRATION_FILE_PATH):
		push_error("ERROR: narration file doesn't exist at filepath " \
			+ NARRATION_FILE_PATH)
		return
	
	# convert FileAccess object to Dictionary
	var narration_file = FileAccess.open(NARRATION_FILE_PATH, FileAccess.READ)
	narration_dict = JSON.parse_string(narration_file.get_as_text())
	narration_file.close()
	
	# connect signals
	skip_button.pressed.connect(skip_narration)
	
	# initialize whitespace for scrolling effect
	whitespace.custom_minimum_size.y = $MarginContainer.size.y - skip_button.size.y
	

func end_narration() -> void:
	skip_button.hide()
	
	var separator = HSeparator.new()
	narration_box.add_child(separator)
	
	is_narrating = false
	narration_finished.emit()
	

func insert_line(text: String) -> Label:
	# add new label to narration list and do settings
	var label = Label.new()
	label.text = text
	label.set_anchors_preset(LayoutPreset.PRESET_HCENTER_WIDE)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	narration_box.add_child(label)
	
	# print(label.text)
	return label
	

func next_line(narration_array: Array) -> void:
	# check if narration has been skipped
	if not is_narrating: return
	
	# check if the narration array has ended
	if current_index >= len(narration_array):
		end_narration()
		return
	
	var label: Label = insert_line(narration_array[current_index])
	label.modulate.a = 0
	
	# tiny wait just so label.size.y returns the correct value
	tiny_timer.start()
	await tiny_timer.timeout
	whitespace.custom_minimum_size.y -= label.size.y
	page_down()
	
	# give it a little fade-in
	var tween = self.create_tween().set_ease(Tween.EASE_OUT) \
	.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(label, "modulate:a", 1, LINE_ANIM_TIME)
	
	# wait
	narration_timer.start()
	await narration_timer.timeout
	
	current_index += 1
	next_line(narration_array)
	

func page_down() -> void:
	# tiny wait just so the scroll bar can properly set itself
	tiny_timer.start()
	await tiny_timer.timeout
	
	scroll_bar.ratio = 1.0
	

func start_narration(section: String) -> void:
	if section not in narration_key_dict:
		push_error("ERROR: invalid narration section \"%s\"" % section)
		return
	
	current_key = narration_key_dict[section]
	current_index = 0
	if current_key not in narration_dict:
		push_error("ERROR: invalid narration key \"%s\"" % current_key)
		return
	
	current_index = 0
	is_narrating = true
	skip_button.show()
	next_line(narration_dict[current_key])
	

func skip_narration() -> void:
	var remaining_text_height = 0
	for i in range(current_index, len(narration_dict[current_key])):
		var label = insert_line(narration_dict[current_key][i])
		remaining_text_height += label.size.y
		
	
	whitespace.custom_minimum_size.y -= remaining_text_height
	page_down()
	
	end_narration()
	
