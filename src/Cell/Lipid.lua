Lipid = Class{}

--[[
A Lipid is a physical object with a body, circleshape, which is connected to
0 or more other verticies via spring joints
-- represents a section of membrane...
]]

BOND_DIST = 2*VERTEX_RADIUS
function Lipid:init(def)
    self.world = def.world
    self.id = def.id --some unique ID
    self.pos = def.pos

    self.islipid = true
    self.valence = 2
    if math.random(0,1) == 0 then
        self.valence = self.valence * -1
    end
    self.bonds = {}

    --TODO add anchor points to Lipid.
    -- anchors have a position
    self.isselected = nil
    self.dragging = {active = false, diffX = 0, diffY = 0}

    self.body = love.physics.newBody(self.world, self.pos.x, self.pos.y, 'dynamic')
    self.shape = love.physics.newCircleShape(VERTEX_RADIUS)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.body:setUserData(self)

    self.forces = {}
end

function Lipid:update(dt)

    self.forces = {}
    
    if self.valence == 0 then goto novalence end
    -- generate forces
    for _, body in pairs(self.world:getBodies()) do
        if body:getUserData()
            and body:getUserData().islipid
            and self.body ~= body
            and not self.bonds[lipid]
            and not body:getUserData().forces[self]
            then
            local lipid = body:getUserData()

            local r = self.pos:dist(lipid.pos)
            local direction = (self.pos - lipid.pos):normalized()
            local force
            local col

            -- force should be proportional to difference in valence (charge)
            -- negative charges should attract positive charges
            -- negative charges should repel negeative charges


            force = CHARGE_CONSTANT * (self.valence * lipid.valence) / math.max(r, VERTEX_RADIUS)^2
            col = {0,1,1,1}


            if r < BOND_DIST
                and ((self.valence < 0 and lipid.valence > 0)
                    or (self.valence > 0 and lipid.valence < 0))
                then
                self:addLink(lipid)
            end

        --[[else
                force = PRESSURE_CONSTANT/50 / math.max(r, 0.0001)^2
                col = {1,1,0,1}
            end
            --]]

            self.forces[lipid] = {force=force*direction, col=col}

        end
    end
    ::novalence::

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
end

function Lipid:render()
    local cx, cy = self.pos.x, self.pos.y
    local fmt = {style='fill', col ={0,1/(1+self.valence),1/ (1+self.valence),1}}

    if self.valence == 0 then
        fmt.col = {0.5, 0.5, 0.5, 1}
    elseif self.valence > 0 then
        fmt.col = {1/1+self.valence,0,0,1}
    else
        fmt.col = {0,0,1/1+math.abs(self.valence),1}
    end

    if self.isselected then
        fmt.col = {1,1,0,1}
    end

    love.graphics.setColor(fmt.col)
    love.graphics.circle(fmt.style, cx, cy, VERTEX_RADIUS)

    if self.isselected then
        local fnet = Vector.zero
        for _, f in pairs(self.forces) do
            local _ = love.graphics.getColor()
            if _ ~= f.col then love.graphics.setColor(f.col) end
            local force = f.force
            force = force / 10
            fnet = fnet + force
            love.graphics.line(cx, cy, (force.x*1e5 + cx),
                                        (force.y*1e5 + cy))
        end

        local lh, lx = 10, 10
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(self.id, lx,lh)
        love.graphics.print('valence: ' .. self.valence, lx,lh*2)

    end

    for _, bond in pairs(self.bonds) do
        love.graphics.setColor(1,1,1,1)
        love.graphics.line(bond:getAnchors())
    end
end

function Lipid:addLink(other)

    if self.bonds[other] or other.bonds[self] then
        return
    end

    local ax1, ay1 = self.body:getPosition()
    local ax2, ay2 = other.body:getPosition()

    local bx, by = ax2 - ax1, ay2 - ay1

    local joint = love.physics.newDistanceJoint(self.body, other.body,
                                                ax1, ay1, ax2, ay2, true)
    joint:setLength(BOND_DIST)
    joint:setFrequency(30)
    joint:setDampingRatio(1)
    --[[

    local bond = {}--= Bond()
    bond.len = VERTEX_RADIUS
    bond.body = love.physics.newBody(self.world, bx, by, 'dynamic')
    bond.shape = love.physics.newRectangleShape(0,0, VERTEX_RADIUS, VERTEX_RADIUS/3)
    bond.fixture = love.physics.newFixture(bond.body, bond.shape)

    bond.joints = {}


    for _, lipid in pairs({self, other}) do
        local lx, ly = lipid.body:getPosition()

        bond.joints[lipid] = joint
    end

    ]]
    self.bonds[other] = joint
    other.bonds[self] = joint

    self.valence = self.valence - 1 * (self.valence/math.abs(self.valence))
    other.valence = other.valence - 1 * (other.valence/math.abs(other.valence))

end

function Lipid:remLink(other)
end

function Lipid:__tostring()
    local s = 'Lipid'..self.id.. ' ('.. string.format("%.3f", self.pos.x)
                .. ', ' ..
                string.format("%.3f", self.pos.y)..')'
    return s
end

function Lipid:type()
    return 'Lipid'
end

function Lipid:typeOf(name)
    return name == self:type()
end
