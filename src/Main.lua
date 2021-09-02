local Wave			= {}
local State			= require(script.State)
local SymbolCache	= require(script.SymbolCache)
local Property		= SymbolCache.new()
local Event			= SymbolCache.new()
local Binding		= SymbolCache.new()
local RunService	= game:GetService("RunService")
local dirty			= {}

local function flatten(value)
	local result = {}
	local function doFlatten(t)
		for i, v in ipairs(t) do
			if type(v) == "table" then
				doFlatten(v)
			else
				table.insert(result, v)
			end
		end
	end
	doFlatten(value)
	return result
end

local function create(T)
	return Instance.new(T)
end

local function delete(instance)
	instance:Destroy()
end

local function onDelete(instance, callback)
	local connection
	connection = instance.AncestryChanged:Connect(function (_, newParent)
		if newParent then
			return
		end
		connection:Disconnect()
		callback()
	end)
end

local function assignParent(instance, parent)
	instance.Parent = parent
end

local function assignChildren(instance, value)
	local currentChildren = instance:GetChildren()
	local newChildren = type(value) == "table" and flatten(value) or {value}
	local set = {}
	for _, child in ipairs(currentChildren) do
		set[child] = false
	end
	for _, child in ipairs(newChildren) do
		set[child] = true
	end
	for child, allowed in pairs(set) do
		if allowed then
			assignParent(child, instance)
		else
			delete(child)
		end
	end
end

local function assign(instance, property, value)
	if property == "Parent" then
		task.defer(assignParent, instance, value)
		return
	elseif property == "Children" then
		assignChildren(instance, value)
		return
	end
	instance[property] = value
end

local function connect(instance, event, callback)
	local connection = instance[event]:Connect(callback)
	return function ()
		connection:Disconnect()
	end
end

local function bind(instance, property, callback)
	local connection = instance:GetPropertyChangedSignal(property):Connect(callback)
	return function ()
		connection:Disconnect()
	end
end

local function update()
	while next(dirty) do
		local instance, properties = next(dirty)
		for property, value in pairs(properties) do
			assign(instance, property, value)
		end
		dirty[instance] = nil
	end
end

RunService.RenderStepped:Connect(update)

function Wave.new(T, properties, children)
	local object = create(T)
	local subscriptions = {}
	properties[Property.Children] = children
	for key, value in pairs(properties) do
		if type(key) == "string" then
			key = Property[key]
		end
		local KeyType, ValueType = getmetatable(key), getmetatable(value)
		if KeyType == Property then
			if ValueType == State then
				local function queuePropertyUpdate(_, newValue)
					local properties = dirty[object]
					if not properties then
						properties = {}
						dirty[object] = properties
					end
					properties[key.Key] = newValue
				end
				table.insert(subscriptions, value:Track(queuePropertyUpdate))
				assign(object, key.Key, value:Get())
			else
				assign(object, key.Key, value)
			end
		elseif KeyType == Event then
			table.insert(subscriptions, connect(object, key.Key, value))
		elseif KeyType == Binding then
			local handler = value
			if ValueType == State then
				handler = function ()
					value:Set(object[key.Key])
				end
			end
			table.insert(subscriptions, bind(object, key.Key, handler))
		end
	end
	onDelete(object, function ()
		for i = 1, #subscriptions do
			table.remove(subscriptions)()
		end
		table.clear(subscriptions)
	end)
	return object
end

Wave.State = State
Wave.Property = Property
Wave.Event = Event
Wave.Binding = Binding

return Wave
