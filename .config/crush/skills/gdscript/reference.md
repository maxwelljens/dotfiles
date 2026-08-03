# GDScript — Full Reference

Based on the [Godot Engine documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html) and the official [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).

## Lexical Basics

- **Identifiers**: Case‑sensitive. Must start with a letter or underscore, followed by alphanumerics/underscore.
- **Keywords**: `extends`, `class_name`, `func`, `var`, `const`, `enum`, `signal`, `if`, `elif`, `else`, `for`, `while`, `match`, `break`, `continue`, `return`, `pass`, `await`, `self`, `super`, `static`, `export`, `onready`, `tool`, `assert`, `preload`, `load`, `is`, `as`, `in`, `not`, `and`, `or`, `true`, `false`, `null`.
- **Literals**: `null`, `true`, `false`, `123`, `1.23`, `"string"`, `"""multiline"""`, `[1, 2]`, `{key = value}`.
- **Operators**: Standard arithmetic, `%` (mod), `**`, `//` (floor div). Comparison `==`, `!=`, `<`, `<=`, `>`, `>=`. Logical `and`, `or`, `not`. Bitwise `&`, `|`, `^`, `~`, `<<`, `>>`. Also `is` and `as` for type checking.

## Static Typing (Comprehensive)

### Type Hints

```gdscript
var name: String
var health: int = 100
func apply_damage(amount: int, crit: bool = false) -> void:
    ...
```

- `Variant` is the implicit type if omitted.
- Allowed types: `int`, `float`, `bool`, `String`, `Vector2`, `Vector3`, `Color`, `Transform2D`, `Transform3D`, `Array`, `Dictionary`, `Node`, any descendant class, custom scripts, and typed arrays like `Array[int]`.
- **Return types** can also be `-> void` (no return) or `-> bool`, etc.

### Inference with `:=`

```gdscript
var x := 10               # int
var name := "Player"      # String
var vec := Vector2(1, 2)  # Vector2
```

Only for initialised local variables; not for member variables unless the type is obvious and the variable is private.

### Typed Arrays

```gdscript
var numbers: Array[int] = [1, 2, 3]
var names: Array[String] = []
```

Without the element type, arrays are `Array[Variant]`.

### `@export` with Types

```gdscript
@export var max_health: int = 100
@export var weapon: PackedScene
@export var target_group: String = "enemies"
```

Export annotations (`@export_range`, `@export_enum`, `@export_file`, etc.) provide constraints for the inspector.

### Safe Lines & Warnings

- If you call a method on a value that might be null, use the `safe` accessor: `node?.method()`.
- To suppress static analysis warnings, use `@warning_ignore("reason")` on the next line (Godot 4.x).

## Code Structure & Style (Guideline)

Based on the official GDScript style guide for Godot 4.

### Naming

- **files**: `snake_case.gd` (match class name if `class_name`).
- **class_name**: `PascalCase` (e.g., `PlayerController`).
- **nodes**: `PascalCase` in scene tree (like `GameManager`), references via `$GameManager`.
- **functions, variables**: `snake_case`.
- **signals**: `snake_case`, use past tense for events: `health_changed`, `door_opened`.
- **constants**: `ALL_CAPS` with underscores.
- **enums**: enum names as `PascalCase`, constants themselves as `ALL_CAPS` inside if unnamed, or `PascalCase` if named.

```gdscript
const MAX_AMMO = 30
enum DamageType { PHYSICAL, MAGIC, TRUE }
```

- **private members**: prefix with single underscore `_private_var`, `_internal_function`.
- Prefer not to use single leading underscore for arguments that shadow built‑ins (like `velocity` vs `_velocity`), to avoid confusion.

### Formatting

- **Indent**: Use **tabs**, not spaces. (Godot editor default).
- **Continuation lines**: Align with previous open parenthesis or operator.
- **Blank lines**: One blank line between functions, two between sections.
- **Line length**: Keep under 100 characters for comfortable reading; no hard limit enforced.
- **Trailing whitespace**: Avoid.
- **String quotes**: Prefer double quotes `"text"` unless the string contains them; then single quotes.

### Comments

- Regular comment: `# This is a comment`.
- Docstring (used for in‑editor documentation): Start with `##` and a space: `## Calculate damage based on armor`.
- Keep comments concise and explain *why*, not what.

### Code Ordering (Inside a Script)

1. `tool` (if needed)
2. `extends`
3. `class_name` (if used)
4. `signal` definitions
5. `enum` declarations
6. `const` constants
7. `@export` variables
8. `@onready` variables
9. other member variables
10. `_static_init` (static constructor)
11. built‑in virtual methods (`_ready`, `_process`, `_input`, etc.)
12. public methods
13. private methods (prefixed `_`)
14. sub‑classes (inner class definitions)

## Key Features & Patterns

### `@onready`

- Used to defer initialization until the node is in the scene tree.
- Common for `$` node accesses.

```gdscript
@onready var health_bar: ProgressBar = $HUD/HealthBar
```

### Unique Nodes (`%`)

- Mark a node as “Access as Unique Name” in the editor.
- Then reference it from any script with `%UniqueName`, eliminating long relative paths.

```gdscript
@onready var score_label: Label = %ScoreLabel
```

### `preload` vs `load`

- `preload("res://path")` is a compile‑time load; executed once and cached. Prefer for resources known at develop time.
- `load("res://path")` is runtime, used for dynamic paths. Use sparingly.

### Signals and Callables

- Always use `signal_name.emit(...)` (Godot 4 syntax) instead of `emit_signal("signal_name", ...)`.
- Connect signals with the `signal.connect(callable)` style:

```gdscript
timer.timeout.connect(_on_timeout)
```

- Disconnect with `.disconnect(callable)`.
- To connect with flags, use the advanced signature:  
  `signal.connect(_callback, CONNECT_DEFERRED | CONNECT_ONE_SHOT)`

### `await` and Coroutines

- Use `await` to pause execution until a signal is emitted or a frame ends.

```gdscript
await get_tree().create_timer(2.0).timeout
print("2 seconds passed")
```

- `await` can also be used with signals directly: `await player.health_changed`

### `match` Statement

```gdscript
match state:
    State.IDLE:
        play_idle()
    State.RUNNING:
        play_run()
    _:
        print("unknown state")
```

- Patterns can include literals, constants, arrays, dictionaries, wildcards.

### Dictionary and Array Patterns

- Inline dictionaries: `{"health": 100, "mana": 50}`
- Access: `dict["health"]` or `dict.health` (only for valid identifiers).
- Nested type dictionaries are not yet supported, only `Dictionary[T, T]`.

### `@tool`

- Add at top to make script run in editor. Useful for custom inspectors or editor plugins.

### Static Typing Benefits

- Improved performance (avoids boxing to Variant).
- Autocompletion and static analysis.
- Earlier error detection.

## Common Pitfalls

- Forgetting `@onready` when accessing `$` in member variable initialization leads to `null`.
- Using spaces instead of tabs confuses Godot’s editor.
- Not typing exported variables can cause unexpected inspector behavior.
- Using `emit_signal` with a string name instead of `signal.emit()`.
- Not handling null with `safe` lines (`?.`) when needed.
- Assuming function parameters are typed if not specified — they default to `Variant`.

## Tooling

- **Godot Editor**: Built‑in script editor supports static typing inspections, warnings, and autocompletion.
- **GDScript (LSP)**: Available for external editors via the `gdscript` language server (integration with VS Code).
- **GUT**: Godot Unit Testing framework, write tests in GDScript.
