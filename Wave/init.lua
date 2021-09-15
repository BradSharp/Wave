local Wave			= {}
local Platform		= require(script.Platform)
local State			= require(script.State)
local Object		= require(script.Object)
local App			= require(script.App)
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

local function processProperty(app, subscriptions, object, key, value)
	local ValueType = getmetatable(value)
	if ValueType == State then
		table.insert(subscriptions, value:Track(function (_, newValue)
			Platform.markDirty(object, key.Index, newValue)
		end))
		Platform.assign(object, key.Index, value:Get())
		return
	end
	Platform.assign(object, key.Index, value)
end

local function processEvent(app, subscriptions, object, key, value)
	table.insert(subscriptions, Platform.connect(object, key.Index, value))
end

local function processChange(app, subscriptions, object, key, value)
	local ValueType = getmetatable(value)
	local handler = value
	if ValueType == State then
		handler = function (newValue)
			value:Set(newValue)
		end
	end
	table.insert(subscriptions, Platform.changed(object, key.Index, handler))
end

local function processLayer(app, subscriptions, object, properties)
	local LayerType = getmetatable(properties)
	if LayerType == State then
		error("State is not yet supported for layers")
	else
		for key, value in pairs(properties) do
			if type(key) == "string" then
				key = Property[key]
			end
			local KeyType = getmetatable(key)
			if KeyType == Property then
				processProperty(app, subscriptions, object, key, value)
			end
		end
	end
end

local computeChildren

local function processObjectNode(app, objectNode, parent)
	local T, properties, children = objectNode.__class, objectNode.__properties, objectNode.__children
	if type(T) == "function" then
		return T(properties, children)
	end
	local object = Platform.new(T.Index)
	local subscriptions = {}
	if children then
		if getmetatable(children) == State then
			processProperty(subscriptions, object, Property.Children, children:Chain(function (value)
				return computeChildren(app, value)
			end))
		else
			processProperty(subscriptions, object, Property.Children, computeChildren(app, children))
		end
	end
	local layers = {}
	for key, value in pairs(properties) do
		if type(key) == "string" then
			key = Property[key]
		end
		local KeyType = getmetatable(key)
		if KeyType == Property then
			processProperty(app, subscriptions, object, key, value)
		elseif KeyType == Event then
			processEvent(app, subscriptions, object, key, value)
		elseif KeyType == Change then
			processChange(app, subscriptions, object, key, value)
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

function computeChildren(app, value)
	local result = {}
	local function add(objectNode)
		if objectNode.__class == Class.Fragment then
			for i, childObject in ipairs(objectNode.__children) do
				add(childObject)
			end
		else
			table.insert(result, processObjectNode(app, objectNode))
		end
	end
	for i, v in ipairs(value) do
		add(v)
	end
	return result
end

function Wave.createApp(config, objectNode)
	local self = setmetatable({}, App)
	self.__children = computeChildren(self, {objectNode})
	return self
end

function Wave.createFragment(children)
	return Object.new(Class.Fragment, nil, children)
end

function Wave.createObject(T, properties, children)
	if type(T) == "string" then
		T = Class[T]
	end
	return Object.new(T, properties, children)
end

Wave.State = State
Wave.Class = Class
Wave.Property = Property
Wave.Event = Event
Wave.Change = Change
Wave.Layer = Layer

return Wave