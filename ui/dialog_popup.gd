extends Control

@export var dialog_data : Dialog

@onready var text_label := $Label

var entry_format_string = "> %s : %s\n"

var last_entry_index := -1

func set_up_dialog(dialog : Dialog):
	dialog_data = dialog
	last_entry_index = 0
	
	text_label.text = ""
	add_entry(dialog_data.dialog_entries[0])

func add_entry(dialog_entry : DialogEntry):
	var speaker = dialog_entry.speaker
	var entry_text = dialog_entry.text
	
	text_label.text += entry_format_string % [speaker, entry_text]


# Called when the node enters the scene tree for the first time.
func _ready():
	if dialog_data != null:
		set_up_dialog(dialog_data)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible and Input.is_action_just_pressed("ui_accept"):
		if last_entry_index < dialog_data.dialog_entries.size() - 1:
			last_entry_index += 1
			add_entry(dialog_data.dialog_entries[last_entry_index])
		else:
			visible = false
