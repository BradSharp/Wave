local Binding	= {__index={}}

function Binding.new(initialValue)
	return setmetatable({
		__subscribers = {},
		__scheduled = false,
		__value = initialValue,
		__last = nil,
	}, Binding)
end

function Binding.computeFrom(...)
	local bindings = {...} -- TODO: Should we verify bindings doesn't contain a cyclic reference?
	local compute = table.remove(bindings)
	local self = Binding.new()
	local function callback()
		local values = {}
		for i, binding in ipairs(bindings) do
			values[i] = binding:Get()
		end
		self:Set(compute(unpack(values, 1, #bindings)))
	end
	for i, binding in ipairs(bindings) do
		binding:Track(callback)
	end
	callback()
	return self
end

function Binding.__index:Get()
	return self.__value
end

function Binding.__index:__resume()
	local oldValue, newValue = self.__last, self.__value
	self.__scheduled = false
	self.__last = nil
	for _, subscriber in ipairs(self.__subscribers) do
		subscriber(oldValue, newValue)
	end
end

function Binding.__index:Set(newValue)
	self.__value, self.__last = newValue, self.__value
	if not self.__scheduled then
		self.__scheduled = true
		task.defer(self.__resume, self)
	end
end

function Binding.__index:Track(callback)
	if table.find(self.__subscribers, callback) then
		return
	end
	table.insert(self.__subscribers, callback)
	return function ()
		self:Untrack(callback)
	end
end

function Binding.__index:Untrack(callback)
	for i, subscriber in ipairs(self.__subscribers) do
		if subscriber == callback then
			table.remove(self.__subscribers, i)
			break
		end
	end
end

return Binding