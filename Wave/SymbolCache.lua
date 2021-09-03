local SymbolCache = {}

function SymbolCache.new()
	return setmetatable({
		__tostring = function (self)
			return self.Key
		end,	
	}, SymbolCache)
end

function SymbolCache:__index(index)
	local value = setmetatable({
		Key = index	
	}, self)
	rawset(self, index, value) -- cache the value so future lookups are cheaper
	return value
end

return SymbolCache