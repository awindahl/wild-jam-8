extends Spatial

func _on_Area_body_entered(body):
	
	if body.type == "PLAYER":
		get_tree().change_scene("res://Win.tscn")