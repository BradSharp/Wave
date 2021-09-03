# Event

An event is a field type used to denote the name of an event to connect to.

## Example

```lua
Wave.new("TextButton", {
	[Wave.Event.Activated] = function ()

	end
})
```