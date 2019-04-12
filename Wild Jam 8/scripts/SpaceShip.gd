extends KinematicBody

const ACCELERATION = 0.5
const DECELERATION = 0.5


onready var cameraLook = get_node("CameraLookat")
onready var camera = get_node("CameraLookat/Camera")

var direction2D = Vector2()
var direction3D = Vector3()
var moveSpeed = 200
var velocity = Vector3()
var yaw = 0
var pitch = 0
var ViewSensitivity = 0.2

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	var forward = Input.is_action_pressed("forward")
	var backward = Input.is_action_pressed("backward")
	var left = Input.is_action_pressed("left")
	var right = Input.is_action_pressed("right")
	
	if forward:
		pass
	if backward:
		pass
	if left:
		pass
	if right:
		pass
	
	direction2D = Vector2()
	direction3D = Vector3()
	
	direction2D = direction2D.normalized()
	direction3D += global_transform.basis.z.normalized() * direction2D.y
	direction3D += global_transform.basis.x.normalized() * direction2D.x
	
	## Acceleration and Retardation
	var hVel = velocity
	hVel.y = 0
	var target = direction3D * moveSpeed
	var acceleration
	if direction3D.dot(hVel) > 0:
		acceleration = ACCELERATION
	else:
		acceleration = DECELERATION
	
	hVel = hVel.linear_interpolate(target, acceleration * moveSpeed * delta)
	velocity.x = hVel.x
	velocity.z = hVel.z
	
	# Only move if camera is not rotating and not rooted and not zoomed
	velocity = move_and_slide(velocity)
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw = yaw - event.relative.x * ViewSensitivity
		pitch = max(min(pitch - event.relative.y * ViewSensitivity, 90), -50)
		cameraLook.rotation = Vector3(deg2rad(pitch), deg2rad(yaw), 0)