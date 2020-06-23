extends Node2D

signal spawnPowerup(tile)
signal enemyKilled()
var bullet = preload("res://Scenes/Enemies/Bullet.tscn")
var hunter = preload("res://Scenes/Enemies/Hunter.tscn")
var turret = preload("res://Scenes/Enemies/Turret.tscn")
var enemies = []
var enemiesToDelete = []
var player
var enemyCount
var rootNode
var enemyRemovalTimer

func _ready():
	rootNode = get_parent()
	enemyRemovalTimer = Timer.new()
	enemyRemovalTimer.name = "enemyRemovalTimer"
	add_child(enemyRemovalTimer)
	connect("enemyRemovalTimer", self, "_on_Timer_timeout")

func enemyDied(enemy):
	enemiesToDelete.append(enemy)
	emit_signal("enemyKilled")
	enemyRemovalTimer.start(1.5)

func fillStageWithEnemies(map, level):
	var powerupsPerStage = 3
	var enemySaturation = 0.5 + 0.1 * level
	if enemySaturation > 1:
		enemySaturation = 1
	map.shuffle()
	for i in range(powerupsPerStage):
		var chosenTileName = map.pop_front()
		emit_signal("spawnPowerup", chosenTileName)
	for i in range(map.size() * enemySaturation):
		var chosenTileName = map.pop_front()
		var rngEnemy = randi() % 2
		var rngAmount = randi() % 2 + level
		var tileVector = rootNode.splitNameIntoVector(chosenTileName)
		if rngEnemy == 0:
			createTurretFormation(tileVector, rngAmount)
			print("turrets spawned " + str(tileVector) + " " + str(rngAmount))
		else:
			createHunterFormation(tileVector, rngAmount)
			print("hunters spawned " + str(tileVector) + " " + str(rngAmount))

func prepareStage(p):
	player = p
	enemyCount = 0
	#unload previous enemys
	#TODO this will get fucked if i implemend visiting houses and returning to the same map
	for node in get_children():
		if node.name.begins_with("enemyRemovalTimer"):
			continue
		node.free()

#creates amt times turrets in random corners of the room
func createTurretFormation(tile, amt):
	randomize()
	var freeCorners = {0:true, 1:true, 2:true, 3:true}
	var cornerOffsets = {0:Vector2(0,-250), 1:Vector2(520,15), 2:Vector2(0,290), 3:Vector2(-540,45)}
	if amt > 4:
		amt = 4
	for i in range(amt):
		while true:
			var c = randi() % 4
			if freeCorners[c]:
				freeCorners[c] = false
				var t = createEnemy(tile, 1)
				t.position = t.position + cornerOffsets[c]
				break

#creates amt times hunters in a circular pattern in the room
func createHunterFormation(tile, amt):
	randomize()
	var freeCorners = {0:true, 1:true, 2:true, 3:true}
	var cornerOffsets = {0:Vector2(0,-250), 1:Vector2(520,15), 2:Vector2(0,290), 3:Vector2(-540,45)}
	if amt > 5:
		amt = 5
	if amt == 1:
		createEnemy(tile, 0)
		return
	var angle = randf() * 2 * PI
	var l = 200
	for i in range(amt):
		var h = createEnemy(tile, 0)
		h.position = h.position + Vector2(l * cos(angle), l * sin(angle))
		angle = angle + (2 * PI) / amt

func createEnemy(tile, type):
	var e
	if type == 0:
		e = hunter.instance()
	elif type == 1:
		e = turret.instance()
	e.position = rootNode.isoToScreen(rootNode.tileToIso(tile))
	e.tile = tile
	e.visible = false
	e.informOfPlayer(player)
	e.name = rootNode.mergeVectorToName(tile) + "_" + str(enemyCount)
	enemyCount = enemyCount + 1
	add_child(e)
	return e

#player uncovered a new tile, activate enemies
func _on_Player_notifyMapOfBorderHit(tile, border):
	for enemy in get_children():
		if enemy.name.begins_with(tile.name):
			enemy.setActive(true)

func _on_Player_notifyEnemyControllerOfBulletsShot(direction, speed, size, spawnDistance):
	var b = bullet.instance()
	b.position = player.position
	b.playerBullet = true
	b.z_index = player.z_index
	b.create(direction, speed, size, spawnDistance)
	add_child(b)

func _on_Timer_timeout():
	for i in enemiesToDelete:
		i.visible = false
		i.free()