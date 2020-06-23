extends Node2D

func setStats(level, killed):
	$Label.text = "Game over! You killed " + str(killed) + " enemies and reached level " + str(level) + "!"
