extends Node2D

@export var tilemap : TileMap
var tilemap_cell_size : int

@export var move_skill_key_down : MoveSkill
@export var move_skill_key_up : MoveSkill
@export var move_skill_key_left : MoveSkill
@export var move_skill_key_right : MoveSkill

var is_moving := false

# Called when the node enters the scene tree for the first time.
func _ready():
	if tilemap == null:
		printerr("LEVEL TILEMAP HAS NOT BEEN ASSIGNED TO THE PLAYER")
	
	tilemap_cell_size = tilemap.tile_set.tile_size.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Enable simple movements by uncommenting below code
	_process_basic_movement(delta)
	return
	
	# Don't process inputs if player is currently in a move sequence
	if is_moving:
		return
	
	var move_skill : MoveSkill
	
	if Input.is_action_just_pressed("ui_down"):
		move_skill = move_skill_key_down
	elif Input.is_action_just_pressed("ui_up"):
		move_skill = move_skill_key_up
	elif Input.is_action_just_pressed("ui_left"):
		move_skill = move_skill_key_left
	elif Input.is_action_just_pressed("ui_right"):
		move_skill = move_skill_key_right
	
	# If no key pressed, or no associated move_skill to the pressed key, do nothing
	if move_skill == null:
		return
	
	var directions := move_skill.directions
	
	for i in range(directions.size()):
		print(directions[i])
	


enum TileType { VALID, BLOCKER, VOID }

func get_tile_coords_from_global_position(some_global_position : Vector2) -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(some_global_position))
	

func get_cell_type(tile_coords : Vector2i) -> TileType:
	var tiledata : TileData = tilemap.get_cell_tile_data(0, tile_coords)
	
	if tiledata == null:
		get_tree().reload_current_scene()
		return TileType.VOID
	
	var is_void = tiledata == null or tiledata.get_custom_data("void")
	if is_void:
		print("Void !")
		get_tree().reload_current_scene()
		return TileType.VOID
	
	var is_blocking = tiledata.get_custom_data("blocker")
	if is_blocking:
		print("Blocked !")
		return TileType.BLOCKER
	
	return TileType.VALID


# Process function to enter basic movement
func _process_basic_movement(delta):
	
	var input_dir := Vector2.ZERO
	
	if Input.is_action_just_pressed("ui_down"):
		input_dir = Vector2(0,1)
	elif Input.is_action_just_pressed("ui_up"):
		input_dir = Vector2(0,-1)
	elif Input.is_action_just_pressed("ui_left"):
		input_dir = Vector2(-1,0)
	elif Input.is_action_just_pressed("ui_right"):
		input_dir = Vector2(1,0)
		
	
	if input_dir != Vector2.ZERO:
		var target_position := global_position + input_dir * tilemap_cell_size
		
		var target_tile_coords := tilemap.local_to_map(tilemap.to_local(target_position))
		
		var tiledata : TileData = tilemap.get_cell_tile_data(0, target_tile_coords)
		
		if tiledata == null:
			get_tree().reload_current_scene()
			return
		
		var is_void = tiledata == null or tiledata.get_custom_data("void")
		if is_void:
			print("Void !")
			get_tree().reload_current_scene()
			return
		
		var is_blocking = tiledata.get_custom_data("blocker")
		if is_blocking:
			print("Blocked !")
			return
		
		global_position = target_position
