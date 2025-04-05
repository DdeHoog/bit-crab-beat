extends Node2D

var speed: float = 200.0
var target_x: float
var direction: int = 1 # 1 = moves right, -1 = moves left

@onready var sprite: Sprite2D = $Sprite2D

func setup(start_pos: Vector2, _target_x: float, _direction: int, _speed: float, _texture: Texture):
	position = start_pos
	target_x = _target_x
	direction = _direction
	speed = _speed
	sprite.texture = _texture

func _process(delta: float) -> void:
	# Move
	position.x += speed * direction * delta

	# Check if target reached/passed & cleanup
	var reached = false
	if direction == 1 and position.x >= target_x: reached = true
	elif direction == -1 and position.x <= target_x: reached = true

	if reached:
		queue_free()
		
