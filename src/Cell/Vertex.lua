Vertex = Class{}

--[[
A vertex is a physical object with a body, circleshape, which is connected to
0 or more other verticies via spring joints
-- represents a section of membrane...
]]
function Vertex:init(def)
    self.parent = def.parent
    self.world = self.parent.world
    self.id = def.id --some unique ID
    self.pos = Vector(def.x, def.y)
    self.angle = def.angle or 0

    -- maintain a list of connections
    -- and a count of number of connections
    self.links = {}
    self.linkcount = 0

    self.isselected = nil
    self.dragging = {active = false, diffX = 0, diffY = 0}

    self.body = love.physics.newBody(self.world, self.pos.x, self.pos.y, def.type or 'dynamic')
    self.shape = love.physics.newRectangleShape(0, 0, 2*VERTEX_RADIUS, VERTEX_RADIUS)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.body:setUserData(self)
    self.body:setAngle(self.angle+math.pi/2)

    self.forces = {}
    self.norm = Vector(0,0)
end

function Vertex:update(dt)

    --TODO consolidate forces
    local x,y = self.pos.x, self.pos.y

    if self.dragging.active and love.mouse.isDown(1) then
        local cx, cy = love.mouse.getPosition( )
        local dx, dy = cx-x, cy-y
        self.body:setPosition(x + dx, y + dy)
    else
        if self.dragging.active then
            self.dragging.active = false end

        -- iterate through consolidated forces and aggregate into net force vector
        local fnet = Vector.zero
        for _, f in pairs(self.forces) do
            fnet = fnet + f.force
        end
        self.body:applyLinearImpulse(fnet.x, fnet.y)
    end

    self.pos.x, self.pos.y = self.body:getPosition()
end

function Vertex:render()
    local fmt = {style='fill', col ={0,1,1,1}}
    if self.isselected then
        fmt.col = {1,1,0,1}
    end
    if self.linkcount < 2 then
        fmt.style = 'line'
    end
    love.graphics.setColor(fmt.col)
    love.graphics.polygon(fmt.style, self.body:getWorldPoints(self.shape:getPoints()))
    if self.isselected then
        love.graphics.print(self.linkcount, WIDTH/2, HEIGHT/2)
    end
    --love.graphics.line(cx, cy, self.norm.x + cx, self.norm.y + cy)
    --[[DEBUG for drawing forces
    if self.isselected then
        local fnet = Vector.zero
        local cx, cy = self.body:getPosition()
        for _, f in pairs(self.forces) do
            local _ = love.graphics.getColor()
            if _ ~= f.col then love.graphics.setColor(f.col) end
            local force = f.force
            force = force / 10
            fnet = fnet + force
            love.graphics.line(cx, cy, (force.x*1e5 + cx),
                                        (force.y*1e5 + cy))
        end
        love.graphics.setColor(1,0,0,1)
        love.graphics.line(cx, cy, fnet.x + cx, fnet.y + cy)
    end
    --]]
end

function Vertex:__tostring()
    local s = 'vertex'..self.id.. ' ('.. string.format("%.3f", self.pos.x)
                .. ', ' ..
                string.format("%.3f", self.pos.y)..')'
    return s
end

function Vertex:addLink(other)
    self.links[other.id] = other
    self.linkcount = tablelength(self.links)
end

function Vertex:remLink(other)
    self.links[other.id] = nil
    self.linkcount = tablelength(self.links)
end
