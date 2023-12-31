extends CharacterBody2D

const BASE_SPEED = 300.0
# Enum represents the direction the Runner is facing.
enum {UP, DOWN, LEFT, RIGHT}

# To be expanded later.
enum {IDLE, WALKING}

# Can be changed
var current_state = movement_state.new(UP, IDLE)

class movement_state:
	# :NOTE: Access modifiers for classes in GDScript are public by default.
	# That is fine for this use case as I want a struct essentially.
	func _init(Direction, State): 
		direction = Direction
		state = State
		
	# :NOTE: I would like to statically type these to be their respective enums.
	# However currently enums aren't considered types in GDScript. 
	# https://github.com/godotengine/godot/issues/20368
	var direction
	var state
	
	# This function updates the direction and state given a Vector2 of a 
	# newDirection
	func update_state(new_direction: Vector2):
		if(new_direction != Vector2.ZERO):
			state = WALKING
			if(new_direction.x > 0):
				direction = RIGHT
			elif(new_direction.x < 0):
				direction = LEFT
			elif(new_direction.y > 0):
				direction = DOWN
			elif(new_direction.y < 0):
				direction = UP
		else:
			# We keep the previous direction so that the idle animation faces 
			# the correct direction.
			state = IDLE

func _physics_process(_delta):
	
	velocity = Input.get_vector("left","right", "up", "down") * BASE_SPEED
	
	# :NOTE: An argument could be made here that Input.get_vector should be used
	# instead depending on velocity regarding animations we want in the future.
	# Currently I'm thinking we stay with velocity as if we allow signals to 
	# change the player's velocity (such as when they take a hit) then it'd be 
	# Best if we use velocity to determine which animation to take based on
	# the player's final movement direction.
	current_state.update_state(velocity)
	if(current_state.state == WALKING):	
		match(current_state.direction):
			RIGHT:
				$AnimatedSprite2D.play("WalkRight")
			LEFT:
				$AnimatedSprite2D.play("WalkLeft")
			DOWN:
				$AnimatedSprite2D.play("WalkDown")
			UP:
				$AnimatedSprite2D.play("WalkUp")
	else: # The player is idling, choose the correct idle animation to match.
		assert(current_state.state == IDLE)
		# Prove that $AnimatedSprite2D is not a null instance
		assert(is_instance_valid($AnimatedSprite2D))
		match(current_state.direction):
			RIGHT:
				$AnimatedSprite2D.play("IdleRight")
			LEFT:
				$AnimatedSprite2D.play("IdleLeft")
			DOWN:
				$AnimatedSprite2D.play("IdleDown")
			UP:
				$AnimatedSprite2D.play("IdleUp")
	
	# :NOTE:
	# delta is automatically incorporated in move_and_slide.
	# see https://github.com/godotengine/godot-proposals/issues/1192
	# Rather inconsistent with move_and_collide which requires delta 
	# (and an input argument that isn't needed as move_and_slide automatically
	# grabs velocity).
	move_and_slide()
