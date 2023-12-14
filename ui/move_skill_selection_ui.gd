extends Control

@export var player : Player

@export var available_skills_slots : Array[TextureRect]

@export var select_texture:Texture2D
@export var selected_texture:Texture2D

@onready var selection_feedback := %SelectionFeedback

var _has_selected_skill:bool
var selected_skill:MoveSkill

var _hovered_skill_index :int

# Called when the node enters the scene tree for the first time.
func _ready():
	player.has_restarted.connect(_on_player_restart)
	player.can_move = false
	_reset_ui()

func _on_player_restart():
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	player.can_move = false
	_reset_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _has_selected_skill:
		var has_added_skill := false
		if Input.is_action_just_pressed("ui_up"):
			player.move_skill_key_up = selected_skill
			has_added_skill = true
		elif Input.is_action_just_pressed("ui_right"):
			player.move_skill_key_right = selected_skill
			has_added_skill = true
		elif player.is_move_skill_left_unlocked and Input.is_action_just_pressed("ui_left"):
			player.move_skill_key_left = selected_skill
			has_added_skill = true
		
		if has_added_skill:
			player.available_skills.erase(selected_skill)
			selection_feedback.texture = select_texture
			_has_selected_skill = false
			_reset_ui()
	
	else:
		if player.available_skills.size() > 0 && Input.is_action_just_pressed("ui_accept"):
			selection_feedback.texture = selected_texture
			selected_skill = player.available_skills[_hovered_skill_index]
			_has_selected_skill = true
			
		if Input.is_action_just_pressed("ui_down"):
			if _hovered_skill_index >= player.available_skills.size() - 1:
				return
			
			_hovered_skill_index += 1
			_select_available_skill_slot(_hovered_skill_index, false)
			
		if Input.is_action_just_pressed("ui_up"):
			if _hovered_skill_index <= 0:
				return
			
			_hovered_skill_index -= 1
			_select_available_skill_slot(_hovered_skill_index, false)
	
	if Input.is_action_just_pressed("ui_cancel"):
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
		player.can_move = true

func _select_available_skill_slot(index:int, selected:bool):
	# For safety
	_hovered_skill_index = index
	
	if selected:
		selection_feedback.texture = selected_texture
		
	print(available_skills_slots[index].name)
	print(player.available_skills[index].resource_name)
	
	selection_feedback.global_position = available_skills_slots[index].global_position

func _reset_ui():
	var slot_index:int
	
	for i in range(player.available_skills.size()):
		available_skills_slots[i].visible = true
		available_skills_slots[i].texture = player.available_skills[i].texture
		slot_index += 1
	
	for i in range(slot_index,available_skills_slots.size()):
		available_skills_slots[i].visible = false
		
	if player.available_skills.size() == 0:
		selection_feedback.visible = false
		return
	else:
		selection_feedback.visible = true
	
	await get_tree().process_frame
	_select_available_skill_slot(0, false)
