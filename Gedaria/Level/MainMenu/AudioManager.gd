extends Node

var dict = {}


func play_sfx(audio_clip : AudioStream, priority=0, delay=0.0, db = 0.0):
	for child in $SFX.get_children():
		if not child.playing:
			child.stream = audio_clip
#			print(audio_clip.stream.resource_path)
			child.volume_db = db
			yield(get_tree().create_timer(delay), "timeout")
			child.play()
			dict[child.name] = priority
			break
			
		if child.get_index() == $SFX.get_child_count() - 1:
			var priority_player = self.find_oldest_player()
			if priority_player:
				priority_player.stream = audio_clip
				
				yield(get_tree().create_timer(delay), "timeout")
				priority_player.play()
# ------------------------------------------------------------------------------

func check_priority(dic, prio):
	var prio_list = []
	
	for key in dic:
		if prio > dic[key]:
			prio_list.append(key)
	
	var last_prio = null
	
	for key in prio_list:
		if not last_prio:
			last_prio = key
			continue
		if dic[key] < dic[last_prio]:
			last_prio = key
	return last_prio
# ------------------------------------------------------------------------------

func find_oldest_player():
	var last_child = null
	
	for child in $SFX.get_children():
		if not last_child:
			last_child = child
			continue
		
		if child.get_playback_position() > last_child.get_playback_position():
			last_child = child
	return last_child
# ------------------------------------------------------------------------------

func play_music(music_clip : AudioStream):
	$Music/AudioPlayer.stream = music_clip
	$Music/AudioPlayer.play()
# ------------------------------------------------------------------------------

func get_volume(bus_name):
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name))
# ------------------------------------------------------------------------------

func set_volume(bus_name, db):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db)
# ------------------------------------------------------------------------------

func stop_sfx(sfx_name):
	for child in $SFX.get_children():
		if child.playing:
			if child.stream == sfx_name:
				child.stop()
# ------------------------------------------------------------------------------

func is_playing_sfx(sfx_name):
	for child in $SFX.get_children():
		if child.playing:
			if child.stream == sfx_name:
				return true
	return false
# ------------------------------------------------------------------------------

func fade_in_music():
	$Tween.interpolate_property($Music/AudioPlayer, "volume_db", -80, -5, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
