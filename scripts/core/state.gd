# State Base Class
# Base class for all states used with StateMachine
extends Node
class_name State

## Reference to the state machine
var state_machine: StateMachine

## Reference to the actor (player, NPC, etc.)
var actor: Node

## Called when entering this state
func enter() -> void:
	pass

## Called when exiting this state
func exit() -> void:
	pass

## Called every physics frame while in this state
func physics_update(_delta: float) -> void:
	pass

## Called every frame while in this state
func frame_update(_delta: float) -> void:
	pass

## Called for unhandled input while in this state
func handle_input(_event: InputEvent) -> void:
	pass
