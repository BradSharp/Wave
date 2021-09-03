# Property

A property is a field type used to denote the name of a property.

!!! hint
	Unlike other field types you never actually need to use property. Wave will automatically convert string fields to properties when assigning them to an object.
	```lua
	Wave.new(Object, {
		PropertyName = value
	})
	```
	is equivalent to
	```lua
	Wave.new(Object, {
		[Wave.Property.PropertyName] = value
	})
	```

## Example

```lua
Wave.new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
})
```