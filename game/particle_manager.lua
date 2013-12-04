-- Copyright 2013 Arman Darini

local Viewable = require("game.viewable")

local class = {}
class.new = function(o)
	local ParticleManager = {}
	Utils.mergeTable(ParticleManager, Viewable.new())

	----------------------------------------------------------
	function ParticleManager:init(o)
		self.view.owner = self
		self.particles = {}

		return self
	end

	----------------------------------------------------------
	function ParticleManager:update(deltaTime)
--		p("ParticleManager:update")
		for i = #self.particles, 1, -1 do
			local particle = self.particles[i]
			
			particle.age = particle.age + deltaTime
			if nil == particle.goal or nil == particle.goal.x then
				display.remove(particle.view)
				table.remove(self.particles, i)
			elseif particle.age > particle.maxAge then
				display.remove(particle.view)
				table.remove(self.particles, i)
			else
				local d = ((particle.goal.x - particle.view.x)^2 + (particle.goal.y - particle.view.y)^2)^0.5
				local step = math.min(particle.speed * deltaTime/1000, d)
				particle.view.x = particle.view.x + step * (particle.goal.x - particle.view.x)/d
				particle.view.y = particle.view.y + step * (particle.goal.y - particle.view.y)/d
				if particle.view.x == particle.goal.x and particle.view.y == particle.goal.y then
					particle.onImpact()
					table.remove(self.particles, i)
				end
			end
		end
	end
	
	----------------------------------------------------------
	function ParticleManager:add(particle)
		self.particles[#self.particles + 1] = particle
		particle.age = 0
		self.view:insert(particle.view)
	end
	----------------------------------------------------------
	return ParticleManager:init(o)
end

return class
