extends Control

@export var player : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	player.has_restarted.connect(_on_player_restart)
	player.can_move = false

func _on_player_restart():
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	player.can_move = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
		player.can_move = true
