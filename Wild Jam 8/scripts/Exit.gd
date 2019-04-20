extends Button


func _on_Exit_mouse_entered():
	$blip2.play()
	

func _on_Exit_pressed():
	get_tree().quit()