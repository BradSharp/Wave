# Wave


!!! hint
	This is a test

??? Test2

``` lua
local tree = Wave.new("ScreenGui", {
	IgnoreGuiInset = true,
	Parent = PlayerGui
}, {
	Wave.new("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		--BackgroundColor3 = color,
		Name = "Frame"
	}, {
		Wave.new("TextBox", {
			Size = UDim2.new(0, 200, 0, 50),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 1),
			Text = "",
			[Wave.Binding.Text] = input
		}),
		Wave.new("TextLabel", {
			Size = UDim2.new(0, 200, 0, 50),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Text = message
		})
	})
})
```

Okay, but loreum impsum dolor dopsum etsum idk what I'm typing