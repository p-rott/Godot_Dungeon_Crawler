extends Node2D

onready var exit = preload("res://Scenes/Map/Exit.tscn")
onready var key = preload("res://Items/Key.tscn")
onready var pickup = preload("res://Items/Pickup.tscn")
onready var ground = $Ground
onready var rock = $Rocks
onready var plant = $Plants
onready var block = $Blocks
var allowed = []
var allowedWall = []
var done = false
var theme 
var pointOfInterest

func showItems():
	if not(pointOfInterest == null) and (pointOfInterest.get_class() == "Key" or pointOfInterest.get_class() == "Pickup"):
		 pointOfInterest.visible = true

func playAnimations():
	if not pointOfInterest == null:
		pointOfInterest.playAnimations()

func createWall(dir):
	var xValues = Vector2()
	var yValues = Vector2()
	if dir == 0:
		xValues = Vector2(0, 21)
		yValues = Vector2(0, 1)
		addWallCollision(Vector2(-30, 20), Vector2(640, 350))
	if dir == 1:
		xValues = Vector2(20, 21)
		yValues = Vector2(0, 21)
		addWallCollision(Vector2(635, 320), Vector2(-30, 660))
	if dir == 2:
		xValues = Vector2(0, 21)
		yValues = Vector2(20, 21)
		addWallCollision(Vector2(30, 660), Vector2(-640, 325))
	if dir == 3:
		xValues = Vector2(0, 1)
		yValues = Vector2(0, 21)
		addWallCollision(Vector2(22, 20), Vector2(-640, 350))
	for y in range(yValues.x, yValues.y):
		for x in range(xValues.x, xValues.y):
			if theme == 0:
				var i = randi() % 4
				rock.set_cell(x,y,0,false,false,false, Vector2(i,0))
			elif theme == 1:
				var i = randi() % 2
				if i == 0:
					block.set_cell(x,y,0,false,false,false, Vector2(6,0))
				else:
					block.set_cell(x,y,0,false,false,false, Vector2(5,0))
			else:
				print("no theme for walls set " + str(theme))

func addWallCollision(a, b):
	var shape = SegmentShape2D.new()
	shape.set_a(a)
	shape.set_b(b)
	var collision = CollisionShape2D.new()
	collision.set_shape(shape)
	collision.set_disabled(false)
	add_child(collision)

func generatePickup():
	var p = pickup.instance()
	p.position = Vector2(0, 320)
	p.visible = false
	add_child(p)
	pointOfInterest = p

func generateExit():
	var e = exit.instance()
	add_child(e)
	pointOfInterest = e

func generateKey():
	var k = key.instance()
	k.visible = false
	k.position = Vector2(0, 320)
	add_child(k)
	pointOfInterest = k

func disableBorders(a, b, c, d):
	if a:
		get_node("BorderTopRight").disabled = true
	if b:
		get_node("BorderBottomRight").disabled = true
	if c:
		get_node("BorderBottomLeft").disabled = true
	if d:
		get_node("BorderTopLeft").disabled = true

func placeGroundTiles(x,y):
	for xi in range(0, x):
		for yi in range(0, y):
			var i = randi() % allowed.size()
			var tileNr = 0
			if xi > x/2:
				tileNr = 4
			ground.set_cell(xi,yi,tileNr,false,false,false, allowed[i])

func placePlants():
	var tileSet = plant.tile_set
	var rect = tileSet.tile_get_region(0)
	for xi in range(1, 19):
		for yi in range(1, 19):
			var tileNr = 0
			if randi() % 10 < 1:
				var x = randi() % int(rect.size.x / tileSet.autotile_get_size(0).x)
				var y = randi() % int(rect.size.y / tileSet.autotile_get_size(0).y)
				plant.set_cell(xi, yi, 0,false,false,false, Vector2(x, y))

func placeRocks():
	var tileSet = rock.tile_set
	var rect = tileSet.tile_get_region(0)
	for xi in range(1, 19):
		for yi in range(1, 19):
			var tileNr = 0
			if randi() % 10 < 1:
				var x = randi() % int(rect.size.x / tileSet.autotile_get_size(0).x)
				var y = randi() % int(rect.size.y / tileSet.autotile_get_size(0).y)
				rock.set_cell(xi, yi, 0,false,false,false, Vector2(x, y))

func applyTheme(th):
	theme = th
	if theme == 0:
		useGrassTiles()
		placePlants()
	elif theme == 1:
		useCaveTiles()
		placeRocks()
	elif theme == 2:
		print("theme not planned")
		var b = 0
		var a = 1/b
	placeGroundTiles(41, 21)

func useCaveTiles():
	allowed.append(Vector2(0,0))
	allowed.append(Vector2(1,1))
	allowed.append(Vector2(2,2))
	allowed.append(Vector2(4,4))
	#allowed.append(Vector2(0,5)) #ehhh
	allowed.append(Vector2(5,5))
	#allowed.append(Vector2(7,5)) #ehhhhhhhh

func useGrassTiles():
	#allowed.append(Vector2(0,0))
	allowed.append(Vector2(1,0))
	allowed.append(Vector2(1,1))
	allowed.append(Vector2(1,2))
	allowed.append(Vector2(1,1))
	allowed.append(Vector2(1,2))
	allowed.append(Vector2(2,1))
	allowed.append(Vector2(2,2))
	allowed.append(Vector2(2,3))
	allowed.append(Vector2(4,4))
	allowed.append(Vector2(6,4))
	allowed.append(Vector2(0,5))
	allowed.append(Vector2(4,5))
	#allowed.append(Vector2(5,5))
	#allowed.append(Vector2(6,5))
	#allowed.append(Vector2(7,5))
