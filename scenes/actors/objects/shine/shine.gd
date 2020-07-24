extends GameObject

onready var effects = $ShineEffects
onready var animated_sprite = $AnimatedSprite
onready var ghost = $Ghost
onready var area = $Area2D
onready var sound = $CollectSound
onready var ambient_sound = $AmbientSound
onready var animation_player = $AnimationPlayer
onready var current_scene = get_tree().current_scene
var collected = false
var character

var anim_damp = 160

var title := "Unnamed Shine"
var description := "This is a shine! Collect it to win the level."
var show_in_menu := false
var activated := true
var red_coins_activate := false
var shine_shards_activate := false

var unpause_timer = 0.0

func _set_properties():
	savable_properties = ["title", "description", "show_in_menu", "activated", "red_coins_activate", "shine_shards_activate"]
	editable_properties = ["title", "description", "show_in_menu", "activated", "red_coins_activate", "shine_shards_activate"]
	
func _set_property_values():
	set_property("title", title, true)
	set_property("description", description, true)
	set_property("show_in_menu", show_in_menu, true)
	set_property("activated", activated, true)
	set_property("red_coins_activate", red_coins_activate, true)
	set_property("shine_shards_activate", shine_shards_activate, true)

func collect(body):
	if activated and enabled and !collected and body.name.begins_with("Character") and body.controllable:
		character = body
		character.set_state_by_name("Fall", 0)
		character.velocity = Vector2(0, 0)
		character.get_node("Sprite").rotation_degrees = 0
		character.controllable = false
		#sound.play() -Sound doesn't carry over between scenes, so it cuts off
		collected = true
		visible = false

func _ready():
	if mode != 1:
		if red_coins_activate or shine_shards_activate:
			activated = false
		var _connect = area.connect("body_entered", self, "collect")

func _physics_process(delta):
	if !animated_sprite.playing:
		#warning-ignore:integer_division
		animated_sprite.frame = wrapi(OS.get_ticks_msec() / (1000/8), 0, 16)
	if mode != 1:
		var camera = current_scene.get_node(current_scene.camera)
		if red_coins_activate and !activated:
			if CurrentLevelData.level_data.vars.red_coins_collected == CurrentLevelData.level_data.vars.max_red_coins:
				activate_shine()
		if shine_shards_activate and !activated:
			if CurrentLevelData.level_data.vars.shine_shards_collected == CurrentLevelData.level_data.vars.max_shine_shards:
				activate_shine()
		if !collected:
			if !activated:
				ambient_sound.playing = false
				ghost.visible = true
				animated_sprite.visible = false
				effects.visible = false
			else:
				if !ambient_sound.playing:
					ambient_sound.playing = true
				ghost.visible = false
				animated_sprite.visible = true
				effects.visible = true
		ambient_sound.volume_db = -16 + -abs(camera.global_position.distance_to(global_position)/25)
	#warning-ignore:integer_division
	effects.rotation_degrees = (OS.get_ticks_msec()/16) % 360
	effects.position = animated_sprite.offset + Vector2(0, 2)
	if collected:
		var sprite = character.get_node("Sprite")
		sprite.animation = "shineFall"
		if character.is_grounded():
			character.exit()
			
	if unpause_timer > 0:
		unpause_timer -= delta
		if unpause_timer <= 0:
			unpause_timer = 0
			var camera = current_scene.get_node(current_scene.camera)
			camera.focus_on = null
			get_tree().paused = false
			pause_mode = PAUSE_MODE_INHERIT

func activate_shine():
	activated = true
	animation_player.play("appear")
	var camera = current_scene.get_node(current_scene.camera)
	camera.focus_on = self
	pause_mode = PAUSE_MODE_PROCESS
	get_tree().paused = true
	unpause_timer = 3.35
