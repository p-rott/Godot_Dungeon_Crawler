extends KinematicBody2D

signal notifyMapOfBorderHit(tile, border)
signal notifygameOfExitHit()
signal notifygameOfGameOver()
signal notifyEnemyControllerOfBulletsShot(direction, speed, size, spawnDistance)
var movespeed = 350
var rootNode
var hasKey = false
var abilityPoints = 0
var coneCooldown = 1
var health = 100
var killed = 0

func regenerateHealth():
	health = health + 35
	if health > 100:
		health = 100

func reset():
	movespeed = 350
	hasKey = false
	abilityPoints = 10
	health = 100
	killed = 0
	$CollisionShape2D.disabled = false
	var gui = get_node("GameOver")
	if gui != null:
		gui.queue_free()
	rootNode = get_parent()
	$AttackCone.name = "AttackCone"
	$AnimationPlayer.play("Idle")

func _ready():
	reset()

func checkInput():
	var movement = Vector2()
	if Input.is_action_pressed("ui_left"):
		movement.x -= movespeed
		$Animations.flip_h = true
	if Input.is_action_pressed("ui_right"):
		movement.x += movespeed
		$Animations.flip_h = false
	if Input.is_action_pressed("ui_up"):
		movement.y -= movespeed
	if Input.is_action_pressed("ui_down"):
		movement.y += movespeed
	if movement.length() > 0:
		$AnimationPlayer.play("Walking")
	else:
		$AnimationPlayer.play("Idle")
	if Input.is_action_just_pressed("ui_click"):
		#create collision cone to reflect bullets
		processAttackCone()
	if Input.is_action_just_pressed("ui_click_right"):
		#use abilit
		useAbility()
	if Input.is_action_just_pressed("ui_select"):
		printPlayerDebug()
	return movement

func useAbility():
	if abilityPoints <= 0:
		return
	abilityPoints = abilityPoints - 1
	var mouse = get_viewport().get_mouse_position() 
	var center = get_viewport().get_size() / 2
	var angle = atan2(mouse.y - center.y, mouse.x - center.x)
	$AudioAbility.play()
	for i in range(-1, 2):
		var angleOffset = PI / 30 * i
		#var b = bullet.instance()
		var direction = Vector2(cos(angle + angleOffset), sin(angle + angleOffset))
		#b.create(direction, 200, 1, (direction * $CollisionShape2D.shape.get_radius()))
		emit_signal("notifyEnemyControllerOfBulletsShot", direction, 200, 1, (direction * $CollisionShape2D.shape.get_radius() * 1.5))

func processAttackCone():
	if $AttackCone/ConeCooldownTimer.is_stopped():
		$AudioReflect.play()
		var mouse = get_viewport().get_mouse_position() 
		var center = get_viewport().get_size() / 2
		$AttackCone.set_rotation(atan2(mouse.y - center.y, mouse.x - center.x))
		$AttackCone/AnimationPlayer.play("Bogen")
		$AttackCone/ConeCooldownTimer.start(coneCooldown)
		$Animations.get_material().set_shader_param("lightFactor", 1.4)

func printPlayerDebug():
	var pos = position
	print("Player Position " + str(pos))

func setPlayerPosition(v):
	position = rootNode.isoToScreen(rootNode.tileToIso(v))

func takeDamage(damage):
	health = health - damage
	$AudioHit.play()
	if health <= 0:
		$AnimationPlayer.play("Death")
		emit_signal("notifygameOfGameOver")
		displayMessage("")
		$CollisionShape2D.disabled = true

#TODO handle collision with bullet
func _physics_process(delta):
	if health <= 0:
		return
	var collision = move_and_collide(checkInput() * delta)
	if collision != null:
		if collision.collider.get_class() == "Exit":
			if hasKey:
				$AudioExit.play()
				emit_signal("notifygameOfExitHit")
			else:
				displayMessage("looks like i need a key")
		elif collision.collider.get_class() == "Key":
			hasKey = true
			$AudioKey.play()
			collision.collider.free()
		elif collision.collider.get_class() == "Bullet":
			#TODO player damage logic
			takeDamage(collision.collider.damage)
			print("Player hit by bullet")
			collision.collider.free()
		elif collision.collider.get_class() == "Pickup":
			abilityPoints = abilityPoints + collision.collider.amount
			collision.collider.free()
		elif collision.collider_shape.name.begins_with("Border"):
			emit_signal("notifyMapOfBorderHit", collision.collider, collision.collider_shape.name)
		else:
			pass
			#print("Player hit: " + collision.collider.get_class())

func _on_MapController_sendMessageToPlayer(message):
	displayMessage(message)

func displayMessage(message):
	if not message == $CenterContainer/Label.text:
		$CenterContainer/Label.text = message
		$CenterContainer/Label.visible_characters = 0
		$MessageDisplayTimer.start(0.08)

func _on_Timer_timeout():
	if $CenterContainer/Label.percent_visible < 1:
		$CenterContainer/Label.visible_characters = $CenterContainer/Label.visible_characters + 1 
	else:
		$MessageDisplayTimer.stop()

func _on_ConeCooldownTimer_timeout():
	$AttackCone/ConeCooldownTimer.stop()
	$Animations.get_material().set_shader_param("lightFactor", 1)

func _on_EnemyController_enemyKilled():
	killed = killed + 1
