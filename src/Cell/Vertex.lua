local anchor = {}

function anchor.new()
    local anchor = {
        x, y, filled
    }
    return anchor
end



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

    --TODO add anchor points to vertex.
    -- anchors have a position
    self.anchors = {
            ['L'] = {
                id = nil, joined=nil,
                pos = self.pos, -- (VERTEX_RADIUS / 2),
                side = 'L'
            },
            ['R'] = {
                id = nil, joined=nil,
                pos = self.pos, -- + (VERTEX_RADIUS / 2),
                side = 'R'
            }
        }

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

    local w = 2*VERTEX_RADIUS
    local phi = self.body:getAngle()
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

    self.pos = Vector(self.body:getPosition())
    -- update anchor positions
    -- calc anchor offsets
    local anchor_offset = Vector(math.cos(phi), math.sin(phi)) *w/4
    for _, anchor in pairs(self.anchors) do
        if anchor.side == 'L' then
            anchor.pos = self.pos - anchor_offset
        else
            anchor.pos = self.pos + anchor_offset
        end
    end
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

    local ca = 0
    for _, anchor in pairs(self.anchors) do
        if anchor.joined then ca = ca + 1 end

        love.graphics.setColor(1,0,0,.5)
        if anchor.joined then
            love.graphics.setColor(0,1,0,.5)
        end
        love.graphics.circle('fill', anchor.pos.x, anchor.pos.y, VERTEX_RADIUS/3)
    end

    if self.isselected then
        love.graphics.setColor(1,1,1,1)
        love.graphics.print('links:' .. self.linkcount, 10, 10)
        love.graphics.print('anchored:' .. ca, 10, 20)
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

function Vertex:addLink(other)

    --[[check orientation, make sure we make edges between the two closeset
    -- available anchor points
    --]]

    for _, anchorA in pairs(self.anchors) do
        if anchorA.joined then goto continue_outer end

        for _, anchorB in pairs(other.anchors) do
            if anchorB.joined then goto continue_inner end

            -- re-assaign available anchors
            self.anchors[other] = anchorA
            anchorA.joined = true
            self.anchors[_] = nil

            other.anchors[self] = anchorB
            anchorB.joined = true
            other.anchors[_] = nil

            ::continue_inner::
        end

        ::continue_outer::
    end

    --[[
    local ax1, ay1 = self.anchors[other].pos.x, self.anchors[other].pos.y
    local ax2, ay2 = other.anchors[self].pos.x, other.anchors[self].pos.y

    --newDistanceJoint(body1, body2, x1, y1, x2, y2, collideConnected)
    local joint = love.physics.newDistanceJoint(self.body, other.body,
                                                ax1, ay1, ax2, ay2, false)
    joint:setDampingRatio(.15)
    joint:setFrequency(60)
    joint:setLength(VERTEX_RADIUS/2)

    -- make a reference
    local edge = {
        joint = joint,
        col = {1,1,0,0}
    }

    self.links[other] = edge
    other.links[self] = edge

    self.linkcount = tablelength(self.links)
    other.linkcount = tablelength(other.links)
    ]]
end

function Vertex:remLink(other)
    -- clear anchors -> reset to original key
    local anchorA = self.anchors[other]

    anchorA.joined = false
    self.anchors[anchorA.side] = anchorA
    self.anchors[other] = nil

    local anchorB = other.anchors[self]

    anchorB.joined = false
    other.anchors[anchorB.side] = anchorB
    other.anchors[self] = nil

    -- destroy the joint
    self.links[other].joint:destroy()

    -- clear references to it
    self.links[other] = nil
    other.links[self] = nil

    self.linkcount = tablelength(self.links)
    other.linkcount = tablelength(other.links)
end

function Vertex:__tostring()
    local s = 'vertex'..self.id.. ' ('.. string.format("%.3f", self.pos.x)
                .. ', ' ..
                string.format("%.3f", self.pos.y)..')'
    return s
end
