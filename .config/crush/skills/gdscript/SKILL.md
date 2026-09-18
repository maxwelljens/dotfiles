---
name: gdscript
description: "GDScript and Godot 4 scripting guide. Use when writing, reviewing, or debugging .gd files, working on Godot projects, or answering questions about GDScript syntax. Emphasizes GDScript's unusual features versus other languages (@onready/@export/@tool annotations, match statement, signals, await/coroutines, typed arrays and dictionaries, Lua-style dictionaries) and enforces the official GDScript style guide."
---

# GDScript

GDScript is a Python-like, indentation-based language designed for Godot Engine. It looks familiar to Python developers but has significant differences: annotation-driven variable declarations, a C-style `match` statement with destructuring and `when` guards, signals, coroutines via `await`, typed arrays/dictionaries, and engine-specific syntax like `$NodePath`.

Primary references (Godot 4 stable):

- GDScript reference (language): https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html
- Style guide: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- Static typing: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html
- @export annotations: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html
- GDScript format strings: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html
- Signals tutorial: https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- Class reference: https://docs.godotengine.org/en/stable/classes/

## Most uncommon features (compared to Python, JS, C#)

These are the constructs most likely to be written incorrectly by someone fluent in another language. Get these right.

### Annotations on variables (`@export`, `@onready`, `@tool`, `@icon`)

GDScript does not use decorators, getters, or setup methods for these; it uses `@` annotations placed on the line above the declaration.

- `@export var health: int = 100` — exposes the variable in the editor Inspector. Modifier annotations exist: `@export_range(1, 100, 1, "or_greater")`, `@export_enum`, etc. Full list: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html
- `@onready var label = $Label` — defers initialization until `_ready()` runs, because child nodes do not exist when the script initializes. This replaces manually assigning node references inside `_ready()`. Do not assign node paths to plain `var` declarations; they will be `null`.
- `@tool` on the first line makes the script run inside the editor (used for editor plugins and live-updating UI scripts). See https://docs.godotengine.org/en/stable/tutorials/plugins/running_code_in_the_editor.html
- `@icon("res://path/to/icon.png")` sets the class icon shown in the editor.
- `@abstract` (placed before `class_name`, Godot 4.5+) marks the class as abstract: it cannot be instantiated. Inner classes declare it inline: `@abstract class MyNode extends Node:`.
- Annotations stack on one line: `@onready @export var x = 5` is legal syntax, but combining `@onready` with `@export` triggers the `ONREADY_WITH_EXPORT` warning (error by default) because `@onready` reassigns the exported value in `_ready()`.

Initialization order matters: default values, then `var` assignments top-to-bottom, then `_init()`, then exported values from the scene, then `@onready` assignments, then `_ready()`.

### `match` statement

`match` is C/Rust-style (not Python-style), supports destructuring, guards, and multiple patterns:

```gdscript
match point:
    [0, 0]:
        print("Origin")
    [var x, var y] when y == x:
        print("Point on line y = x")
    [var x, var y]:
        print("Point (%s, %s)" % [x, y])
    _:
        print("Unmatched")
```

Key rules:

- A `when` guard is only evaluated after the pattern matches. `_` is the wildcard.
- Patterns: literals (`1`, `"text"`), constant expressions (`TYPE_FLOAT`, `Math.TAU`), wildcard `_`, bindings (`var new_var`), arrays (`[1, _, "test"]`, open-ended `[42, ..]`), dictionaries (`{"name": "Dennis", "age": var age}`, open-ended `{..}`), and multiple comma-separated alternatives (`1, 2, 3:`). Bindings are not allowed in comma-separated patterns.
- Matching is by exact type: `1` does not match `1.0` (the only exception is String vs StringName).
- `match` does not fall through; no `break` needed.

Reference section: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#match

### Signals

Godot's observer/event pattern, built into the language:

```gdscript
signal health_changed(old_value, new_value)

func _ready():
    health_changed.connect(_on_health_changed)
    health_changed.emit(100, 80)
```

- Prefer signals over direct node references for decoupling. Connecting in the editor is also possible. Tutorial: https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- `emit()` and `connect()` are methods on the signal; `.bind()` attaches extra arguments.
- Signal names should be snake_case, past tense, when possible: `signal door_opened`, `signal score_changed`.

### Coroutines and `await`

`await` suspends a function until a signal fires, another coroutine completes, or the engine returns control:

```gdscript
func wait_confirmation():
    print("Prompting user")
    await $Button.button_up
    print("User confirmed")
    return true

func request_confirmation():
    var confirmed = await wait_confirmation()
```

- Awaiting a non-signal, non-coroutine value returns immediately without making the function a coroutine.
- If the awaited signal emits multiple parameters, `await` yields an `Array`; no parameters yield `null`.
- There is no `async` keyword; any function containing `await` becomes a coroutine and its callers should `await` it too.
- Timers: `await get_tree().create_timer(1.0).timeout`.

### Integer division

`/` on two `int` operands is integer division: `5 / 2 == 2`, not `2.5`. Force a float with `2.0`, `float(x)`, or `x * 1.0`. Also `%` is int-only (use `fmod()` for floats) and truncates toward zero for negatives (use `posmod()`/`fposmod()`).

### Ternary is Python-style, not C-style

```gdscript
var x = "yes" if condition else "no"
next_state = "idle" if is_on_floor() else "fall"
```

### Lambdas (Callables)

```gdscript
var lambda = func (x): return x * 2   # return is REQUIRED in single-line bodies
lambda.call(42)                        # must be called via .call()
```

- Functions are first-class `Callable` values; pass them by name (`arr.map(add_one)`) and call them with `.call()`. Direct `callable()` invocation is not allowed.
- Locals are captured by value at creation; reassigning the captured variable outside the lambda afterwards is not seen by the lambda. Arrays/dictionaries/objects are captured by reference.

### Typed arrays and dictionaries

```gdscript
var scores: Array[int] = []
var items: Dictionary[String, int] = {}   # Godot 4.4+
```

- Plain `Array` means `Array[Variant]`. Typed arrays are not covariant: `Array[Node2D]` cannot be assigned to an `Array[Node]` variable; use `b.assign(a)` to copy contents.
- Packed arrays (`PackedFloat32Array`, `PackedVector2Array`, etc.) are more memory-efficient for large uniform data.
- Dictionaries also support Lua-style syntax without quotes: `var d = {name = "item", count = 3}` and dot access `d.name`.

### Node path shorthand

`$Node/Label` is shorthand for `get_node("Node/Label")`; `$"Node Name"` for names with special characters; `%UniqueName` for scene-unique nodes. Results are untyped; use `as` or an explicit type for static typing: `var sprite := $Sprite as Sprite2D`.

### Other gotchas

- Boolean literals are `true`/`false` (lowercase), `null` for nothing.
- `and`, `or`, `not` are preferred over `&&`, `||`, `!` (which exist but violate the style guide).
- `**` is left-associative: `2 ** 2 ** 3 == (2 ** 2) ** 3`.
- `super(args)` calls the parent implementation of the current method; `super.method()` calls any parent method.
- Inner classes are declared with `class SomeInnerClass:` and instantiated with `SomeInnerClass.new()`.
- `class_name Foo` registers a global class type; `extends` defaults to `RefCounted`; no multiple inheritance.
- `_init()` is the constructor; `_ready()` runs when the node enters the scene tree; static constructors use `static func _static_init():`.
- Format strings use the `%` operator: `"%s was reluctant to learn %s." % ["Estragon", "GDScript"]`, `%d%%` for a literal percent. Reference: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html
- Prefer static typing: annotate types on parameters, returns, and variables; use `-> type` for return types. There is no `void` except as a return-type annotation for functions that return nothing. See the "Static typing" style rules below for when `:=` inference is appropriate. Reference: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html

## Style guide (mandatory)

Follow the official style guide: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html

### Naming

| Element | Convention | Example |
|---|---|---|
| File names | snake_case | `yaml_parser.gd` |
| `class_name` classes | PascalCase | `YAMLParser` |
| Node names | PascalCase | `Camera3D`, `Player` |
| Functions | snake_case | `load_level()` |
| Variables | snake_case | `particle_effect` |
| Signals | snake_case, past tense | `door_opened`, `score_changed` |
| Constants | CONSTANT_CASE | `MAX_SPEED` |
| Enum names | PascalCase, singular | `enum Element` |
| Enum members | CONSTANT_CASE | `EARTH`, `WATER` |

- For a class named `Weapon`, the file is `weapon.gd`.
- Prefix virtual methods, private functions, and private variables with a single underscore: `var _counter = 0`, `func _recalculate_path():`.

### Declaration order

```text
01. @tool, @icon, @static_unload
02. @abstract (if the class is abstract; Godot 4.5+)
03. class_name
04. extends
05. ## doc comment

06. signals
07. enums
08. constants
09. static variables
10. @export variables
11. remaining regular variables
12. @onready variables

13. _static_init()
14. remaining static methods
15. overridden built-in virtual methods:
    1. _init()
    2. _enter_tree()
    3. _ready()
    4. _process()
    5. _physics_process()
    6. remaining virtual methods
16. overridden custom methods (overrides of a parent script's methods)
17. remaining methods (public before private)
18. inner classes
```

This code order follows four rules of thumb:

1. Properties and signals come first, followed by methods.
2. Public comes before private.
3. Virtual callbacks come before the class's interface.
4. The object's construction and initialization functions, `_init` and `_ready`, come before functions that modify the object at runtime.

### Static typing

GDScript's static typing is optional but preferred. Declare a variable's type with `var health: int = 0` and a function's return type with `func heal(amount: int) -> void:`.

Use `:=` to let the compiler infer the type. Prefer `:=` when the type is written on the same line as the assignment (it is visible at a glance); otherwise write the type explicitly.

**Good**:

```gdscript
# The type can be int or float, and thus should be stated explicitly.
var health: int = 0

# The type is clearly inferred as Vector3.
var direction := Vector3(1, 2, 3)
```

**Bad**:

```gdscript
# Typed as int, but it could be that float was intended.
var health := 0

# The type hint has redundant information.
var direction: Vector3 = Vector3(1, 2, 3)

# What type is this? It's not immediately clear to the reader.
var value := complex_function()
```

Include the type hint when the type is ambiguous, and omit it when it is redundant.

`get_node()` cannot infer a type beyond its declared return type, so state the type explicitly for node references:

```gdscript
@onready var health_bar: ProgressBar = get_node("UI/LifeBar")
```

Alternatively, cast with `as` and let that infer the type: `@onready var health_bar := get_node("UI/LifeBar") as ProgressBar`. The `as` cast is more type-safe than a hint, but less null-safe: on a type mismatch at runtime it silently sets the variable to `null` without an error or warning.

### Formatting

- Indent with **tabs**, not spaces (editor default). Continuation lines use two indent levels, except array/dictionary/enum literals which use one.
- Keep lines under 100 characters (ideally under 80). One statement per line; the ternary operator is the only exception.
- Double quotes by default; single quotes only when they avoid escaping: `print('hello "world"')`.
- Use `and`/`or`/`not`, not `&&`/`||`/`!`.
- No leading or trailing zero omission in numbers (`0.234`, `13.0`), lowercase hex (`0xfb8c0b`), underscores for large numbers (`1_234_567_890`).
- Use trailing commas on the last line of multiline arrays/dictionaries/enums.
- Comments and doc comments start with a space: `# Comment text.` and `## Doc comment.` Doc comments (`##`) are extracted as class documentation. Keep comments on their own line unless they are a few short inline words.
- Two blank lines surround functions and class definitions; one blank line inside functions to separate logical sections.

### Template

```gdscript
@tool
class_name MyThing
extends Node
## Short description of the class.
##
## Longer description if needed.

signal something_happened(item)

enum State {IDLE, RUNNING}

const MAX_SPEED = 200.0

@export var speed: float = 100.0

var _is_running := false

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    something_happened.connect(_on_something_happened)

func _on_something_happened(item) -> void:
    pass

func _do_internal_work() -> void:
    pass
```

## Workflow

1. When writing or reviewing a `.gd` file, check the declaration order and naming table above first; these are cheap to verify and the most visible style failures.
2. When node references are involved, confirm `@onready` is used (or assignment happens in `_ready()`), and that `@export` is used for inspector-exposed values.
3. For branching logic over shapes of data (arrays, dictionaries, types), prefer `match` with destructuring and `when` guards over nested `if` chains.
4. When in doubt about syntax, check the reference page rather than guessing from Python or JavaScript habits: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html
