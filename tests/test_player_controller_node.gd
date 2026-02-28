extends Node

var tests_passed = 0
var tests_failed = 0

var was_died_emitted = false

func assert_eq(actual, expected, test_name: String):
	if actual == expected:
		print("✅ PASS: ", test_name)
		tests_passed += 1
	else:
		print("❌ FAIL: ", test_name)
		print("   Expected: ", expected)
		print("   Got:      ", actual)
		tests_failed += 1

func _on_player_died():
	was_died_emitted = true

func _ready():
	print("Running PlayerController tests...")

	var PlayerController = load("res://scripts/player/player_controller.gd")
	var MockStateMachine = load("res://tests/mock_state_machine.gd")

	# TEST 1: Non-lethal damage
	print("\n--- TEST: Non-lethal damage ---")
	var p1 = PlayerController.new()
	var sm1 = MockStateMachine.new()
	sm1.name = "StateMachine"
	p1.add_child(sm1)
	p1.state_machine = sm1
	add_child(p1) # Add to tree

	p1.current_health = 100
	p1.max_health = 100
	p1.take_damage(20)
	assert_eq(p1.current_health, 80, "Damage reduces current_health by 20")
	assert_eq(sm1.last_transition, "hit", "State machine transition called correctly for 'hit'")
	p1.queue_free()

	# TEST 2: Lethal damage
	print("\n--- TEST: Lethal damage ---")
	was_died_emitted = false
	var p2 = PlayerController.new()
	var sm2 = MockStateMachine.new()
	sm2.name = "StateMachine"
	p2.add_child(sm2)
	p2.state_machine = sm2
	p2.died.connect(_on_player_died)
	add_child(p2) # Add to tree

	p2.current_health = 100
	p2.take_damage(100)
	assert_eq(p2.current_health, 0, "Health drops to 0")
	assert_eq(sm2.last_transition, "dead", "State machine transition called correctly for 'dead'")
	assert_eq(was_died_emitted, true, "Player emitted 'died' signal")
	p2.queue_free()

	# TEST 3: Overkill damage
	print("\n--- TEST: Overkill damage ---")
	var p3 = PlayerController.new()
	var sm3 = MockStateMachine.new()
	sm3.name = "StateMachine"
	p3.add_child(sm3)
	p3.state_machine = sm3
	add_child(p3) # Add to tree

	p3.current_health = 10
	p3.take_damage(50)
	assert_eq(p3.current_health, -40, "Health handles negative values (no clamping implemented)")
	p3.queue_free()

	print("\nTest Summary:")
	print("Passed: ", tests_passed)
	print("Failed: ", tests_failed)

	if tests_failed > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0)
