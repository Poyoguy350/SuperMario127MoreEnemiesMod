extends Node2D

func _ready():
	update_activity()

func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_state("Testing!")

	var assets = activity.get_assets()
	assets.set_large_image("sm127")
	assets.set_large_text("0.7.2")
	assets.set_small_image("capsule_main")
	assets.set_small_text("ZONE 2 WOOO")
	
	var timestamps = activity.get_timestamps()
	timestamps.set_start(OS.get_unix_time() + 100)
	timestamps.set_end(OS.get_unix_time() + 500)

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(str(result))
