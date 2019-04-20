extends KinematicBody

const ACCELERATION = 4
const DECELERATION = 1
const MAXSPEED = 140.0
const MINSPEED = 0.0
const MAXANGLE = 90
const MINANGLE = 60

onready var cameraLook = get_node("CameraLookat")
onready var camera = get_node("CameraLookat/Camera")
onready var model = get_node("Model")
onready var collider = get_node("CollisionShape")
onready var exhaust = get_node("Model/Particles")
onready var exhaust2 = get_node("Model/Particles2")
onready var exhaust3 = get_node("Model/Particles3")
onready var fuelText = get_node("UI/FuelVar")
onready var speedText = get_node("UI/SpeedVar")
onready var boost = get_node("Boost")
onready var distText = get_node("UI/DistVar")
onready var livesText = get_node("UI/LivesVar")

var distVar = 24000
var fuelVar = 100
var lives = 3

var laser = preload("res://Laser.tscn")

var direction2D = Vector2()
var direction3D = Vector3()
var moveSpeed = 0.0
var rotationSpeed = 1
var velocity = Vector3()
var yaw = 0
var pitch = 0
var ViewSensitivity = 0.05
var forward
var backward
var left
var right
var shoot
var canShoot = true
var type = "PLAYER"
var normal = Vector3()
var isKnocked
var canDie = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#camera.set_as_toplevel(true)

func _process(delta):
	
	forward = Input.is_action_pressed("forward")
	backward = Input.is_action_pressed("backward")
	left = Input.is_action_pressed("left")
	right = Input.is_action_pressed("right")
	shoot = Input.is_action_just_pressed("shoot")
	
	var aim = camera.get_camera_transform().basis
	var value = 0
	
	distVar -= 1
	distText.text = var2str(distVar)
	livesText.text = var2str(lives)
	
	if distVar == 0:
		_die()
	
	if lives < 0:
		forward = null
		aim = null
		shoot = null
		cameraLook = null
		#camera = null
		
	if lives < 0 and canDie:
		canDie = false
		$AnimationPlayer.play("die")
		forward = null
		
	
	rotationSpeed = 1
	#direction3D = Vector3()
	direction3D = -model.get_transform().basis[2]
	
	if forward and fuelVar > 1 and get_slide_count() <= 0:
		moveSpeed = lerp(moveSpeed, MAXSPEED, 0.01)
		camera.translation.z = lerp(camera.translation.z, MAXANGLE, moveSpeed/10000)
		fuelVar -= 0.1
		exhaust.visible = true
		exhaust2.visible = true
		exhaust3.visible = true
	elif canDie:
		moveSpeed = lerp(moveSpeed, MINSPEED, 0.001)
		camera.translation.z = lerp(camera.translation.z, MINANGLE, 1/(moveSpeed+1))
	if backward:
		#direction3D += model.get_transform().basis[2]
		moveSpeed = lerp(moveSpeed, MINSPEED, 0.04)
		exhaust.visible = false
		exhaust2.visible = false
		exhaust3.visible = false
	if left:
		#direction3D -= model.get_transform().basis[0]
		#if model.rotation_degrees.z < 90:
		model.rotation_degrees.z += 1 * moveSpeed/50
		collider.rotation_degrees.z += 1 * moveSpeed/50
		rotationSpeed = 2
	if right:
		#direction3D += model.get_transform().basis[0]
		#if model.rotation_degrees.z > -90:
		model.rotation_degrees.z -= 1 * moveSpeed/50
		collider.rotation_degrees.z -= 1 * moveSpeed/50
		rotationSpeed = 2
	
	if moveSpeed < 2 and not forward:
		moveSpeed = 0
		exhaust.visible = false
		exhaust2.visible = false
		exhaust3.visible = false
	
	if fuelVar < 100 and exhaust.visible == false:
		fuelVar += 0.1
	
	elif fuelVar < 1:
		fuelVar = 0
	
	speedText.text = var2str(int(floor(moveSpeed)))
	
	$Rocket.volume_db = (moveSpeed/12) - 15
	fuelText.text = var2str(fuelVar)
	
	if exhaust.visible == true and $Rocket.playing == false:
		$Rocket.play()
		#$Rocket.volume_db = moveSpeed/4 +10
	elif exhaust.visible == false:
		$Rocket.stop()
	
	if get_slide_count() > 0:
		if get_slide_collision(0) != null:
			if moveSpeed > 60:
				moveSpeed = 0
				isKnocked = true
				$Knockback.start()
				$Explode.play()
				lives -= 1
				normal = get_slide_collision(0).normal
			#direction3D = get_slide_collision(0).normal
			else:
				moveSpeed = 0
	
	if isKnocked:
		velocity = move_and_slide(normal*40)
	else:
		velocity = move_and_slide(direction3D*moveSpeed)
	
	if canDie:
		cameraLook.rotation.z = 0
		var rotationTarget = model.rotation.linear_interpolate(cameraLook.rotation, delta * rotationSpeed)
		model.rotation = rotationTarget
		collider.rotation = rotationTarget
	
	var newLaser = laser.instance()
	
	if shoot and canShoot and canDie:
		newLaser.global_transform = model.get_node("ShootRay").global_transform
		get_parent().add_child(newLaser)
		$Laser.play()
		canShoot = false
		$ShootTimer.start()

func _unhandled_input(event):
	if event is InputEventMouseMotion and canDie:
		yaw = yaw - event.relative.x * ViewSensitivity
		pitch = pitch - event.relative.y * ViewSensitivity
		cameraLook.rotation = Vector3(deg2rad(pitch), deg2rad(yaw), 0)

func _on_ShootTimer_timeout():
	canShoot = true

func _on_Knockback_timeout():
	isKnocked = false

func _die():
	get_tree().change_scene("res://GameOverCutscene.tscn")