extends Control

class_name DialogPopup

@export var dialog_data : Dialog

@export var end_screen : PackedScene

@export var player : Player

@export var last_dialog_name : String

@onready var text_label := $Label

@onready var rewards_label := $RewardsLabel
@onready var image := $Image

var entry_format_string = "> %s : %s\n"

var last_entry_index := -1

func set_up_dialog(dialog : Dialog):
	dialog_data = dialog
	last_entry_index = 0
	
	if dialog_data.rewards_text != null:
		rewards_label.text = dialog_data.rewards_text
	else:
		rewards_label.text = ""
	
	if dialog_data.image != null:
		image.texture = dialog_data.image
	else:
		image.texture = null
	
	
	text_label.text = ""
	add_entry(dialog_data.dialog_entries[0])

func add_entry(dialog_entry : DialogEntry):
	var speaker = dialog_entry.speaker
	var entry_text = dialog_entry.text
	
	text_label.text += entry_format_string % [speaker, entry_text]


# Called when the node enters the scene tree for the first time.
func _ready():
	text_label.text = ""
	if dialog_data != null:
		set_up_dialog(dialog_data)
	else:
		visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		player.can_move = false
		if Input.is_action_just_pressed("ui_accept"):
			if last_entry_index < dialog_data.dialog_entries.size() - 1:
				last_entry_index += 1
				add_entry(dialog_data.dialog_entries[last_entry_index])
			else:
				visible = false
				player.can_move = true
				
				#if last_dialog_name == dialog_data.resource_name:
					#get_tree().change_scene_to_packed(end_screen)
