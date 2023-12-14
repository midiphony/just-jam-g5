extends Node2D

class_name Player

signal has_restarted

@export var tilemap : TileMap
var tilemap_cell_size : int

@export var move_skill_key_down : MoveSkill
@export var move_skill_key_up : MoveSkill
@export var move_skill_key_left : MoveSkill
@export var move_skill_key_right : MoveSkill

@export var move_step_duration := 0.3

var start_position : Vector2

var can_move := false

# Called when the node enters the scene tree for the first time.
func _ready():
	if tilemap == null:
		printerr("LEVEL TILEMAP HAS NOT BEEN ASSIGNED TO THE PLAYER")
	
	tilemap_cell_size = tilemap.tile_set.tile_size.x
	
	# Center player on the tile he is over
	var current_tile_coords := get_tile_coords_from_global_position(global_position)
	global_position = tilemap.to_global(tilemap.map_to_local(current_tile_coords))
	
	start_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("restart"):
		global_position = start_position
		has_restarted.emit()
	
	# Don't process inputs if player is currently in a move sequence
	if not can_move:
		return
	
	# Enable simple movements by uncommenting below code
	_process_basic_movement(delta)
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
	if directions.size() > 0:
		can_move = true
	
	var current_tile_coords := get_tile_coords_from_global_position(global_position)
	var original_position := global_position
	var previous_position := global_position
	var target_tile_coords := current_tile_coords
	
	
	var tween := create_tween()
	
	for i in range(directions.size()):
		var direction := directions[i]
		
		match direction:
			MoveSkill.DIRECTION.LEFT:
				target_tile_coords += Vector2i.LEFT
			MoveSkill.DIRECTION.RIGHT:
				target_tile_coords += Vector2i.RIGHT
			MoveSkill.DIRECTION.UP:
				target_tile_coords += Vector2i.UP
			MoveSkill.DIRECTION.DOWN:
				target_tile_coords += Vector2i.DOWN
			_:
				printerr("Unkwown MoveSkill Direction")
		
		var cell_type := get_cell_type(target_tile_coords)
		var target_position = tilemap.to_global(tilemap.map_to_local(target_tile_coords))
		
		match cell_type:
			CellType.VALID:
				tween.tween_property(self, "global_position", target_position, move_step_duration)
				pass
			CellType.BLOCKER:
				tween.set_ease(Tween.EASE_IN)
				tween.tween_property(self, "global_position", target_position, move_step_duration / 5)
				tween.set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "global_position", previous_position, move_step_duration / 5)
				tween.tween_callback(
					func(): global_position = original_position
				)
				break
			CellType.VOID:
				tween.tween_property(self, "global_position", target_position, move_step_duration)
				tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
				tween.tween_callback(
					func(): 
						global_position = original_position
						scale = Vector2.ONE
				)
				break
			_:
				printerr("Unkwown CellType")
				break
		
		previous_position = target_position
	
	
	tween.tween_callback(
		func(): can_move = false
	)
	


enum CellType { VALID, BLOCKER, VOID }

func get_tile_coords_from_global_position(some_global_position : Vector2) -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(some_global_position))
	

func get_cell_type(tile_coords : Vector2i) -> CellType:
	var tiledata : TileData = tilemap.get_cell_tile_data(0, tile_coords)
	
	if tiledata == null:
		return CellType.VOID
	
	var foreground_tile_data := tilemap.get_cell_tile_data(1, tile_coords)
	if foreground_tile_data != null:
		tiledata = foreground_tile_data
	
	var is_void = tiledata == null or tiledata.get_custom_data("void")
	if is_void:
		print("Void !")
		return CellType.VOID
	
	var is_blocking = tiledata.get_custom_data("blocker")
	if is_blocking:
		print("Blocked !")
		return CellType.BLOCKER
	
	return CellType.VALID


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
		
		var tile_type := get_cell_type(tilemap.local_to_map(tilemap.to_local(target_position)))
		
		var tiledata : TileData = tilemap.get_cell_tile_data(0, target_tile_coords)
		
		match tile_type:
			CellType.BLOCKER:
				print("Blocked !")
				return
			CellType.VOID:
				print("Void !")
				get_tree().reload_current_scene()
				return
		
		global_position = target_position


func _on_area_2d_area_entered(area):
	if area.name.begins_with("ability"):
		print("Move skill name : ", area.move_skill_name)
		print("New slot : ", area.new_slot)
		area.queue_free()
	
	if area.name.begins_with("dialog"):
		print("dialog")
