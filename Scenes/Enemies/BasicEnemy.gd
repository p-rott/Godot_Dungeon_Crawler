extends KinematicBody2D

var active = false
var player
var tile
var health = 100

func takeDamage(amount):
	print(name + " took damage")
	health = health - amount
	if health <= 0:
		print(name + " is ded")
		get_parent().enemyDied(self)
		$CollisionShape2D.disabled = true

func _ready():
	pass

func _process(delta):
	if not active or player.health <= 0 or health <= 0:
		return
	act(checkLineOfSight())

func act(canSeeEnemy):
	pass

#raycast to player
func checkLineOfSight():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(player.position, position, [], 1)
	if result.size() > 0 and result["collider"].get_class().begins_with("Enemy"):
		return true
	else:
		return false

func setActive(b):
	active = b
	visible = true

func informOfPlayer(p):
	player = p
