extends Button

func _on_Demo_mouse_entered():
	$blip.play()

func _on_Demo_pressed():
	$click.play()
	get_tree().change_scene("res://Space.tscn")