extends "res://Scenes/Enemies/BasicEnemy.gd"

var bullet = preload("res://Scenes/Enemies/Bullet.tscn")
var shotspeed = 150
var coolDownTime = 0.3

func get_class():
	return "Enemy_Turret"

func takeDamage(amount):
	.takeDamage(amount)
	$AnimationPlayer.play("Death")
	$Timer.paused = true

func _ready():
	$Timer.paused = true
	$Timer.start(coolDownTime)
	$AnimationPlayer.play("Idle")

func act(canSeeEnemy):
	if canSeeEnemy and active:
		$Timer.paused = false
	else:
		$Timer.paused = true
		$AnimationPlayer.play("Idle")

func _on_Timer_timeout():
	var direction = position.direction_to(player.position)
	var dist = position.distance_to(player.position)
	$AnimationPlayer.play("Shooting")
	$AudioShooting.volume_db = 0 - dist * 0.01
	$AudioShooting.play()
	var b = bullet.instance()
	add_child(b)
	b.create(direction, shotspeed, 0.8, (direction * $CollisionShape2D.shape.get_radius()))
