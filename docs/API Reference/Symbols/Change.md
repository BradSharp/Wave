# Change

A change is a field type used to denote the name of a property to track the value of.

## Example

```lua
Wave.new("TextBox", {
	[Wave.Change.Text] = function (value)

	end
})
```