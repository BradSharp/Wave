local Wave			= {}
local Platform		= require(script.Platform)
local State			= require(script.State)
local SymbolCache	= require(script.SymbolCache)
local Class			= SymbolCache.new()
local Property		= SymbolCache.new()
local Event			= SymbolCache.new()
local Change		= SymbolCache.new()

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

local function computeChildren(value)
	return type(value) == "table" and flatten(value) or {value}
end

local function processProperty(subscriptions, object, key, value)
	local ValueType = getmetatable(value)
	if ValueType == State then
		table.insert(subscriptions, value:Track(function (_, newValue)
			Platform.markDirty(object, key.Name, newValue)
		end))
		Platform.assign(object, key.Name, value:Get())
		return
	end
	Platform.assign(object, key.Name, value)
end

local function processEvent(subscriptions, object, key, value)
	table.insert(subscriptions, Platform.connect(object, key.Name, value))
end

local function processChange(subscriptions, object, key, value)
	local ValueType = getmetatable(value)
	local handler = value
	if ValueType == State then
		handler = function (newValue)
			value:Set(newValue)
		end
	end
	table.insert(subscriptions, Platform.changed(object, key.Name, handler))
end

function Wave.createObject(T, properties, children)
	-- Component
	if type(T) == "function" then
		return T(properties, children)
	end
	-- Fundamental
	if type(T) == "string" then
		T = Class[T]
	end
	local object = Platform.new(T.Name)
	local subscriptions = {}
	if children then
		if getmetatable(children) == State then
			processProperty(subscriptions, object, Property.Children, children:Chain(computeChildren))
		else
			processProperty(subscriptions, object, Property.Children, computeChildren(children))
		end
	end
	for key, value in pairs(properties) do
		if type(key) == "string" then
			key = Property[key]
		end
		local KeyType = getmetatable(key)
		if KeyType == Property then
			processProperty(subscriptions, object, key, value)
		elseif KeyType == Event then
			processEvent(subscriptions, object, key, value)
		elseif KeyType == Change then
			processChange(subscriptions, object, key, value)
		end
	end
	Platform.deleted(object, function ()
		for i = 1, #subscriptions do
			table.remove(subscriptions)()
		end
		table.clear(subscriptions)
	end)
	return object
end

Wave.State = State
Wave.Class = Class
Wave.Property = Property
Wave.Event = Event
Wave.Change = Change

return Wave