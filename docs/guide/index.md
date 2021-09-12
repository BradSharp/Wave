# Getting Started

!!! attention
	This guide is targetted at Roblox developers but most of the information you find here will still be applicable to other platforms.

## Introduction

Wave is designed to be gradually adoptable so you can use it as little or as much as you want in your projects. This is one of the main advantages you get from using Wave over an alternative framework.

Similar to many web frameworks Wave offers a declarative approach. This allows you to describe what your app should look like without needing to consider how you're going to pass data around to each component.

If you want to learn more about the differences between Wave and other frameworks you can check out [Comparison with Other Frameworks](comparison).

## Installation

Right now, Wave is targetted at Roblox developers. You can download and insert an .rbxm into your place directly, use the _Tide_ plugin or add it as a git dependency.

??? info "via Tide"
	Tide is a work in progress and not yet available, please use an alternative method for now.

??? info "via rbxm"
	Once the build process is setup, you'll be able to grab a copy of Wave via rbxm through the releases section on GitHub

??? info "via git"
	Wave can be found on [GitHub](https://github.com/BradSharp/Wave/)

## Creating an App

Let's start by creating a simple app. First we must initialize our app using the `createApp` method. This allows us to configure different settings for our app as well as create it.

```lua
Wave.createApp(config, rootObject)
```

```lua
Wave.createApp({}, Wave.createObject("ScreenGui", {
	IgnoreGuiInset = true,
	Parent = game:GetService("Players").LocalPlayer.PlayerGui
}, {
	Wave.createObject("TextLabel", {
		Text = "Hello world!",
		TextColor3 = Color3.fromHex("ffffff"),
		BackgroundColor3 = Color3.fromHex("eff8fa"),
		Size = UDim2.fromScale(1, 1),
	})
}))
```

Great, we've just created our very first app using Wave! While our simple app is easy to get excited about it doesn't actually do much. We need some way to change the state of our app after it has been created.

## Managing State

States allow us to store data which can be retrieved or updated later on. They are one of the fundamental parts of any Wave app.

Creating a state is easy:

```lua
local count = Wave.State.new(0)
```

Once you have a state, it can be used directly in the place of a property. Take our example earlier, we can change the `Text` property of our TextLabel to be the newly created state:

```lua hl_lines="6"
Wave.createApp({}, Wave.createObject("ScreenGui", {
	IgnoreGuiInset = true,
	Parent = game:GetService("Players").LocalPlayer.PlayerGui
}, {
	Wave.createObject("TextLabel", {
		Text = count,
		TextColor3 = Color3.fromHex("ffffff"),
		BackgroundColor3 = Color3.fromHex("eff8fa"),
		Size = UDim2.fromScale(1, 1),
	})
}))
```

We can then update the state whenever we want and our app will automatically reflect this change.

```lua
for i = 1, 10 do
	task.wait(1) -- wait one second
	count:Set(count:Get() + 1)
end
```

With this, we now have a counter that will count up from zero to ten in ten seconds! But what if we only wanted the counter to increment when the user clicked a button?

## Handling Events

We can do more than just set properties when creating an object. Sometimes it can be useful listen to events on an object, such as when a user clicks it.

In this example we'll add a button with a counter on it that shows the number of times it has been clicked:

```lua hl_lines="19-21"
local count = Wave.State.new(0)

Wave.createApp({}, Wave.createObject("ScreenGui", {
	IgnoreGuiInset = true,
	Parent = game:GetService("Players").LocalPlayer.PlayerGui
}, {
	Wave.createObject("Frame", {
		BackgroundColor3 = Color3.fromHex("eff8fa"),
		Size = UDim2.fromScale(1, 1),
	}, {
		Wave.createObject("TextButton", {
			Text = count,
			Size = UDim2.fromOffset(200, 50),
			BackgroundColor3 = Color3.fromHex("eff8fa"),
			BorderColor3 = Color3.fromHex("ffffff"),
			BorderSizePixel = 2,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			[Wave.Event.MouseButton1Click] = function ()
				count:Set(count:Get() + 1)
			end
		})
	})
}))
```

<!-- Should I put something here about changes? Probably -->

States are clearly very useful then, but our button currently only shows the number of times it was clicked. It would be nice to add some additional text to go alongside that.

## Computing State

Sometimes it can be useful to compose a value using another value, that is where computed states come in.

In the previous example we saw how we could use a state to update a counter. We can create a new state from the count state which formats the value in a more user-friendly way.

```lua hl_lines="2-4 15"
local count = Wave.State.new(0)
local message = Wave.State.computeFrom(count, function (value)
	return "You have clicked " .. value .. " times"
end)

Wave.createApp({}, Wave.createObject("ScreenGui", {
	IgnoreGuiInset = true,
	Parent = game:GetService("Players").LocalPlayer.PlayerGui
}, {
	Wave.createObject("Frame", {
		BackgroundColor3 = Color3.fromHex("eff8fa"),
		Size = UDim2.fromScale(1, 1),
	}, {
		Wave.createObject("TextButton", {
			Text = message,
			Size = UDim2.fromOffset(200, 50),
			BackgroundColor3 = Color3.fromHex("eff8fa"),
			BorderColor3 = Color3.fromHex("ffffff"),
			BorderSizePixel = 2,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			[Wave.Event.MouseButton1Click] = function ()
				count:Set(count:Get() + 1)
			end
		})
	})
}))
```

Now everytime `count` is updated, our new state `message` will also update with the new value.

---

Ready for some more? Next up we'll learn how to make reusable [Components](components) for our app