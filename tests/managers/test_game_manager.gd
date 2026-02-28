extends SceneTree

var game_manager_script = load("res://scripts/managers/game_manager.gd")
var game_manager
var passed = 0
var failed = 0

func _init():
    print("Testing GameManager...")
    game_manager = game_manager_script.new()
    var root = get_root()
    root.add_child(game_manager)

    call_deferred("_run_tests")

func assert_eq(actual, expected, test_name):
    if actual == expected:
        print("PASS: ", test_name)
        passed += 1
    else:
        print("FAIL: ", test_name, " - Expected ", expected, " but got ", actual)
        failed += 1

func assert_true(actual, test_name):
    assert_eq(actual, true, test_name)

func assert_false(actual, test_name):
    assert_eq(actual, false, test_name)

func _run_tests():
    print("Running Tests...\n")

    # Test valid state transition: PLAYING -> PAUSED
    game_manager.current_state = game_manager.GameState.PLAYING
    game_manager.is_paused = false
    self.paused = false

    game_manager.pause_game()
    assert_eq(game_manager.current_state, game_manager.GameState.PAUSED, "pause_game changes state to PAUSED")
    assert_true(game_manager.is_paused, "pause_game sets is_paused to true")
    assert_true(self.paused, "pause_game sets tree.paused to true")

    # Test valid state transition: PAUSED -> PLAYING
    game_manager.resume_game()
    assert_eq(game_manager.current_state, game_manager.GameState.PLAYING, "resume_game changes state to PLAYING")
    assert_false(game_manager.is_paused, "resume_game sets is_paused to false")
    assert_false(self.paused, "resume_game sets tree.paused to false")

    # Test invalid state transition: PLAYING -> PLAYING (resume_game while playing)
    game_manager.current_state = game_manager.GameState.PLAYING
    game_manager.is_paused = false
    self.paused = false

    game_manager.resume_game()
    assert_eq(game_manager.current_state, game_manager.GameState.PLAYING, "resume_game from PLAYING does not change state")
    assert_false(game_manager.is_paused, "resume_game from PLAYING does not change is_paused")
    assert_false(self.paused, "resume_game from PLAYING does not change tree.paused")

    # Test invalid state transition: PAUSED -> PAUSED (pause_game while paused)
    game_manager.current_state = game_manager.GameState.PAUSED
    game_manager.is_paused = true
    self.paused = true

    game_manager.pause_game()
    assert_eq(game_manager.current_state, game_manager.GameState.PAUSED, "pause_game from PAUSED does not change state")
    assert_true(game_manager.is_paused, "pause_game from PAUSED does not change is_paused")
    assert_true(self.paused, "pause_game from PAUSED does not unpause tree")

    print("\n--- TEST SUMMARY ---")
    print("Passed: ", passed)
    print("Failed: ", failed)

    if failed > 0:
        quit(1)
    else:
        quit(0)
