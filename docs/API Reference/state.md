# State

A state stores a value which can be changed and bound to properties or events.

## Static

### new

```
State State.new(initialValue : any)
```

Creates a new state initialized with the specified value

### computeFrom

```
State State.computeFrom(...states : ...State, compute : (values : ...any) -> any)
```

Creates a new state which is computed from a set of existing states. Whenever one of the existing states is updated the compute function is called with all the values of each state.

??? example
	```lua
	local firstName = Wave.State.new("John")
	local lastName = Wave.State.new("Smith")
	local fullName = Wave.State.computeFrom(firstName, lastName, function (first, last)
		return first .. " " .. last
	end)
	```

## Members

### Get

```
any State:Get()
```

Returns the value current stored by the state

### Set

```
void State:Set(value : any)
```

Sets the value stored by the state

### Track

```
() -> () State:Track(callback : (oldValue : any, newValue : any) -> void)
```

Tracks changes to the value by calling the callback each time the value is updated. Returns a function which stops tracking changes for the callback when called.

### Untrack

```
void State:Untrack(callback : (oldValue : any, newValue : any) -> void)
```

Removes the callback from the tracking list

### Chain

!!! danger "Experimental"
	This feature is experimental and may be removed in the future without warning

```
State State:Chain(compute : (value : any) -> any)
```

Creates a new State which computes a value from the current state.

??? example
	```lua
	local count = Wave.State.new(2)
	local double = count:Chain(function (value)
		return value * 2
	end)
	```