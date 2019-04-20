extends Spatial

var TYPE = "ASTEROID"

func _bullet_hit():
	$CollisionShape.disabled = true
	TYPE = null
	$AnimationPlayer.play("die")
	$Boom.play()

func _die():
	queue_free()