local State	= {__index={}}

function State.new(initialValue)
	return setmetatable({
		__subscribers = {},
		__value = initialValue
	}, State)
end

function State.computeFrom(...)
	local states = {...} -- TODO: Should we verify states doesn't contain a cyclic reference?
	local compute = table.remove(states)
	local self = State.new()
	local function callback()
		local values = {}
		for i, binding in ipairs(states) do
			values[i] = binding:Get()
		end
		self:Set(compute(unpack(values, 1, #states)))
	end
	for i, binding in ipairs(states) do
		binding:Track(callback)
	end
	callback()
	return self
end

function State.__index:Get()
	return self.__value
end

function State.__index:Set(newValue)
	local oldValue = self.__value
	self.__value = newValue
	for _, subscriber in ipairs(self.__subscribers) do
		subscriber(oldValue, newValue)
	end
end

function State.__index:Track(callback)
	if table.find(self.__subscribers, callback) then
		return
	end
	table.insert(self.__subscribers, callback)
	return function ()
		self:Untrack(callback)
	end
end

function State.__index:Untrack(callback)
	for i, subscriber in ipairs(self.__subscribers) do
		if subscriber == callback then
			table.remove(self.__subscribers, i)
			break
		end
	end
end

return State