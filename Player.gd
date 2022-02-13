extends Area2D

signal hit

const rotation_speed = 5
const boost_accel = 10
const max_speed = 1000

var ship_velocity = Vector2(0, 0)

func _process(_delta: float) -> void:
    $ParticleBooster.emitting = Input.is_action_pressed("ui_up")
    
    $ParticleBreak1.emitting = Input.is_action_pressed("ui_down")
    $ParticleBreak2.emitting = Input.is_action_pressed("ui_down")
    
    if not $AudioStreamPlayer.playing and (Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")) and self.visible:
        $AudioStreamPlayer.play()
    if $AudioStreamPlayer.playing and (not (Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")) or not self.visible):
        $AudioStreamPlayer.stop()


func _physics_process(delta: float) -> void:
    var angular_velocity = 0
    if Input.is_action_pressed("ui_left"):
        angular_velocity -= 1
    if Input.is_action_pressed("ui_right"):
        angular_velocity += 1
        
    self.rotate(rotation_speed * angular_velocity * delta)
    
    if Input.is_action_pressed("ui_up"):
        ship_velocity += boost_accel * Vector2(sin(self.rotation), -cos(self.rotation))
    if Input.is_action_pressed("ui_down"):
        ship_velocity -= boost_accel * Vector2(sin(self.rotation), -cos(self.rotation))
        
    ship_velocity = ship_velocity.clamped(max_speed)
    
    self.translate(ship_velocity * delta)

    
func start() -> void:
    show()
    $CollisionShape2D.disabled = false


func _on_Player_body_entered(_body: Node) -> void:
    hide()
    emit_signal("hit")
    $CollisionShape2D.set_deferred("disabled", true)
