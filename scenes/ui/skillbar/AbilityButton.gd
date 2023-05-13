extends TextureButton

@onready var time_label = $Counter/Value

@export var cooldown = 1.0

signal ability_use(ability)

var ability

#hello

func _ready():
	
	time_label.hide()
	$Sweep.texture_progress = texture_normal
	$Sweep.value = 0
	set_process(false)

# Connect the Timer's "timeout" signal to _on_Timer_timeout() function
	$Timer.timeout.connect(_on_Timer_timeout)

# Connect the AbilityButton's "pressed" signal to _on_AbilityButton_pressed() function
	pressed.connect(_on_AbilityButton_pressed)
	

func bind_ability(bind_ability):
	ability = bind_ability
	texture_normal = ability.texture
	$Sweep.texture_progress = texture_normal
	cooldown = ability.cooldown
	$Timer.wait_time = cooldown
	

func _process(delta):
	time_label.text = "%3.1f" % $Timer.time_left
	$Sweep.value = int(($Timer.time_left / cooldown) * 100)
	
	
func _on_AbilityButton_pressed():
	activate_button()

func activate_button():
	if ability:
		ability_use.emit(ability)
		disabled = true
		set_process(true)
		$Timer.start()
		time_label.show()
		
	
func _on_Timer_timeout():
	print("Ability ready!")
	$Sweep.value = 0
	disabled = false
	time_label.hide()
	set_process(false)


func _on_pressed():
	activate_button()

