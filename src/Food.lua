Food = Class{__includes = Entity}

function Food:init(def)
    Entity.init(self, def)

    -- physical presence
    self.body = love.physics.newBody(self.world, self.pos.x, self.pos.y, 'dynamic')
    self.shape = love.physics.newRectangleShape(self.size, self.size)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(self)

end

function Food:update(dt)
    --TODO change over time
end

function Food:render()
    local body, shape, col = self.body, self.shape, self.col

    love.graphics.setColor(col.r, col.g, col.b, 1)
    love.graphics.polygon('fill', body:getWorldPoints(shape:getPoints()))

end

--------------------

function Food:type()
    return 'Food'
end

function Food:typeOf(name)
    return name == self:tyoe()
end
