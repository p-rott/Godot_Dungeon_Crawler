extends Node2D
onready var gameOverGUI = preload("res://Scenes/GameOver.tscn")
# IDEAS
# FIRE, can spread and maybe be put out with shockwave
# Turrets/Enemies can teleport if to close/etc
# Bullet pattern variations regarding spread/speed/chargeup
# Bullet effects: slowing, starting fire, freezing
# Enemy effects: Spells
# Powerups: Increase primary range/duration - secondary speed, size, damage
# Display health/ammo as fading of character/switching of lights on character

var currentLevel = 0
var theme = 0

func _ready():
	generateNewLevel(theme)
	$AudioMusic.play()
	#$EnemyController.createTurretFormation(Vector2(0, 1), 4)
	#$EnemyController.createHunterFormation(Vector2(0, 1), 5)

func generateNewLevel(theme):
	$Player.hasKey = false
	$MapController.clearMap()
	$EnemyController.prepareStage($Player)
	var spawn
	if currentLevel == 0:
		spawn = createTutorial()
	else:
		spawn = $MapController.createMapAndGetSpawn(theme)
		$MapController.tutorialMode = false
		$EnemyController.fillStageWithEnemies($MapController.getMapForEnemySpawning(), currentLevel)
	print("Level " + str(currentLevel) + " Theme " + str(theme) + " Spawn " + str(spawn))
	$Player.setPlayerPosition(spawn)

func createTutorial():
	var spawn = $MapController.createTutorialMap(theme)
	$EnemyController.createTurretFormation(Vector2(1, 1), 2)
	#$EnemyController.createEnemy(Vector2(1, 1), 0)
	#$EnemyController.createEnemy(Vector2(1, 1), 1)
	return spawn

func _on_Player_notifygameOfExitHit():
	currentLevel = currentLevel + 1
	if currentLevel > 3:
		theme = 1
	generateNewLevel(theme)

#coordinate stuff
func splitNameIntoVector(name):
	var x = int(name.substr(0, name.find("_")))
	var y = int(name.substr(name.find("_") + 1, name.length()))
	return Vector2(x, y)

func mergeVectorToName(v):
	return str(v.x)+"_"+str(v.y)

func isoToTile(v):
	return Vector2(floor(v.x/20), floor(v.y/20))

func tileToIso(v):
	return Vector2(10 + v.x * 20, 10 + v.y * 20)

func screenToIso(v):
	var x = 0.5 * ( v.x / 32 + v.y / 16)
	var y = 0.5 * (-v.x / 32 + v.y / 16)
	return Vector2(x, y)

func isoToScreen(v):
	var x = (v.x - v.y) * 32;
	var y = (v.x + v.y) * 32 / 2;
	return Vector2(x, y)


func _on_Player_notifygameOfGameOver():
	print("game over hit")
	var gui = gameOverGUI.instance()
	gui.get_node("Button").connect("pressed", self, "restart_game_signal")
	gui.setStats(currentLevel, $Player.killed)
	$Player.add_child(gui)

func restart_game_signal():
	currentLevel = 0
	theme = 0
	generateNewLevel(theme)
	print("restart hit")
	$MapController.reset()
	$Player.reset()