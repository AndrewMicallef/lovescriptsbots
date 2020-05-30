BindingSite = Class{__includes = Molecule}

-- A binding site is a special type of molecule. It is a sensor that can form a
-- molecular bond with certain types of molecules it comes into contact with.

BindingSite.__type = "BindingSite"

function BindingSite:init(props)
    self = Molecule(props)

    self.body = love.phsyics.newBody(self.loc.x, self.loc.y, 'static')
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setSensor(true)

    self.__debug = false

end

--[[
function BindingSite:update(dt)
end
--]]

function BindingSite:render()
    self.statemachine:render()

    if self.__debug then
        local x,y = self.body:getPosition()
        local r = self.radius

        love.graphics.setColor(gColor['white'])
        love.graphics.circle(x, y, r)
    end
end
