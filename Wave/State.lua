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
		for i, state in ipairs(states) do
			values[i] = state:Get()
		end
		self:Set(compute(unpack(values, 1, #states)))
	end
	for i, state in ipairs(states) do
		state:Track(callback)
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
	local index = table.find(self.__subcribers, callback)
	table.remove(self.__subscribers, index)
end

function State.__index:Chain(operator)
	local state = State.new(operator(self.__value))
	self:Track(function (_, value)
		state:Set(operator(value))
	end)
	return state
end

function State:__tostring()
	return "State(" .. tostring(self.__value) ..")"
end


function State:__unm()
	return self:Chain(self, function (value)
		return -value
	end)
end

function State:__add(other)
	return self:Chain(function (value)
		return value + other
	end)
end

function State:__sub(other)
	return self:Chain(function (value)
		return value - other
	end)
end

function State:__mul(other)
	return self:Chain(function (value)
		return value * other
	end)
end

function State:__div(other)
	return self:Chain(self, function (value)
		return value / other
	end)
end

function State:__mod(other)
	return self:Chain(self, function (value)
		return value % other
	end)
end

function State:__pow(other)
	return self:Chain(self, function (value)
		return value ^ other
	end)
end

function State:__concat(other)
	return self:Chain(self, function (value)
		return value .. other
	end)
end

function State:__call(other)
	return self:Chain(self, function (value)
		return value[other]
	end)
end

return State