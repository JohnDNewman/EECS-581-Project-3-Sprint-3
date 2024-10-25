extends CharacterBody2D

@export var speed          = 400
@export var rotation_speed = 3.5
@export var max_bullets = 5 #OPTION Could make a changeable value for powerups
@export var max_mines = 1
var cur_bullets := 0 #create var for cur mines and bullets
var cur_mines := 0   #walrus, := is used to make it only be of the type of its assignment
					 #in this case, an int. Just an optimization and helps prevent mishaps

@onready var BULLET = preload("res://bullet.tscn")#load the idea of a bullet to this var
												  #so we can make some from this script

var rotation_direction = 0   #Just create it
var mouse_pos = Vector2(0,0) #set mouse pos to some place, don't matter.

#functions to decrease cur number of mines and bullets
func dec_mines():
	cur_mines = cur_mines - 1
func dec_bullets():
	cur_bullets = cur_bullets - 1

#func to get input from player
func get_input():
	rotation_direction = Input.get_axis("left", "right") #Direction to turn
	velocity = transform.x * Input.get_axis("down", "up") * speed #velocity to move at
	
	#MAKE TURRENT TURN TOWARDS MOUSE
	$tankGun.global_rotation = mouse_pos.angle_to_point(position)-deg_to_rad(-90)
	

func _physics_process(delta):
	##MOVEMENT
	get_input() # get details of movement
	rotation += rotation_direction * rotation_speed * delta #rotate tank
	move_and_slide() #move tank with physics, wooo
	
	##SHOOTING LOGIC
	if Input.is_action_just_pressed("shoot") && (cur_bullets < 5): #check if want to and can fire
		cur_bullets = cur_bullets + 1 #increase number of bullets fired
		#create bullet instance for bullet
		var bul = BULLET.instantiate()
		bul.parent = get_parent().get_node("Tank") #set parent to this instance for refrence
		get_tree().root.add_child(bul) #add to game tree at root #no reason not to for now
		bul.global_rotation = ($tankGun.global_rotation)-deg_to_rad(-90) #do orientation bullshit because graphics are fucked fuck you andrew jk love you
		bul.global_position = $tankGun/fire_loc.global_position #move to the fire loc so it pretend to fire from turret
		#Should change a bit so end of bullet is end of turret but meh, like a 5 minute fix I'll leave to someone else

	elif Input.is_action_just_pressed("mine") && (cur_mines < 1):
		cur_mines = cur_mines + 1 #increase number of mines placed
		#create bullet instance for mine
			#TODO create new scene for mines
		var mine = BULLET.instantiate()
		mine.get_node("life_time").wait_time = 5 #change so mine lasts longer than bullet #wont need if new scene
		mine.parent = get_parent().get_node("Tank") #set parent to this instance for refrence
		get_tree().root.add_child(mine) #add to game tree at root
		mine.type = "mine" #say its a mine bullet
		mine.get_node("texture").texture = preload("res://assets/mine.png") #change texture to mine
		mine.get_node("hitbox").shape = preload("res://mine_collision.tres") #change collision to mine
		mine.global_position = global_position #place at center of tank #TODO Change something with the rendering so tank is on top



func _input(event): #get input event if one happens
	if event is InputEventMouseMotion: #if it is mouse movement
		#print("Mouse Motion at: ", event.position) #print debug info
		mouse_pos = event.position #change mouse_pos to new pos
