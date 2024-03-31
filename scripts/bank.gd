class_name FishBank

var fish_list = []
var bank_position = 0.0
var has_player = false
var bank_max_speed = 6



func _init(_fish_list:Array):
	fish_list = _fish_list
	var position = Vector2(randf_range(100,1000.0),randf_range(100,700.0))
	var velocity = Vector2(randf_range(-5.0,5.0),randf_range(-5.0,5.0))
	bank_max_speed = fish_list[0].max_speed
	for fish in fish_list:
		fish.position = position + Vector2(randf_range(-20.0,20.0),randf_range(-20.0,20.0))
		fish.velocity = velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


func separation(list):
	for fish in list:
		fish.close_d = Vector2(0.0,0.0)
		var distance = Vector2(0.0,0.0)
		var threshold = fish.separation
		for other_fish in list:
			if(fish == other_fish):
				continue
			distance = fish.position - other_fish.position
			if(other_fish.fishType == "player"):
					threshold *= 2
			if (distance.length() <= threshold):
				fish.close_d += distance
		if(fish.fishType == "player"):
			if(fish.no_external_forces):
				break
		fish.velocity += fish.close_d * fish.avoidfactor
		#detect_wall_collisions(fish)

func add_player(player):
	if !has_player:
		fish_list.append(player)
		has_player = true

func remove_player(player):
	if has_player:
		fish_list.remove_at(fish_list.size() - 1)
		has_player = false
	
func alignment(list):
	for fish in list:
		fish.neighboring_boids = 0
		fish.vel_avg = Vector2(0.0,0.0)
		var distance = Vector2(0.0,0.0)
		for other_fish in list:
			if(fish == other_fish):
				continue
			distance = fish.position - other_fish.position
			if (distance.length() < fish.visible_range):
				fish.vel_avg += other_fish.vel_avg
				fish.neighboring_boids += 1
		if (fish.neighboring_boids > 0):
			fish.vel_avg = fish.vel_avg/fish.neighboring_boids
		if(fish.fishType == "player"):
			if(fish.no_external_forces):
				break
		fish.velocity += (fish.vel_avg)* fish.matching_factor
		#detect_wall_collisions(fish)


func cohesion(list):
	var pos_avg = Vector2(0.0,0.0)
	var neighboring_boids = 0
	for fish in list:
		pos_avg += fish.position
		neighboring_boids += 1
	if (neighboring_boids > 0):
		pos_avg = pos_avg/neighboring_boids
	
	for fish in list:
		if(fish.fishType == "player"):
			if(fish.no_external_forces):
				break
		fish.velocity += (pos_avg - fish.position)*fish.centering_factor
		detect_wall_collisions(fish)
	bank_position = pos_avg

func detect_wall_collisions(fish):
	var collision_factor = 5
	var rightmargin = 1280
	var bottommargin = 720
	var topmargin = 0
	var leftmargin = 0
	var dist_right_border = rightmargin - fish.position.x
	var dist_left_border = fish.position.x - leftmargin
	var dist_top_border =  fish.position.y - topmargin
	var dist_bottom_border = bottommargin - fish.position.y
	
	if (fish.position.x >= rightmargin):
		fish.velocity.x = -fish.velocity.x
	else:
		fish.velocity.x = fish.velocity.x + (-1/dist_right_border)*collision_factor
	
	if (fish.position.x <= leftmargin):
		fish.velocity.x = -fish.velocity.x
	else:
		fish.velocity.x = fish.velocity.x + (1/dist_left_border)*collision_factor
	
	if (fish.position.y <= topmargin):
		fish.velocity.y = -fish.velocity.y
	else:
		fish.velocity.y = fish.velocity.y + (1/dist_top_border)*collision_factor
	
	if (fish.position.y >= bottommargin):
		fish.velocity.y = -fish.velocity.y
	else:
		fish.velocity.y = fish.velocity.y + (-1/dist_bottom_border)*collision_factor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	separation(fish_list)
	alignment(fish_list)
	cohesion(fish_list)
	pass

