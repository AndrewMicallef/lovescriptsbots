Vertex = Class{}

--[[
A vertex is a physical object with a body, circleshape, which is connected to
0 or more other verticies via spring joints
]]
function Vertex:init(def)
    self.parent = def.parent
    self.world = self.parent.world
    self.id = def.id --some unique ID
    self.x = def.x
    self.y = def.y
    self.edges = def.edges or {}
    self.edgelist = {}

    self.isselected = nil
    self.dragging = {active = false, diffX = 0, diffY = 0}

    self.body = love.physics.newBody(self.world, self.x, self.y, def.type or 'dynamic')
    self.shape = love.physics.newCircleShape(VERTEX_RADIUS)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.body:setUserData(self)

    self.forces = {}
    self.norm = Vector(0,0)
end

function Vertex:update(dt)

    --TODO consolidate forces
    -- for _, f in ipairs(forces) do fnet = fnet + f end
    local x,y = self.x, self.y
    local fnet = Vector.zero

    if self.dragging.active and love.mouse.isDown(1) then
        local cx, cy = love.mouse.getPosition( )
        local dx, dy = cx-x, cy-y
        self.body:setPosition(x + dx, y + dy)
    else
        if self.dragging.active then
            self.dragging.active = false end

        --for _, f in ipairs(self.forces) do fnet = fnet + f end
        --local dx, dy = fnet.x * dt, fnet.y * dt
        --self.body:setPosition(x + dx, y + dy)
    end

    self.forces = {}

    self.x, self.y = self.body:getPosition()
end

function Vertex:render()
    local vcol, ecol = {0,1,1,1}, {1,1,0,1}
    if self.isselected then
        vcol = {1,1,0,1}
        ecol = {1,0,1,1}
    end
    love.graphics.setColor(vcol)
    local cx, cy = self.body:getPosition()
    love.graphics.circle("line", cx, cy, VERTEX_RADIUS)

    love.graphics.line(cx, cy, self.norm.x + cx, self.norm.y + cy)
end

function Vertex:__tostring()
    local s = 'vertex'..self.id.. ' ('.. string.format("%.3f", self.x)
                .. ', ' ..
                string.format("%.3f", self.y)..')'
    return s
end
