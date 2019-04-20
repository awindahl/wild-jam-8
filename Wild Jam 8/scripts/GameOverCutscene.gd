extends Spatial

func _ready():
	$AnimationPlayer.play("spaghet")

func _gameover():
	get_tree().change_scene("res://GameOver.tscn")