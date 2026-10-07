# skrzynka z ktorej wyskakuje ziomek
extends Node2D


var speed = 100
var margin = 55
var direction = Vector2(1,0)

@onready var animated_sprite = $Green
@onready var area = $Area2D
var idle_timer = 0.0
var is_idling = false
var is_dragging = false
var drag_offset = Vector2()
var afk_time = 0.0
var draging_time = 0.0
var afk = false
var color = "Green"
var last_direction = Vector2.ZERO
var is_dying = false
var is_angry = false
var is_petting = false
var float_pos = Vector2.ZERO
func  _physics_process(delta: float) -> void:
	if is_dying:
		return
	if is_petting:
		return
	var mouse_pos = Vector2(DisplayServer.mouse_get_position())
	if is_dragging:
		var new_win_pos = mouse_pos - drag_offset
		float_pos = new_win_pos
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		draging_time += delta
		is_idling = false
		if draging_time > 5:
			is_angry = true
			if is_angry:
				animated_sprite.play('hit')
		else:
			is_angry = false
		return
	elif not is_dragging:
		draging_time = 0
	if is_idling:
		idle_timer -= delta
		if idle_timer <= 0:
			is_idling = false
			speed = 100          
			animated_sprite.play('walk')  
		return

	var screen_size = Vector2(DisplayServer.screen_get_size()) 
	var window_size = Vector2(DisplayServer.window_get_size())		
	float_pos += direction * speed * delta
	float_pos.x = clamp(float_pos.x, -margin, screen_size.x - window_size.x + margin)
	DisplayServer.window_set_position(Vector2i(float_pos))		
	if float_pos.x <= -margin or float_pos.x >= screen_size.x - window_size.x + margin:
		direction.x *= -1
		animated_sprite.flip_h = direction.x < 0
		may_idle()
		if is_idling:
			return
	afk_time += delta
	if afk_time > 3600.0:
		animated_sprite.play('idle')
		speed = 0
	else:
		speed = 100
		animated_sprite.play('walk')

	
	if float_pos.y <= 0 or float_pos.y >= screen_size.y - window_size.y:
		direction.y *= -1
		may_idle()

		

	
func _input(event):
	if is_dying:
		return
	if event is InputEventKey and event.is_released():
		afk_time = 0.0
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.is_pressed():
			is_dragging = false
			animated_sprite.play('walk')
		if event.is_pressed():
			if event.position.distance_to(animated_sprite.global_position) > 55:
				is_dragging = true
				animated_sprite.play('idle')
				var mouse_pos = Vector2(DisplayServer.mouse_get_position())
				var win_pos = Vector2(DisplayServer.window_get_position())
				drag_offset = mouse_pos - win_pos
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			direction.x *= 0
			direction.y *= 0
			is_dying = true
			animated_sprite.play('death')
			await get_tree().create_timer(0.6).timeout
			get_tree().quit()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			is_petting = true
			animated_sprite.play('jump_fall')
		else:
			is_petting = false
	if event is InputEventKey and event.keycode == KEY_1:
		if event.pressed:
			color = 'Green'
			animated_sprite = $Green
			$Blue.visible= false
			$Red.visible= false 
			$Green.visible= true
			$Area2D/Green.disabled = false
			$Area2D/Red.disabled = true
			$Area2D/Blue.disabled = true
			$Green.flip_h = direction.x < 0
			$Red.flip_h = direction.x < 0
			$Blue.flip_h = direction.x < 0
			if not is_dragging:
				animated_sprite.play('walk')
			elif is_dragging:
				animated_sprite.play('idle')
			

	elif event is InputEventKey and event.keycode == KEY_2:
		if event.pressed:
			color = 'Red'
			animated_sprite = $Red
			$Green.visible= false
			$Blue.visible= false 
			$Red.visible= true
			$Area2D/Green.disabled = true
			$Area2D/Red.disabled = false
			$Area2D/Blue.disabled = true
			$Green.flip_h = direction.x < 0
			$Red.flip_h = direction.x < 0
			$Blue.flip_h = direction.x < 0
			if not is_dragging:
				animated_sprite.play('walk')
			elif is_dragging:
				animated_sprite.play('idle')
	elif event is InputEventKey and event.keycode == KEY_3:
		if event.pressed:
			color = 'Blue'
			animated_sprite = $Blue
			$Green.visible= false
			$Red.visible= false 
			$Blue.visible = true
			$Area2D/Green.disabled = true
			$Area2D/Red.disabled = true
			$Area2D/Blue.disabled = false
			$Green.flip_h = direction.x < 0
			$Red.flip_h = direction.x < 0
			$Blue.flip_h = direction.x < 0
			if not is_dragging:
				animated_sprite.play('walk')
			elif is_dragging:
				animated_sprite.play('idle')

func _ready():
	float_pos = Vector2(DisplayServer.window_get_position())
	animated_sprite.play('walk')
	scale.x = 3
	scale.y = 3
	$Area2D.input_pickable = true
	$Blue.visible= false
	$Red.visible= false 
	$Green.visible= true
	$Area2D/Green.disabled = false
	$Area2D/Red.disabled = true
	$Area2D/Blue.disabled = true
#func _process(delta):
#


func may_idle():
	if randf() < 1.0:
		is_idling = true
		idle_timer = randf_range(5.0, 10.0)
		speed = 0
		animated_sprite.play('idle')

		

	
