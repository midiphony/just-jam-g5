extends Control

@export var player : Player

@onready var left_key_slot := $LeftKeySlot
@onready var up_key_slot := $UpKeySlot
@onready var right_key_slot := $RightKeySlot

@onready var restart_group := $RestartGroup

@export var white_texture:Texture2D

@export var move_selection_ui:Control

# Called when the node enters the scene tree for the first time.
func _ready():
	if player == null:
		print("No player found for HUD")
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	player.move_skill_left_unlocked.connect(_on_player_move_skill_left_unlocked)

func _on_player_move_skill_left_unlocked():
	left_key_slot.texture = white_texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.move_skill_key_up != null && player.move_skill_key_up.texture != up_key_slot.texture:
		up_key_slot.texture = player.move_skill_key_up.texture
	elif player.move_skill_key_right != null && player.move_skill_key_right.texture != right_key_slot.texture:
		right_key_slot.texture = player.move_skill_key_right.texture
	elif player.is_move_skill_left_unlocked && player.move_skill_key_left != null && player.move_skill_key_left.texture != left_key_slot.texture:
		left_key_slot.texture = player.move_skill_key_left.texture
	
	if move_selection_ui != null:
		restart_group.visible = not move_selection_ui.visible
