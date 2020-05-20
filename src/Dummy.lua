--Dummy = Class{__includes = Entity}
Dummy = Class{}

function Dummy:init(def)
    self.world = def.world --maintain reference to the world

    -- position in the world
    self.pos = def.pos or Vector.new(math.random(0, WIDTH), math.random(0, HEIGHT))

    self.res = def.res or 8
    self.radius = 150
    self.body = Membrane(self)
    self.verticies = self.body.verticies

    self.organs = {}
    --[[for i=1, 3 do
        local organelle = Organelle(self)
        self.organs[organelle] = organelle
    end
    ]]

    -- not sure if I want polygon body to mimic b2d shapes and fixtures...
    -- I think I might want to do this for collision detection
    --self.shape = Membrane:getShape()
    --self.fixture = Membrane:getFixture()

    -- collection of the traits that are able to be mutated
    -- self.mutable_traits = {}
end

function Dummy:update(dt)

    for _, o in pairs(self.organs) do
        o:update(dt)
    end
    self.body:update(dt)
    self.pos = Vector(self.body:getPosition())
end

function Dummy:render()

    -- light pink, I think
    --love.graphics.setColor(.3,0,5, 3)
    --love.graphics.polygon('fill', unpack(self:getPoints()))

    --TODO reconsider this
    self.body:render()

    for _, o in pairs(self.organs) do
        o:render()
    end
end

--------------------------------------------------------------------------------

function Dummy:getPoints()
    local points = {}
    for i, vertex in ipairs(self.verticies) do
        local iy = 2*i
        local ix = iy - 1
        --[[ i   2i   2i-1
            1   2     1
            2   4     3
            3   6     5
        ]]
        points[ix] = vertex.pos.x
        points[iy] = vertex.pos.y
    end
    return points
end

--------------------------------------------------------------------------------
function Dummy:type()
    return 'Dummy'
end

function Dummy:typeOf(name)
    return name == self:type()
end

function Dummy:__tostring()
    return "Dummy"
end
