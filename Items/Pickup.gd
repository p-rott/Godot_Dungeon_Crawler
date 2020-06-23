extends StaticBody2D

var amount = 3

func get_class():
	return "Pickup"

func playAnimations():
	$Sprite.visible = true
	$AnimationPlayer.play("Pickup")
