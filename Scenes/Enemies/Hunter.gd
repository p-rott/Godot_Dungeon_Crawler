extends "res://Scenes/Enemies/BasicEnemy.gd"

#TODO hunter stops when bullets are between him and player
var direction = Vector2.ZERO
var movespeed = 100
var damage = 35

func takeDamage(amount):
	.takeDamage(amount)
	$AnimationPlayer.play("Death")

func _ready():
	$AnimationPlayer.play("Idle")

func get_class():
	return "Enemy_Hunter"

func act(canSeeEnemy):
	if canSeeEnemy:
		direction = position.direction_to(player.position)
		$AnimationPlayer.play("Running")
		if direction.angle_to(Vector2(0, 1)) <= 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
	else:
		$AnimationPlayer.play("Idle")

func _physics_process(delta):
	var collision = move_and_collide(direction * movespeed * delta)
	if collision != null:
		if collision.collider.name == "Player":
			player.takeDamage(damage)
			takeDamage(400)
	direction = Vector2.ZERO
