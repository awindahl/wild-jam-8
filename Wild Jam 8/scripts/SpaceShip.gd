extends KinematicBody

const ACCELERATION = 1
const DECELERATION = 1


onready var cameraLook = get_node("CameraLookat")
onready var camera = get_node("CameraLookat/Camera")
onready var model = get_node("Model")
onready var collider = get_node("CollisionShape")

var direction2D = Vector2()
var direction3D = Vector3()
var moveSpeed = 50
var velocity = Vector3()
var yaw = 0
var pitch = 0
var ViewSensitivity = 0.05
var forward
var backward
var left
var right

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#camera.set_as_toplevel(true)

func _process(delta):
	forward = Input.is_action_pressed("forward")
	backward = Input.is_action_pressed("backward")
	left = Input.is_action_pressed("left")
	right = Input.is_action_pressed("right")
	var aim = camera.get_camera_transform().basis
	var value = 0
	
	direction3D = Vector3()
	
	if forward:
		direction3D -= model.get_transform().basis[2]
	if backward:
		direction3D += model.get_transform().basis[2]
	if left:
		direction3D -= model.get_transform().basis[0]
		if model.rotation_degrees.z < 45:
			model.rotation_degrees.z += 1
	if right:
		direction3D += model.get_transform().basis[0]
		if model.rotation_degrees.z < -45:
			model.rotation_degrees.z -= 1
	
	
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
	velocity.y = hVel.y

	velocity = move_and_slide(velocity)
	model.rotation = model.rotation.linear_interpolate(cameraLook.rotation, delta)
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw = yaw - event.relative.x * ViewSensitivity
		pitch = pitch - event.relative.y * ViewSensitivity
		cameraLook.rotation = Vector3(deg2rad(pitch), deg2rad(yaw), 0)