MembraneSegment = Class{}

--[[
Represents a section of membrane with the ability to link to other membrane segments
]]
function MembraneSegment:init(def)
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
                pos = Vector.zero, -- (VERTEX_RADIUS / 2),
                side = 'L'
            },
            ['R'] = {
                id = nil, joined=nil,
                pos = Vector.zero, -- + (VERTEX_RADIUS / 2),
                side = 'R'
            }
        }

    self.isselected = nil
    self.dragging = {active = false, diffX = 0, diffY = 0}

    -- segment physical presence
    self.body = love.physics.newBody(self.world, self.pos.x, self.pos.y, def.type or 'dynamic')
    self.shape = love.physics.newRectangleShape(0, 0, SEGMENT_W, SEGMENT_H)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.body:setUserData(self)
    self.body:setAngle(self.angle+math.pi/2)

    self.forces = {}
    self.norm = Vector(0,0)
end

function MembraneSegment:update(dt)

    local w = SEGMENT_W
    local phi = self.body:getAngle()
    --TODO consolidate forces
    local x,y = self.pos.x, self.pos.y

    if self.dragging.active and love.mouse.isDown(1) then
        local cx, cy = love.mouse.getPosition( )
        local dx, dy = cx-x, cy-y
        self.body:setPosition(x + dx, y + dy)
        self.pos = Vector(self.body:getPosition())
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
        if anchor.side == 'R' then
            anchor.pos = self.pos + anchor_offset
        else
            anchor.pos = self.pos - anchor_offset
        end
    end
end

function MembraneSegment:render()
    local fmt = {style='fill', col ={0,1,1,.3}}
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
        love.graphics.circle('fill', anchor.pos.x, anchor.pos.y, SEGMENT_H)
    end

    if self.isselected then
        love.graphics.setColor(0,0,0,.8)
        love.graphics.rectangle('fill', 0, 0, 100, 50)
        love.graphics.setColor(1,1,1,1)
        love.graphics.print('id:' .. self.id, 10, 10)
        love.graphics.print('anchored:' .. ca, 10, 20)
        local _h = 0
        for _, anchor in pairs(self.anchors) do
            love.graphics.print('    ' .. anchor.side .. ': ', 10, 30 + _h)
            if anchor.id then
                love.graphics.print(anchor.id, 40, 30 + _h)
            end
            _h = _h + 10
        end
    end
end

function MembraneSegment:addLink(other)

    --[[check orientation, make sure we make edges between the two closeset
    -- available anchor points
    --]]
    if self.anchors[other] then
        return
    end

    if self.organelle or other.organelle then
        return
    end

    local anc_pair -- pair of anchors
    local min_d  -- the minimum distance between anchors

    --[[ I need to connect the first available anchor in self with the first
    available anchor in other. I can forget about minimising distance for the moment
    --]]

    for _, anc_s in pairs(self.anchors) do
        if anc_s.joined then goto cont1 end

        for _, anc_o in pairs(other.anchors) do
            if anc_o.joined then goto cont2 end

            local d = anc_s.pos:dist(anc_o.pos)
            if not min_d or d < min_d then
                min_d = d
                anc_pair = {anc_s.side, anc_o.side}
            end
            ::cont2::
        end
        ::cont1::
    end

    if not anc_pair then
        return
    end

    for _, v in pairs(anc_pair) do
        if not v then
            return
        end
    end

    local selfside, otherside = unpack(anc_pair)

    -- re-assaign available anchors
    self.anchors[other] = self.anchors[selfside]
    self.anchors[other].joined = true
    self.anchors[other].id = other.id
    self.anchors[selfside] = nil

    other.anchors[self] = other.anchors[otherside]
    other.anchors[self].joined = true
    other.anchors[self].id = self.id
    other.anchors[otherside] = nil

    ----[[
    local ax1, ay1 = self.anchors[other].pos.x, self.anchors[other].pos.y
    local ax2, ay2 = other.anchors[self].pos.x, other.anchors[self].pos.y

    --newDistanceJoint(body1, body2, x1, y1, x2, y2, collideConnected)
    local joint = love.physics.newDistanceJoint(self.body, other.body,
                                                ax1, ay1, ax2, ay2, false)
    joint:setDampingRatio(.5)
    joint:setFrequency(60)
    joint:setLength(SEGMENT_H)

    -- make a reference
    local edge = {
        joint = joint,
        col = {1,1,0,0}
    }

    self.links[other] = edge
    other.links[self] = edge

    self.linkcount = self.linkcount + 1
    other.linkcount = other.linkcount + 1

    --]]
end

function MembraneSegment:remLink(other)
    -- clear anchors -> reset to original key
    local anchorA = self.anchors[other]
    anchorA.joined = false
    anchorA.id = nil
    self.anchors[anchorA.side] = anchorA
    self.anchors[other] = nil

    local anchorB = other.anchors[self]
    anchorB.joined = false
    anchorB.id = nil
    other.anchors[anchorB.side] = anchorB
    other.anchors[self] = nil

    -- destroy the joint
    self.links[other].joint:destroy()

    -- clear references to it
    self.links[other] = nil
    other.links[self] = nil

    self.linkcount = self.linkcount - 1
    other.linkcount = other.linkcount - 1
end

function MembraneSegment:__tostring()
    local s = 'vertex'..self.id.. ' ('.. string.format("%.3f", self.pos.x)
                .. ', ' ..
                string.format("%.3f", self.pos.y)..')'
    return s
end
