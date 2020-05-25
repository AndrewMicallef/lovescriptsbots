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
    self.shape = love.physics.newCircleShape(10)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(self)
    self.body:setUserData(self)

    --self.statemachine = def.statemachine

end

function Organelle:update(dt)

    -- Get inputs
    --self.statemachine:update()

    if love.keywaspressed['q'] and self.isselected then
        -- Do hook
        self:hook()
    elseif love.keywaspressed['w'] and self.isselected then
        -- Do Break
        self:tear()
    end


    --TODO
    self.pos = Vector(self.body:getPosition())

    local x,y = self.pos.x, self.pos.y

    if self.dragging.active and love.mouse.isDown(1) then
        local cx, cy = love.mouse.getPosition()
        local dx, dy = cx-x, cy-y
        self.body:setPosition(x + dx, y + dy)
    else
        if self.dragging.active then
            self.dragging.active = false end
    end
end

function Organelle:render()
    local cx, cy = self.pos.x, self.pos.y
    love.graphics.setColor(0,1,1,.5)
    if self.isselected then love.graphics.setColor(0,1,1,1) end
    love.graphics.circle('fill', cx,cy, 10)

    if self.joint then
        local x1,y1, x2, y2 = self.joint:getAnchors()
        love.graphics.setColor(1,1,1,1)
        love.graphics.line(x1,y1,x2,y2)
    end
end


--------------------------------------------------------------------------------
-- Actions
--------------------------------------------------------------------------------

function Organelle:hook()

    if self.joint then
        self.joint:destroy()
        self.joint = nil
        self.segment.organelle = nil
        self.segment = nil
        print('detached hook')
        return
    end

    local segments = self.parent.segments

    local min_dist
    local closest_segment

    for _, segment in pairs(segments) do

        local distance = self.pos:dist2(segment.pos)
        if not min_dist or min_dist > distance then
            closest_segment = segment
            min_dist = distance
        end
    end

    if min_dist > 30^2 then
        return
    end

    local anchor = (self.pos + closest_segment.pos) / 2
    self.joint = love.physics.newDistanceJoint( self.body, closest_segment.body,
                                            self.pos.x, self.pos.y,
                                            closest_segment.pos.x,
                                            closest_segment.pos.y,
                                            false)

    self.joint:setLength(20)
    self.segment = closest_segment
    self.segment.organelle = self
    print('hooked segment ' .. closest_segment.id)
end

function Organelle:tear()
    if not self.segment then
        print('I got nothing to cut here man!')
        return
    end

    -- cut the first link that we find
    for other, anchor in pairs(self.segment.anchors) do
        if anchor.joined then
            self.segment:remLink(other)
            --anchor.joined = true
            print('severed link to: ' .. other.id)
            break
        end
    end

end


--------------------------------------------------------------------------------

function Organelle:getInputs()

end
