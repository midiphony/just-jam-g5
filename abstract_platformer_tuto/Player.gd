extends Node2D

@export var tilemap : TileMap

var tilemap_cell_size : int

# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap_cell_size = tilemap.tile_set.tile_size.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
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
