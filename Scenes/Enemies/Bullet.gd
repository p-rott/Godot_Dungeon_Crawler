extends KinematicBody2D

export var a = 0.0
export var b = 0.0

var direction
var speed
var f = 0
var fmax = 20
var defaultCollisionRadius = 20
var damage = 30
var size
var playerBullet = false

func get_class():
	return "Bullet"

func _process(delta):
	$Sprite.get_material().set_shader_param("n_out15p0", a)

func create(dir, sp, sz, spawnDistance):
	randomize()
	direction = dir
	speed = sp
	size = sz
	$CollisionShape2D.shape.set_radius(defaultCollisionRadius * sz)
	$Sprite.apply_scale(Vector2(sz, sz))
	position = position + 1.1 * direction * $CollisionShape2D.shape.get_radius() + spawnDistance
	$AnimationPlayer.play("Bullet")

func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	if collision != null:
		if collision.collider.name == "Player":
			print("Player hit by bullet")
			collision.collider.takeDamage(damage)
			free()
		elif collision.collider.name == "AttackCone":
			var angle = collision.collider.get_rotation()
			direction = Vector2(cos(angle), sin(angle))
			playerBullet = true
		elif collision.collider.get_class().begins_with("Enemy"):
			print(collision.collider.name + " hit")
			collision.collider.takeDamage(damage)
			free()
		elif collision.collider.get_class() == "Bullet":
			#player bullets dont collide with each other
			#player bullets survive enemy bullets
			#TODO see if this is fun, otherwise just let the larger one survive
			if playerBullet and not collision.collider.playerBullet:
				collision.collider.free()
			elif not playerBullet and collision.collider.playerBullet:
				free()
			elif collision.collider.size > size:
				free()
			elif collision.collider.size < size:
				collision.collider.free()
		else:
			print("Bullet hit " + collision.collider.get_class())
			free()
