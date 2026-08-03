---
name: gdscript
description: Write, review, and refactor GDScript code (Godot Engine's built‑in scripting language). Use when working with .gd files, Godot game logic, signals, autoloads, or when the user mentions GDScript, Godot scripting, or specific keywords like @onready, preload, signal, extends, or static typing.
---

# GDScript

## Quick start

Every script begins with `extends` and uses `func` for logic. Example:

```gdscript
extends Node

@export var speed: float = 400.0
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    sprite.modulate = Color.RED

func move(direction: float) -> void:
    position.x += direction * speed * get_process_delta_time()
```

## Workflows

### 1. Create a New Script

1. Choose the base class via `extends`.
   - If no explicit parent, use `extends RefCounted` for pure data classes.
2. Use **class_name** for globally accessible types (optional).
3. Place code in the correct lifecycle methods (`_ready`, `_process`, `_physics_process`) when they are needed.
4. Use the steps below for variables, functions, and signals.

### 2. Declare Variables

- Prefer `var` with **explicit static type** on all non‑trivial variables.
- Use `@export` to expose tuning values in the editor.
- Initialize at declaration whenever possible.

```gdscript
var health: int = 100                    # regular variable
@export var max_speed: float = 600.0     # exposed to inspector
@onready var anim: AnimationPlayer = $AnimationPlayer  # deferred node access
```

- Use `@onready` for any node obtained with `$` or `get_node()`.
- Group plugin access with `%` for unique nodes (accessing from anywhere with `%UniqueName`).

### 3. Write Functions

- Always specify return type `-> void` unless the function returns a value.
- Prefer **static functions** (`static func`) for utility methods that do not access instance state.
- Use `_` prefix for private methods (convention).
- Keep functions short and single‑purpose.

```gdscript
func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        die()

static func from_json(data: Dictionary) -> Player:
    return Player.new(data.name, data.score)
```

### 4. Use Static Typing

- Enable **optional typing** gradually; it improves performance and catches bugs.
- Use type hints on:
  - Variables: `var name: String = "Guy"`
  - Parameters: `func add(value: int) -> void:`
  - Return types: `func get_name() -> String:`
  - Arrays with element type: `var scores: Array[int] = []`
  - `@export` variables must be typed.
- **Inference** is allowed for simple literals (e.g., `var x := 10`). Prefer explicit types for exported or public API.

### 5. Connect and Emit Signals

- Define with `signal` keyword, emit with `.emit()`.

```gdscript
signal health_changed(new_health: int)

func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)
```

- Connect in code (prefer the **`node.signal.connect(callable)`** style):

```gdscript
button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
    print("clicked")
```

- Avoid string-based connections (they are error-prone and lack refactoring support).

### 6. Use Strong Node References

- Use `$` or `%` for child nodes; store in `@onready var`.
- Use **unique names** (the `%` operator) to access nodes across the scene without fragile paths.

```gdscript
@onready var music_player: AudioStreamPlayer = %MusicPlayer
```

### 7. Follow the GDScript Style Guide

Godot’s official style guide is authoritative. Key rules:

- **Naming**: `snake_case` for variables, functions, signals, methods; `PascalCase` for classes and node types.
- **Constants**: `const MAX_SPEED = 500` (ALL_CAPS).
- **Enums**: `enum { IDLE, RUNNING, JUMPING }` or `enum State { ... }` with PascalCase names.
- **Indentation**: tabs (not spaces). Size set in editor.
- **Blank lines**: Use to separate logic blocks.
- **Line length**: No hard limit, but keep lines for readability.
- **Documentation**: Use `#` for line comments; for docstrings use `##` and spaces surrounding text.

## Advanced features

The full style guide, exhaustive syntax, and edge cases are detailed in [reference.md](reference.md). This includes:

- Static typing in‑depth (infix types, typed arrays, `Variant`, `safe` lines, `@warning_ignore`)
- Control flow (`match`, `for`, `while`, `await`)
- Class names, `class_name`, and `tool` scripts
- Using `preload` vs `load`
- Best practices for performance and maintainability

-> For uncommon and advanced GDScript patterns, see [examples.md](examples.md).
