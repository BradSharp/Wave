# Wave

## Methods

### createApp

!!! typedef "App createApp(config : { string: any }, root : Object)"

Creates an app of the specified object type with the given properties assigned, and children parented to it.

??? example
	```lua
	local app = Wave.createApp({
		-- empty config
	}, Wave.createFragment())
	```

### createObject

!!! typedef "Object createObject(objectType : Class | string, properties : { Symbol, any }, children : any)"

Creates an object of the specified object type with the given properties assigned, and children parented to it.

??? example
	```lua
	local objectNode = Wave.createObject("TextBox", {
		TextColor = Color3.fromHex("ffffff"),
		PlaceholderText = "Type here...",
		[Wave.Change.Text] = textInput,
	})
	```

### createFragment

!!! typedef "Object createFragment(children : any)"

Creates a fragment object which can be used to create a hierarchy for children

??? example
	```lua
	local objectNode = Wave.createFragment({})
	```