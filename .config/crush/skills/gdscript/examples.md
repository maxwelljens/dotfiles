# GDScript — Unusual Constructs & Advanced Patterns

This document collects less common GDScript constructs that are nevertheless idiomatic and powerful. Use them when working with Godot 4.

## Inner Classes with `class`

You can declare lightweight inner classes for data structures or helper objects.

```gdscript
class InventorySlot:
    var item_id: int
    var quantity: int

    func is_empty() -> bool:
        return quantity == 0

var slots: Array[InventorySlot] = []
```

- Inner classes are reference types; they are not resources.
- They can have methods, signals, and static functions.

## `match` with Complex Patterns

`match` can destructure arrays, dictionaries, and even use binding patterns.

```gdscript
var data = {"type": "damage", "amount": 25, "element": "fire"}

match data:
    {"type": "heal", "amount": var amt}:
        apply_heal(amt)
    {"type": "damage", "amount": var amt, "element": var elem}:
        apply_damage(amt, elem)
    _:
        print("Unknown action")
```

- Use `var` to capture a value.
- Patterns can be nested arrays/dictionaries.
- Constants can be used as pattern values.

## Typed Arrays of Custom Resources

Arrays can be typed not just with built-ins, but with your own classes.

```gdscript
class_name Weapon extends Resource
@export var damage: float

var inventory: Array[Weapon] = []
```

- The editor will allow you to edit such arrays in the inspector if exported.
- You can also use `Array[Node]` or `Array[PackedScene]`.

## Using `Callable` and `.bind()` for Parameterised Connections

`.bind()` creates a new Callable with arguments pre-filled.

```gdscript
for i in range(3):
    var button := Button.new()
    button.pressed.connect( _on_button_pressed.bind(i) )
    add_child(button)

func _on_button_pressed(index: int) -> void:
    print("Button ", index, " pressed")
```

- Unbound arguments are passed after the bound ones.
- Use `.unbind()` to remove bound arguments.
- You can also store `Callable` in variables and pass them around.

## Coroutines with `await` and Signal Chaining

Chain multiple asynchronous steps using `await`.

```gdscript
func enter_combat() -> void:
    print("Prepare!")
    await get_tree().create_timer(1.0).timeout
    print("Fight!")
    await _play_animation("attack")
    print("Enemy defeated")

func _play_animation(name: String) -> Signal:
    $AnimationPlayer.play(name)
    return $AnimationPlayer.animation_finished
```

- Returning a signal from a function allows clean chaining.
- You can also `await` directly on a signal: `await $Timer.timeout`.

## `@onready` with Complex Initialisation (Lazy Load)

`@onready` can execute any expression, not just simple node access.

```gdscript
@onready var player_list: Array[Node] = _find_all_players()
@onready var config: Dictionary = _load_config("res://config.json")
```

- This is especially useful if the operation depends on the scene tree being ready.
- Heavy initialisation is deferred until the node enters the scene.

## Bit Flag Enums (Flag System)

Godot can treat enums as bit flags when values are powers of two.

```gdscript
enum DamageType { NONE = 0, FIRE = 1, ICE = 2, LIGHTNING = 4, POISON = 8 }

@export var vulnerabilities: int = DamageType.FIRE | DamageType.ICE

func is_vulnerable_to(type: DamageType) -> bool:
    return (vulnerabilities & type) != 0
```

- Use bitwise OR `|` to combine, `&` to check.
- Great for filters, capabilities, or attributes.

## `@export_enum` with String Labels

Better UI than raw integers.

```gdscript
@export_enum("Warrior", "Mage", "Rogue") var character_class: String = "Warrior"
```

- The inspector shows a dropdown with the given strings.
- The variable receives the selected string.

## Static Variables and Functions (Class-Level)

`static` methods and variables belong to the class, not instances.

```gdscript
class_name GameSettings
extends RefCounted

static var master_volume: float = 1.0

static func get_volume_db() -> float:
    return linear_to_db(master_volume)
```

- Use them for utility functions or singleton-like data without a full autoload.
- Cannot access instance members (`self`).

## Using `is` and `as` for Safe Type Casting

```gdscript
if node is Player:
    var p := node as Player
    p.heal(10)
```

- `is` checks the type without casting; `as` returns `null` if incompatible.
- Prefer `is` + `as` over `node.name == "Player"`.
- You can also use `node is Player` inside a `match` pattern guard.

## Custom Resources with `@export` for Designer-Friendly Data

Define a resource and use it in exported variables.

```gdscript
class_name SpellData extends Resource
@export var name: String
@export var mana_cost: int
@export var damage: float

# In a character script
@export var spell: SpellData
```

- Create a new resource file, set values in the inspector, and reuse across scenes.
- Makes balancing and prototyping very fluid.

## `@tool` Scripts That Run in the Editor

Add `@tool` at the top to make the script execute inside the editor.

```gdscript
@tool
extends Node2D

@export var radius: float = 100.0:
    set(value):
        radius = value
        queue_redraw()

func _draw() -> void:
    draw_circle(Vector2.ZERO, radius, Color.RED)
```

- Great for custom visualisers, debug drawing, or editor plugins.
- Remember to check `Engine.is_editor_hint()` if you want different behavior at runtime.

## Lambda-like Behaviour with `Callable` from Methods

GDScript doesn't have anonymous functions, but you can use a method as a callable.

```gdscript
var callbacks: Array[Callable] = []

func _ready() -> void:
    callbacks.append(_my_callback)
    callbacks[0].call("hello")

func _my_callback(msg: String) -> void:
    print(msg)
```

- For custom arguments, use `.bind()` on the method callable.
- For one-shot callables, `func()` expression syntax is planned for future Godot versions (Godot 4.x doesn't have it yet).

## `Dictionary` as Lightweight Struct

When you don't need a full class, use a `Dictionary`.

```gdscript
var player_info = {
    "name": "Grog",
    "health": 150,
    "inventory": ["sword", "shield"]
}
player_info["health"] -= 10
```

- Dot notation (`player_info.name`) works only if the key is a valid identifier.
- Dictionaries are passed by reference, so be careful with shared mutable data.
