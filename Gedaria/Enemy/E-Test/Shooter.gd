extends E

var projectilePath = preload("res://Enemy/E-Test/Projectile.tscn")
var TurnAroundTimer = null

func _ready():
	TurnAroundTimer = get_tree().create_timer(0.0,false)
# ------------------------------------------------------------------------------
# warning-ignore:unused_argument
func _process(delta):
	if !bIsDead:
		# LOOK AROUND FOR PLAYER
		if TurnAroundTimer.time_left <= 0.0 && !bPlayer:
			TurnAroundTimer = get_tree().create_timer(5.0,false)
			if !bYieldStop:
				yield(TurnAroundTimer,"timeout")
				TurnAround()
		
		direction = 1 if $Sprite.flip_h else -1
		
		if bPlayer:
			Shoot()
# ------------------------------------------------------------------------------
func TurnAround(): # LOOK BACK AND FORTH
	if !bIsDead:
		$Sprite.flip_h = !$Sprite.flip_h
		$HitRay.cast_to.x = -$HitRay.cast_to.x
		
		if TurnAroundTimer.time_left <= 0.0:
			TurnAroundTimer = get_tree().create_timer(0.75,false)
			if !bYieldStop:
				yield(TurnAroundTimer,"timeout")
				if !bPlayer:
					$Sprite.flip_h = !$Sprite.flip_h
					$HitRay.cast_to.x = -$HitRay.cast_to.x
# ------------------------------------------------------------------------------
func Shoot(): # FIRE A PROJECTILE 
	if !bIsDead:
		if AttackTimer.time_left <= 0.0:
			AttackTimer = get_tree().create_timer(2.0,false)
			if !bYieldStop:
				yield(AttackTimer, "timeout")
				if bPlayer && !Player.bIsDead:
					var projectile = projectilePath.instance()
					add_child(projectile)
