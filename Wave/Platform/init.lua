local Platform	= {}
local None		= {}
local dirty		= {}
local updateId	= 0

local function delete(object)
	object:Destroy()
end

local function assignParent(object, parent)
	object.Parent = parent
end

local function assignChildren(object, value)
	local currentChildren = object:GetChildren()
	local newChildren = value
	local set = {}
	for _, child in ipairs(currentChildren) do
		set[child] = false
	end
	for _, child in ipairs(newChildren) do
		set[child] = true
	end
	for child, allowed in pairs(set) do
		if allowed then
			assignParent(child, object)
		else
			delete(child)
		end
	end
end

function Platform.new(class)
	return Instance.new(class)
end

function Platform.assign(object, property, value)
	if property == "Parent" then
		task.defer(assignParent, object, value)
	elseif property == "Children" then
		assignChildren(object, value)
	else
		object[property] = value
	end
end

function Platform.deleted(object, callback)
	local connection
	connection = object.AncestryChanged:Connect(function (_, newParent)
		if newParent then
			return
		end
		connection:Disconnect()
		callback()
	end)
end

function Platform.connect(object, event, callback)
	local connection = object[event]:Connect(callback)
	return function ()
		connection:Disconnect()
	end
end

function Platform.changed(object, property, callback)
	local connection = object:GetPropertyChangedSignal(property):Connect(function ()
		callback(object[property])
	end)
	return function ()
		connection:Disconnect()
	end
end

local function update()
	while next(dirty) do
		local instance, properties = next(dirty)
		for property, value in pairs(properties) do
			if value == None then
				Platform.assign(instance, property, nil)
			else
				Platform.assign(instance, property, value)
			end
		end
		dirty[instance] = nil
	end
end

local function tryUpdate(id)
	if id == updateId then
		updateId = 0
		update()
	end
end

function Platform.markDirty(object, property, value)
	local properties = dirty[object]
	if not properties then
		properties = {}
		dirty[object] = properties
	end
	if value == nil then
		value = None
	end
	properties[property] = value
	updateId = updateId + 1
	task.defer(tryUpdate, updateId)
end

return Platform
