extends Node2D

onready var ground = $Ground
onready var rock = $Rocks
onready var tree = $Trees
var allowed = []


func showAllowed():
	for y in range(0, allowed.size()):
		ground.set_cell(-3,y,0,false,false,false, allowed[y])
		ground.set_cell(-4,y,0,false,false,false, allowed[y])

func showAllowedAllTiles():
	#for t in range(0, 4, 2):
	for t in [0,4]:
		for y in range(0, allowed.size()):
			ground.set_cell(t/4-3,y-3,t,false,false,false, allowed[y])
			ground.set_cell(t/4-3,y-3,t,false,false,false, allowed[y])

func placeGroundTiles(x,y):
	for xi in range(0, x):
		for yi in range(0, y):
			var i = randi() % allowed.size()
			var tileNr = 0
			if xi > x/2:
				tileNr = 4
			ground.set_cell(xi,yi,tileNr,false,false,false, allowed[i])

func placeCustomTiles(x,y,chance,tiles):
	var tileSet = tiles.tile_set
	var rect = tileSet.tile_get_region(0)
	for xi in range(0, x):
		for yi in range(0, y):
			var i = randi() % 100
			if i < chance:
				var xt = randi() % int(rect.size.x / tileSet.autotile_get_size(0).x)
				var yt = randi() % int(rect.size.y / tileSet.autotile_get_size(0).y)
				tiles.set_cell(xi,yi,0,false,false,false, Vector2(xt,yt))

func _ready():
	fillAllowed()
	showAllowedAllTiles()
	#showAllowed()
	var tileSet = ground.tile_set
	var rect = tileSet.tile_get_region(0)
	var x = 50 #int(rect.size.x / tile_set.autotile_get_size(0).x)
	var y = 50 #int(rect.size.y / tile_set.autotile_get_size(0).y)
	placeGroundTiles(x,y)
	placeCustomTiles(x,y,5,rock)
	placeCustomTiles(x,y,15,tree)

func _get_subtile_coord(id):
	var tileSet = ground.tile_set
	var rect = tileSet.tile_get_region(id)
	var x = randi() % int(rect.size.x / tileSet.autotile_get_size(id).x)
	var y = randi() % int(rect.size.y / tileSet.autotile_get_size(id).y)
	return Vector2(x, y)

func fillAllowed():
	#allowed.append(Vector2(0,0))
	#allowed.append(Vector2(1,0))
	allowed.append(Vector2(1,1))
	#allowed.append(Vector2(1,2))
	allowed.append(Vector2(1,1))
	#allowed.append(Vector2(1,2))
	allowed.append(Vector2(2,1))
	#allowed.append(Vector2(2,2))
	#allowed.append(Vector2(2,3))
	allowed.append(Vector2(4,4))
	allowed.append(Vector2(6,4))
	allowed.append(Vector2(0,5))
	allowed.append(Vector2(4,5))
	#allowed.append(Vector2(5,5))
	#allowed.append(Vector2(6,5))
	#allowed.append(Vector2(7,5))

func fillAllowedAll():
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
