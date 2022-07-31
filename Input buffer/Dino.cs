using Godot;
using System;
using System.Collections.Generic;

/// <summary>
/// The game's brave protagonist.
/// </summary>
public class Dino : KinematicBody2D
{
    private enum DinoState
    {
        Grounded,
        Jumping,
        Ducking,
        Dead
    }

    private readonly struct StateBehaviours
    {
        /// <summary> Method to call when entering this state. </summary>
        public readonly Action Enter;
        /// <summary> Method to call repeatedly while the state machine is in this state. </summary>
        public readonly Action Tick;
        /// <summary> Method to call when exiting this state. </summary>
        public readonly Action Exit;

        public StateBehaviours(Action enter, Action tick, Action exit)
        {
            Enter = enter;
            Tick = tick;
            Exit = exit;
        }
    }

    private static readonly string JUMP_ACTION = "ui_select";

    private DinoState _state = DinoState.Grounded;
    private AnimationPlayer _animator; [Export] private NodePath _animation_player_path;
    private Vector2 _velocity;
    private float _gravity;

    /// <summary> How many pixels per second squared the dino accelerates towards the ground at while rising. </summary>
    [Export] private float _regular_gravity = 2400f;
    /// <summary>
    /// How many pixels per second squared the dino accelerates towards the ground at if the player releases the jump 
    /// button while rising.
    /// </summary>
    [Export] private float _short_hop_gravity = 4800f;
    /// <summary>
    /// Pixels per second downward the dino moves the moment it jumps.
    /// Recall that the coordinate system has the positive y axis point down, so this should be negative.
    /// </summary>
    [Export] private float _initial_jump_speed = 800f;

    private Dictionary<DinoState, StateBehaviours> _stateMachine = new Dictionary<DinoState, StateBehaviours>
    {
        { DinoState.Grounded, new StateBehaviours
        (
            () => GD.Print("Hello"),
            () => GD.Print(":))))"),
            () => GD.Print("Goodbye")
        )},
        { DinoState.Ducking, new StateBehaviours
        (
            enter: () => GD.Print("hello"),
            tick: () => GD.Print(":)"),
            exit: () => GD.Print("goodbye")
        )},

    };

    /// <summary>
    /// Called when the node enters the scene tree for the first time.
    /// </summary>
    public override void _Ready()
    {
        _animator = GetNode<AnimationPlayer>(_animation_player_path);

        _stateMachine[DinoState.Grounded].Enter();
    }

    /// <summary>
    /// Called during the physics processing step of the main loop.
    /// </summary>
    /// <param name="delta"> The elapsed time since the previous physics step. </param>
    public override void _PhysicsProcess(float delta)
    {
        base._PhysicsProcess(delta);

        switch (_state)
        {
            case DinoState.Grounded:
                if (Input.IsActionJustPressed(JUMP_ACTION))
                {
                    _state = DinoState.Jumping;
                    _velocity = _initial_jump_speed * Vector2.Up;
                    _gravity = _regular_gravity;
                    _animator.Play("Run");
                }
                break;
            case DinoState.Jumping:
                // Short-hop if the player releases the jump button while rising
                if (Input.IsActionJustReleased(JUMP_ACTION) && _velocity.Dot(Vector2.Up) > 0)
                {
                    _gravity = _short_hop_gravity;
                }

                _velocity += _gravity * delta * Vector2.Down;

                // Reset the gravity once the dino begins falling after a short hop. 
                if (_velocity.Dot(Vector2.Up) < 0)
                {
                    _gravity = _regular_gravity;
                }

                MoveAndSlide(_velocity, Vector2.Up);
                if (IsOnFloor())
                {
                    _state = DinoState.Grounded;
                }
                break;
            default: throw new InvalidOperationException("Unhandled state: " + _state);
        }
    }
}
