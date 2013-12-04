-- Copyright 2013 Arman Darini

local math = require "math"

----------------------------------------------------------
math.sign = function(value)
	if value > 0 then return 1; elseif value < 0 then return -1; else return 0; end
end

----------------------------------------------------------
math.round = function(x)
	return math.floor(x + 0.5)
end

----------------------------------------------------------
math.frac = function(x)
	return x - math.floor(x)
end

----------------------------------------------------------
math.clamp = function(x, min, max)
	return math.min(max, math.max(x, min))
end

----------------------------------------------------------
math.d = function(a, b)
	return ((a.x - b.x)^2 + (a.y - b.y)^2)^0.5
end

----------------------------------------------------------
math.vector = {}

----------------------------------------------------------
math.vector.dot = function(A, B)
	if A.x and B.x and A.y and B.y then
		return A.x * B.x + A.y * B.y
	else
		return A[1] * B[1] + A[2] * B[2]
	end
end

----------------------------------------------------------
math.vector.magnitude = function(A)
	if A.x and A.y then
		return (A.x^2 + A.y^2)^0.5
	else
		return (A[1]^2 + A[2]^2)
	end
end

return math