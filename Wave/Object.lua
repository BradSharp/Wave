local Object	= {__index={}}

function Object.new(T, properties, children)
	return setmetatable({
		__class = T,
		__properties = properties,
		__children = children
	}, Object)
end

return Object