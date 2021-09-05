# Symbols

Symbols are used by Wave to represent fields or types as constants

## Class

!!! typedef "Wave.Class[.symbolName]"

A class symbol represents a type of object that can be created on the platform you are using.

!!! hint
	Wave will automatically create a class symbol when you pass a string as the first argument to `createObject` so you never actually need to create one yourself.

??? example
	```lua hl_lines="1"
	Wave.createObject(Wave.Class.TextBox, {
		[Wave.Property.TextColor] = Color3.fromHex("ffffff"),
		[Wave.Event.MouseClick] = event,
		[Wave.Change.Text] = textInput,
	})
	```

## Property


!!! typedef "Wave.Property[.symbolName]"

A property symbol represents an assignable property of the object.

!!! hint
	Wave will automatically create a property symbol when you use a string in the properties table of `createObject` so you never actually need to create one yourself.

??? example
	```lua hl_lines="2"
	Wave.createObject(Wave.Class.TextBox, {
		[Wave.Property.TextColor] = Color3.fromHex("ffffff"),
		[Wave.Event.MouseClick] = event,
		[Wave.Change.Text] = textInput,
	})
	```

## Event

!!! typedef "Wave.Event[.symbolName]"

An event symbol represents an event which can be listened to on the object.

??? example
	```lua hl_lines="3"
	Wave.createObject(Wave.Class.TextBox, {
		[Wave.Property.TextColor] = Color3.fromHex("ffffff"),
		[Wave.Event.MouseClick] = event,
		[Wave.Change.Text] = textInput,
	})
	```

## Change

!!! typedef "Wave.Change[.symbolName]"

A change symbol represents a property which invokes an event when it's value changes.

??? example
	```lua hl_lines="4"
	Wave.createObject(Wave.Class.TextBox, {
		[Wave.Property.TextColor] = Color3.fromHex("ffffff"),
		[Wave.Event.MouseClick] = event,
		[Wave.Change.Text] = textInput,
	})
	```