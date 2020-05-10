Entity = Class{}

function Entity:init(def)
    --[[
    Defines common properties to all entities
    all game entities:
        1. exist in the same world,
        2. have an id,
        3. have a position,
        4. have some health value,
        5. have a colour,
        6. have a size / radius
        7. have some physical body
    ]]
    self.world = def.world --maintain reference to the world
    self.id=def.id

    self.pos = def.pos or Vector.new(math.random(0, WIDTH), math.random(0, HEIGHT))

    self.health = def.health or math.random() * HEALTHMAX
    self.col = def.col --{r,g,b}

    self.size = def.size

    self.body = def.body

end

function Entity:update(dt)
end

function Entity:render()
    --XXX this is just here to be over written later
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle('line', self.pos.x, self.pos.y, self.size/2)
    love.graphics.point(self.pos.x, self.pos.y)
end

--------------------------------------------------------------------------------
function Entity:type()
    return 'Entity'
end

function Entity:typeOf(name)
    return name == self:type()
end
