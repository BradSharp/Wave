# Wave

## Methods

### createObject

!!! typedef "Object createObject(objectType : Class | string, properties : { Symbol, any }, children : any)"

Creates an object of the specified object type with the given properties assigned, and children parented to it.

??? example
	```lua
	local textBox = Wave.createObject("TextBox", {
		TextColor = Color3.fromHex("ffffff"),
		PlaceholderText = "Type here...",
		[Wave.Change.Text] = textInput,
	})
	```

<!-- ## State
<a href="state">See State →</a>

## Symbols
<a href="symbols">See Symbols →</a> -->