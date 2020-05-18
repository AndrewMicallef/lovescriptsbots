Organelle = Class{}


--[[
Can be one of clatherin or actin.
Actin
]]

function Organelle:init(parent)
    self.parent = parent
    self.world = self.parent.world

    self.pos = self.parent.pos + Vector.randomDirection(5, self.parent.radius-5)
    self.state = 'Actin'

    self.isselected = nil
    self.dragging = {active = false, diffX = 0, diffY = 0}

    self.body = love.physics.newBody(self.world, self.pos.x, self.pos.y, 'dynamic')
    self.shape = love.physics.newCircleShape(VERTEX_RADIUS*1.5)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(self)
    self.body:setUserData(self)

end

function Organelle:update(dt)
    --TODO
    self.pos = Vector(self.body:getPosition())

    local x,y = self.pos.x, self.pos.y

    if self.dragging.active and love.mouse.isDown(1) then
        local cx, cy = love.mouse.getPosition( )
        local dx, dy = cx-x, cy-y
        self.body:setPosition(x + dx, y + dy)
    else
        if self.dragging.active then
            self.dragging.active = false end

        --[[
        local fnet = Vector.zero
        for _, f in pairs(self.forces) do
            fnet = fnet + f.force
        end
        self.body:applyLinearImpulse(fnet.x, fnet.y)
        --local dx, dy = fnet.x * dt, fnet.y * dt
        --self.body:setPosition(x + dx, y + dy)
        ]]
    end
end

function Organelle:render()
    local cx, cy = self.pos.x, self.pos.y
    love.graphics.setColor(1,0,0,.5)
    if self.isselected then love.graphics.setColor(1,0,0,1) end
    love.graphics.circle('fill', cx,cy, VERTEX_RADIUS*1.5)
end
