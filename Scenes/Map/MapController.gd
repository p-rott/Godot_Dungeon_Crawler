extends Node2D

onready var defaultTile = preload("res://Scenes/Map/Tile.tscn")
signal sendMessageToPlayer(message)
var isTileDiscovered = {}
var showAll = false
var rootNode
var tutorialMode = true
var tileGoal = 12
var splitRatio = 4
var exitLocation
var keyLocation

func reset():
	isTileDiscovered = {}
	showAll = false
	rootNode
	tutorialMode = true

func _ready():
	rootNode = get_parent()

func disableShader(tile):
	tile.get_material().set_shader_param("lightFactor", 0.7)

func createTutorialMap(theme):
	disableShader(createTile(Vector2(0, 0), theme))
	createTile(Vector2(0, 1), theme).generatePickup()
	createTile(Vector2(1, 1), theme)
	createTile(Vector2(2, 1), theme).generateExit()
	createTile(Vector2(3, 1), theme).generateKey()
	generateWalls()
	return Vector2(0, 0)

func findFurthestTileFromTile(start):
	var dist = 0
	var chosenTileName
	for tileName in isTileDiscovered:
		var currentDist = rootNode.splitNameIntoVector(tileName).distance_to(start)
		if currentDist > dist:
			dist = currentDist
			chosenTileName = tileName
	return get_node(chosenTileName)

func createMapAndGetSpawn(theme):
	#get rid of tutorial message
	emit_signal("sendMessageToPlayer", "")
	randomize()
	tileGoal = 12
	splitRatio = 4
	var current = Vector2(0, 0)
	var next = Vector2(0, 0)
	var tries = 0
	#create tile 0,0 and unhide it
	disableShader(createTile(current, theme))
	while tileGoal > 0:
		if tileGoal%splitRatio == 0 and tries < 8:
			current = Vector2(0, 0)
		#get dir of new tile
		next.x = current.x
		next.y = current.y
		var dir = randi() % 4
		if dir == 0:
			next.y = next.y - 1;
		if dir == 1:
			next.x = next.x + 1;
		if dir == 2:
			next.y = next.y + 1;
		if dir == 3:
			next.x = next.x - 1;
		#check if next planned tile already exists, if so skip
		if isTileDiscovered.has(rootNode.mergeVectorToName(next)):
			tries = tries + 1
			if tries >= 8:
				#fix so generation doesnt get stuck
				var choices = isTileDiscovered.keys()
				current = rootNode.splitNameIntoVector(choices[randi() % choices.size()])
			continue
		#create new tile
		else:
			tries = 0
			var tile = createTile(next, theme)
			tileGoal = tileGoal - 1
			current.x = next.x
			current.y = next.y
	generateWalls()
	var exit = findFurthestTileFromTile(Vector2(0, 0))
	exitLocation = exit.name
	exit.generateExit()
	var key = findFurthestTileFromTile(rootNode.splitNameIntoVector(exit.name))
	keyLocation = key.name
	key.generateKey()
	return Vector2(0, 0)

#generates walls and collisions as outer border for the map
func generateWalls():
	var count = 0
	for tileName in isTileDiscovered.keys():
		var tileVector = rootNode.splitNameIntoVector(tileName)
		#check all 4 directions for neighboring tiles
		#create wall if there is none
		var node = get_node(tileName)
		if not isTileDiscovered.has(rootNode.mergeVectorToName(tileVector + Vector2(0, -1))):
			node.createWall(0)
			count = count + 1
		if not isTileDiscovered.has(rootNode.mergeVectorToName(tileVector + Vector2(1, 0))):
			node.createWall(1)
			count = count + 1
		if not isTileDiscovered.has(rootNode.mergeVectorToName(tileVector + Vector2(0, 1))):
			node.createWall(2)
			count = count + 1
		if not isTileDiscovered.has(rootNode.mergeVectorToName(tileVector + Vector2(-1, 0))):
			node.createWall(3)
			count = count + 1
	print("Created " + str(count) + " walls")

func createTile(v, theme):
	var tile = defaultTile.instance()
	tile.z_index = v.x + 15 * v.y
	add_child(tile)
	tile.applyTheme(theme)
	tile.position = Vector2(672 * v.x - 672 * v.y, 336 * v.x + 336 * v.y)
	var name = rootNode.mergeVectorToName(v)
	isTileDiscovered[name] = showAll
	tile.set_name(name)
	return tile

func _on_Player_notifyMapOfBorderHit(tile, border):
	isTileDiscovered[tile.name] = true
	tile.get_node(border).disabled = true
	tile.showItems()
	tile.playAnimations()
	disableShader(tile)
	disableBorderIfTileAhead(tile)
	if tutorialMode:
		showTutorial(rootNode.splitNameIntoVector(tile.name))

func disableBorderIfTileAhead(tile):
	var v = rootNode.splitNameIntoVector(tile.name)
	if isTileDiscovered.has(str(v.x + 1) + "_" + str(v.y)):
		tile.disableBorders(false, true, false, false)
	if isTileDiscovered.has(str(v.x - 1) + "_" + str(v.y)):
		tile.disableBorders(false, false, false, true)
	if isTileDiscovered.has(str(v.x) + "_" + str(v.y + 1)):
		tile.disableBorders(false, false, true, false)
	if isTileDiscovered.has(str(v.x) + "_" + str(v.y - 1)):
		tile.disableBorders(true, false, false, false)

func showTutorial(tile):
	var message = ""
	if tile == Vector2(0, 1):
		message = "i seem to be lost"
	if tile == Vector2(1, 1):
		message = "this thing probably shouldn't touch me"
	if tile == Vector2(2, 1):
		message = "i wonder what i can find in there"
	if tile == Vector2(3, 1):
		pass
		#message = "lucky me, almost as if this was a tutorial"
	emit_signal("sendMessageToPlayer", message)

func clearMap():
	for tileName in isTileDiscovered.keys():
		var node = get_node(tileName)
		if not node == null:
			node.free()
	isTileDiscovered.clear()

func getMapForEnemySpawning():
	var array = isTileDiscovered.keys()
	array.erase("0_0")
	array.erase(exitLocation)
	array.erase(keyLocation)
	return array

func _on_EnemyController_spawnPowerup(tileName):
	get_node(tileName).generatePickup()

"""
func createOuterBorders():
	get_node("0_0").createWall(0)
	get_node("0_0").createWall(3)
	get_node("0_1").createWall(3)
	get_node("0_2").createWall(3)
	get_node("0_2").createWall(2)
	get_node("1_0").createWall(0)
	get_node("1_2").createWall(2)
	get_node("2_0").createWall(0)
	get_node("2_0").createWall(1)
	get_node("2_1").createWall(1)
	get_node("2_2").createWall(2)
	get_node("2_2").createWall(1)

func createPresetAndReturnSpawn():
	randomize()
	var r = randi() % 3
	var s = randi() % 2
	if r == 0:
		get_node("2_0").createWall(3)
		get_node("1_0").createWall(1)
		get_node("2_1").createWall(3)
		get_node("1_1").createWall(1)
		get_node("0_1").createWall(1)
		get_node("0_1").createWall(2)
		get_node("0_2").createWall(0)
		get_node("1_1").createWall(3)
		if s == 0:
			get_node("0_1").generateExit()
		else:
			get_node("2_0").generateExit()
		return Vector2(1, 1)
	if r == 1:
		get_node("0_0").createWall(1)
		get_node("1_0").createWall(3)
		get_node("1_0").createWall(1)
		get_node("2_0").createWall(3)
		get_node("0_1").createWall(1)
		get_node("1_1").createWall(3)
		get_node("2_1").createWall(2)
		get_node("2_2").createWall(0)
		if s == 0:
			get_node("0_0").generateExit()
		else:
			get_node("2_2").generateExit()
		return Vector2(1, 0)
	if r == 2:
		get_node("0_1").createWall(1)
		get_node("1_1").createWall(3)
		get_node("0_1").createWall(2)
		get_node("0_2").createWall(0)
		get_node("2_1").createWall(3)
		get_node("1_1").createWall(1)
		get_node("2_1").createWall(2)
		get_node("2_2").createWall(0)
		if s == 0:
			get_node("0_1").generateExit()
		else:
			get_node("2_1").generateExit()
		return Vector2(0, 2)


func createMapAndGetSpawn(theme):
	print("aaaaaaaa")
	for x in range(3):
		for y in range(3):
			var tile = defaultTile.instance()
			tile.position = Vector2(672 * x - 672 * y, 336 * x + 336 * y)
			isTileDiscovered[str(x)+"_"+str(y)] = showAll
			tile.visible = showAll
			#if x == 0 and y == 0:
			tile.set_name(str(x)+"_"+str(y))
			add_child(tile)
	createOuterBorders()
	#make spawn tile visible
	#var spawn = createPresetAndReturnSpawn()
	var spawn = Vector2(1,1)
	isTileDiscovered[str(spawn.x)+"_"+str(spawn.y)] = true
	get_node(str(spawn.x)+"_"+str(spawn.y)).visible = true
	get_node(str(spawn.x)+"_"+str(spawn.y)).disableBorders(false, true, true, false)
	return spawn

"""