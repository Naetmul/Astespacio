extends Node2D

export(PackedScene) var asteroid_scene

const projectile_scene = preload("res://Projectile.tscn")
const shoot_sound = preload("res://Assets/FX300.mp3")
const collison_sound = preload("res://Assets/retro_sound_1_0.wav")

const asteroid_max_speed = 500
const projectile_speed = 2000
const projectile_start_margin = 40
const fire_period = 0.2
const SAVE_FILE_PATH = "user://savedata.dat"

var elapsed_seconds = 0
var score = 0
var highscore = 0
var can_fire = true
var is_game_over = false
var is_game_playing = false

var data_dict: Dictionary = {}


func _ready() -> void:
    shoot_sound.loop = false
    collison_sound.loop_mode = AudioStreamSample.LOOP_DISABLED
    
    $PauseHUD/Control.hide()
    
    load_highscore()
    $HUD.update_highscore(highscore)
    
    randomize()


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel") and is_game_playing:
        get_tree().paused = true
        $HUD.show_highscore()
        $PauseHUD.game_paused()
        get_tree().get_root().set_input_as_handled()
    
    
func _process(_delta: float) -> void:
    if can_fire and Input.is_action_pressed("ui_accept"):
        can_fire = false
        
        var projectile = projectile_scene.instance()
        self.add_child(projectile)
        
        projectile.position = $Player.position + projectile_start_margin * Vector2.UP.rotated($Player.rotation)
        projectile.rotation = $Player.rotation
        projectile.linear_velocity = projectile_speed * Vector2.UP.rotated($Player.rotation)
        projectile.connect("body_entered", self, "_on_projectile_body_entered")
        
        play_sound_effect(shoot_sound)
        
        yield(get_tree().create_timer(fire_period), "timeout")
        if not is_game_over:
            can_fire = true


func new_game() -> void:
    elapsed_seconds = 0
    score = 0
    
    $HUD.update_score(score)
    $HUD.update_highscore(highscore)
    $HUD.show_message("Get Ready")
    
    get_tree().call_group("asteroids", "queue_free")
    
    $Player.start()
    is_game_over = false
    is_game_playing = true
    can_fire = true
    
    $StartTimer.start()


func game_over() -> void:
    if score > highscore:
        highscore = score
        $HUD.update_highscore(highscore, true)
        save_highscore()
    else:
        $HUD.update_highscore(highscore)
        
    is_game_over = true
    is_game_playing = false
    can_fire = false
    
    $HUD.show_highscore()
    $HUD.show_game_over()
    
    $ScoreTimer.stop()
    $AsteroidTimer.stop()


func _on_StartTimer_timeout() -> void:
    $AsteroidTimer.wait_time = 0.5
    $ScoreTimer.start()
    
    $HUD.hide_highscore()
    
    print("Level 1")
    $AsteroidTimer.start()


func _on_ScoreTimer_timeout() -> void:
    elapsed_seconds += 1
    score += 10
    
    $HUD.update_score(score)
    
    if elapsed_seconds == 20:
        print("Level 2")
        $AsteroidTimer.wait_time = 0.4
    if elapsed_seconds == 40:
        print("Level 3")
        $AsteroidTimer.wait_time = 0.3
    if elapsed_seconds == 80:
        print("Level 4")
        $AsteroidTimer.wait_time = 0.2
    if elapsed_seconds == 120:
        print("Level 5")
        $AsteroidTimer.wait_time = 0.1
    if elapsed_seconds == 180:
        print("Level 5")
        $AsteroidTimer.wait_time = 0.05


func _on_AsteroidTimer_timeout() -> void:
    var asteroid = asteroid_scene.instance()
    self.add_child(asteroid)
    
    var horizontal_length = 1.2 * get_viewport_rect().size.x
    var vertical_length = 1.2 * get_viewport_rect().size.y
    
    var gen_pos = rand_range(0, 2*horizontal_length + 2*vertical_length)
    if 0 <= gen_pos and gen_pos < horizontal_length:
        var eff_pos = gen_pos
        asteroid.position = $Player.position + Vector2(eff_pos - horizontal_length/2, -vertical_length/2)
        asteroid.linear_velocity = rand_range(0, asteroid_max_speed) * Vector2.DOWN.rotated(rand_range(-PI/2, PI/2))
    elif horizontal_length <= gen_pos and gen_pos < horizontal_length + vertical_length:
        var eff_pos = gen_pos - horizontal_length
        asteroid.position = $Player.position + Vector2(horizontal_length/2, eff_pos - vertical_length/2)
        asteroid.linear_velocity = rand_range(0, asteroid_max_speed) * Vector2.LEFT.rotated(rand_range(-PI/2, PI/2))
    elif horizontal_length + vertical_length <= gen_pos and gen_pos < 2*horizontal_length + vertical_length:
        var eff_pos = gen_pos - horizontal_length - vertical_length
        asteroid.position = $Player.position + Vector2(eff_pos - horizontal_length/2, vertical_length/2)
        asteroid.linear_velocity = rand_range(0, asteroid_max_speed) * Vector2.UP.rotated(rand_range(-PI/2, PI/2))
    else:
        var eff_pos = gen_pos - 2*horizontal_length - vertical_length
        asteroid.position = $Player.position + Vector2(-horizontal_length/2, eff_pos - vertical_length/2)
        asteroid.linear_velocity = rand_range(0, asteroid_max_speed) * Vector2.RIGHT.rotated(rand_range(-PI/2, PI/2))
    
    print("Asteroid generated")
    
    for ast in get_tree().get_nodes_in_group("asteroids"):
        if is_asteroid_removal_needed(ast):
            ast.queue_free()
            print("Asteroid removed")


func is_asteroid_removal_needed(asteroid: Asteroid) -> bool:
    var viewport_rect_size = get_viewport_rect().size
    if asteroid.position.x < $Player.position.x - viewport_rect_size.x:
        return true
    if asteroid.position.y < $Player.position.y - viewport_rect_size.y:
        return true
    if asteroid.position.x > $Player.position.x + viewport_rect_size.x:
        return true
    if asteroid.position.y > $Player.position.y + viewport_rect_size.y:
        return true
    return false


func _on_Player_hit() -> void:
    game_over()
    
    
func _on_projectile_body_entered(body: Node) -> void:
    if body.get_node("VisibilityNotifier2D").is_on_screen():
        score += 50
        $HUD.update_score(score)
        play_sound_effect(collison_sound)
        print("On screen collision")
    else:
        print("Off screen collision")


func save_highscore() -> void:
    data_dict["highscore"] = highscore
    
    var file = File.new()
    file.open(SAVE_FILE_PATH, File.WRITE)
    file.store_var(data_dict)
    file.close()
    
    
func load_highscore() -> void:
    var file = File.new()
    if file.file_exists(SAVE_FILE_PATH):
        file.open(SAVE_FILE_PATH, File.READ)
        data_dict = file.get_var()
        file.close()
        
        highscore = data_dict["highscore"]


func play_sound_effect(sound: AudioStream) -> void:
    var stream_player = AudioStreamPlayer.new()
    stream_player.stream = sound
    stream_player.connect("finished", stream_player, "queue_free")
    
    self.add_child(stream_player)
    stream_player.play()


func _on_PauseHUD_resume_game() -> void:
    $HUD.hide_highscore()
    get_tree().paused = false


func _on_PauseHUD_surrender_game() -> void:
    $HUD.hide_highscore()
    get_tree().paused = false
    game_over()
