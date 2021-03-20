Food = Class{}

function Food:init(def)

    self.world = def.world --maintain reference to the world
    self.id=0

    self.pos = def.pos or Vector.new(math.random(0, WIDTH), math.random(0, HEIGHT))

    self.energy = def.health or math.random() * HEALTHMAX

    self.col = {red = math.cos(self.energy),
                gre = math.sin(self.energy),
                blu = math.cos(self.energy)}

    self.radius = 5

    -- physical presence
    self.body = love.physics.newBody(self.world, self.pos.x, self.pos.y, 'dynamic')
    self.shape = love.physics.newRectangleShape(self.radius, self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(self)

end

function Food:update(dt)
    --TODO change over time
end

function Food:render()

    love.graphics.setColor(self.col.red, self.col.gre, self.col.blu, 1)
    local _ = love.graphics.getLineWidth()
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.radius, self.radius)
    love.graphics.setLineWidth(_)

end

--------------------

function Food:type()
    return 'Food'
end

function Food:typeOf(name)
    return name == self:type()
end
