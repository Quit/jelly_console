Jelly.Console+
=====


Jelly.Console+ is changing and extending Stonehearth's in-game console.

## Features

* Configurable hotkey to open/close the console
* Arrow keys can be used to the input history. Persistent through game restarts.
* Extended command parser that is capable of arguments with whitespace in it
* Simple lua binding to easily add lua-sided functions
* Resizable output window using console commands

## Configuration

Jelly.Console+ adds three new entries in your `user_settings.json` after the first start:

```json
{
	"mods" : {
		"jelly_console" : {
			"console_key" : 192,
			"height" : "200",
			"last_lines" : []
		}
	}
}
```

- **`console_key`** is the key that is used to open the console, the default is 192. To figure out which number you have to use, you can use [this page](http://jsfiddle.net/9uLedsg9/2/embedded/result/). Simply click into the yellow bit, press your desired key and it should write on the page which number to use. This may not work in all browsers, you might need to work Chrome or one of its derivates.
- **`height`** is the height of the console, in pixels. This should not be smaller than 50 or taller than 500.
- **`last_lines`** simply contains your history and can be ignored. It is not configuration relevant.

## Command syntax

Usually, each argument is separated by a whitespace, so `Hello World` would become `["Hello", "World"]`. To avoid this, Jelly.Console+ introduces the concept of "long strings" which work in a similar way as for example verbatim strings in C#. The rules for them are somewhat simple:

- Each long string starts and ends with the same quotation mark, which can be either `'` or `"`.
Valid: `"Hello World"`, invalid: `"Hello World'`
- Within long strings, it's possible to use the other quotation mark without any special syntax.
Example: `"How's the weather, partner?" 'This is not "Sparta".'` will result in `[ "How's the weather, partner?", "This is not \"Sparta\".' ]`
- Within long strings, the quotation mark used to mark it can be escaped by using it twice.
Example: `'How''s the weather, partner?' "This is not ""Sparta""."`
- Double quotation marks at the start or end of a parameter, long or short, will count as escaped and therefore will be cut down.
Example: `""Quote"" ''Unquote'' "This is not ""Sparta"""` will result in `["\"Quote\", "\"Unquote\"", "This is not \"Sparta\""]`

If you are confused about how it works, there's a built-in command, `show_arguments` which will return the parameters in the new format to you.

There are functions that do not need this advanced parsing up to the point where it could be impossible to use it (for example, `eval`). These functions are named below with an '@' at the beginning and can be called as such. For example, `eval return false -- "^^` will claim that there is an unfinished long string, whereas `@eval return false -- "^^` will work as expected. **This will turn off command parsing altogether, however** - some functions therefore require it to be enabled at all time. For these functions, their @-counterpart does not exist.

All commands that take as first argument an entity require either a "link" to the entity (as a string, like `"object://game/1234"`) or they will use the last selected entity (by clicking on it in the world, followed by the command `select`).

## Writing your own commands
Have a look at the [example commands](example_commands.lua) that I've included for learning purposes (they are not activated in normal installations). You can of course also check out the source of the [server commands](server_commands.lua)

## Built-in commands

### `@ show_arguments ...`
Debugging function. As `@show_arguments`, it will return the arguments the same way any function receives them when called in "plain mode". Without the @, it will return arguments parsed, just like commands normally receive them.

### `  expand [size]`
If `size` is set, expands the console output to that size, otherwise expands it a little.

### `  shrink [size]`
If `size` is set, shrinks the console to that size, otherwise shrinks it a little.

### `@ kill [entity]`
Kills `entity`. This will be a rather swift and direct death which may not invoke any observers that usually watch for kills. If `entity` was not specified, the selected entity is used instead.

### `@ destroy [entity]`
Destroys (effectively removes) `entity`. If `entity` was not specified, the selected entity is used instead.

### `@ set_attribute [entity] attribute_name attribute_value`
Sets `attribute_name` of `entity` to `attribute_value`. For example, `set_attribute health 100` to completely heal a previously selected citizen, or `set_attribute health 0` to kill him/her instead. If `entity` was not specified, the selected entity is used instead.

### `@ get_attribute [entity] attribute_name`
Returns the current value of `attribute_name` of `entity`. For example, `get_attribute mind` will return the previously selected citizen's mind stat. If `entity` was not specified, the selected entity is used instead.

### `@ get_attributes [entity]`
Returns all public attributes and their current value of `entity`. If `entity` was not specified, the selected entity is used instead.

### `@ set_scale [entity] scale`
Sets the renderscale of `entity`. Note that `1` is rarely the normal size of an entity. If `entity` was not specified, the selected entity is used instead.

### `@ get_scale [entity]`
Returns the renderscale of `entity`. If `entity` was not specified, the selected entity is used instead.

### `   set_model_variant [entity] variant_name`
Sets the model variant of `entity` to `variant_name`. For example, `set_model_variant depleted` will set any previously selected wild crop to its "recently harvested" model. If `entity` was not specified, the selected entity is used instead.

### `  get_model_variant [entity]`
Returns the current model variant of `entity`. If `entity` was not specified, the selected entity is used instead.

### `@ set_pos [entity] x y z`
Sets the position of `entity` to `(x, y, z)`. If `entity` was not specified, the selected entity is used instead.

### `@ get_pos [entity]`
Returns the position of `entity`.

### `@ add_buff [entity] uri`
Adds the buff located at `uri` to `entity`.  If `entity` was not specified, the selected entity is used instead.

### `@ set_display_name [entity] name`
Sets the display name of `entity` to everything that follows after the first argument.  If `entity` was not specified, the selected entity is used instead.

### `@ get_display_name [entity]`
Returns the display name of `entity`. ### `@ set_display_name [entity] name`
Sets the display name of `entity` to everything that follows after the first argument.  If `entity` was not specified, the selected entity is used instead.

### `@ set_name [entity] name`
Sets the name of `entity` to everything that follows after the first argument.  If `entity` was not specified, the selected entity is used instead.

### `@ think [entity] uri`
Forces `entity` to think `uri`. These are the thought bubbles for sleep or hunger that appears over their heads. This "thought" will persist until `unthink` is called. If `entity` was not specified, the selected entity is used instead.

### `@ unthink [entity] uri`
Forces `entity` to stop thinking about `uri`. If `entity` was not specified, the selected entity is used instead.

### `@ equip_item [entity] (equipment_uri|equipment_entity)`
Equips something on `entity`. If the second argument is a string, said entity is created. If `entity` was not specified, the selected entity is used instead.

### `@ unequip_item [entity] uri`
Unequips equipment of type `uri` on `entity`. If `entity` was not specified, the selected entity is used instead.

### `@ get_equipment [entity]`
Lists all equipment items currently on `entity`. If `entity` was not specified, the selected entity is used instead.

### `@ run_effect [entity] uri`
Runs an effect on `entity`. Note that this effect cannot be stopped. If `entity` was not specified, the selected entity is used instead.