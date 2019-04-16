extends Spatial

var BULLET_SPEED = 180

const KILL_TIMER = 12
var timer = 0
var forward_dir

func _ready():
	$Area.connect("body_entered", self, "_collided")
	forward_dir = get_parent().get_node("SpaceShip/Model/ShootRay").get_global_transform().basis.z.normalized() * -1

func _physics_process(delta):
	var parentSpeed = get_parent().get_node("SpaceShip").moveSpeed
	BULLET_SPEED += parentSpeed/10
	global_translate(forward_dir * BULLET_SPEED * delta)
	timer += delta
	if timer >= KILL_TIMER:
		queue_free()
		pass

func _on_Area_body_entered(body):
	if body.get("TYPE") == "ENEMY":
		body._bullet_hit()