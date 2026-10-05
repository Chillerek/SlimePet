# animacja smierci sie powtarza
# apperance menu
#

extends Node2D


var speed = 100
var direction = Vector2(1,0)
var screen_size = Vector2()
var window_size = Vector2(150, 150)
@onready var animated_sprite = $Green
@onready var area = $Area2D
var idle_timer = 0.0
var is_idling = false
var is_dragging = false
var drag_offset = Vector2()
var afk_time = 0.0
var afk = false
var color = "Green"
func  _physics_process(delta: float) -> void:
	if is_idling:
		idle_timer -= delta
		if idle_timer <= 0:
			is_idling = false
			speed = 100
			animated_sprite.play('walk')
		return
	if color = 'Green':
		animated_sprite = $Green
	elif color = 'Red':
		animated_sprite = $Red
	elif color = 'Black':
		animated_sprite = $Black
		
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))
	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
		may_idle()
	if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y:
		direction.y *= -1
		may_idle()
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return
		

	
func _input(event):
	if event is InputEventKey and event.is_released():
		afk_time = 0.0
		direction = Vector2(1,0) 	
		direction.x *= 1
		direction.y *= 1
	if event is InputEventKey and event.keycode == KEY_1:
		if event.pressed:
			color = 'Green'
			print(color)
	elif event is InputEventKey and event.keycode == KEY_2:
		if event.pressed:
			color = 'Red'
			print(color)
	elif event is InputEventKey and event.keycode == KEY_3:
		if event.pressed:
			color = 'Black'
			print(color)
func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play('walk')
	area.input_event.connect(_on_area_input)
	scale.x = 3
	scale.y = 3
func _process(delta):
	afk_time += delta
	#if afk_time > 5.0:
		#animated_sprite.play('idle')
		##moonwalkuje bo mnozymy przez zero
		#direction.x = 0
		#direction.y = 0
	#else:
		#direction.x *= -1
		#direction.y *= -1
	#animated_sprite.flip_h = !animated_sprite.flip_h

func may_idle():
	if randf() < 0.3:
		is_idling = true
		idle_timer = randf_range(5.0, 10.0)
		var r = randi() % 3
		if r == 0:
			animated_sprite.play('idle')
			speed = 0
func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			animated_sprite.play('idle')
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
		else:
			is_dragging = false
			animated_sprite.play('walk')
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			animated_sprite.play('death')
			direction.x *= 0
			direction.y *= 0
			await get_tree().create_timer(0.8).timeout
			get_tree().quit()
			

			




		

	
