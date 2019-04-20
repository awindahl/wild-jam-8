extends Spatial
 

func _on_Area_body_entered(body):
	if body.type == "PLAYER":
		body.distVar += 1000
		if body.moveSpeed < 200:
			body.moveSpeed += 20
		if body.fuelVar < 200:
			body.fuelVar += 20
		
		body.boost.play()
		queue_free()