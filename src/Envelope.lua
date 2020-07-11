Envelope = Class{}
ControlPoint = Class{}

function Envelope:init(verts)
    self.controls = {}

    for i=1, #verts, 2 do
        local x,y = verts[i], verts[i+1]
        table.insert(self.controls, ControlPoint(x,y))
    end

    self.curve = love.math.newBezierCurve(unpack(verts))
    self.verts = verts
end

function Envelope:update(dt)

    for i, cp in ipairs(self.controls) do
        cp:update(dt)

        if cp.dirty then

            self.curve:setControlPoint(i, cp.x, cp.y)
            cp.dirty = false
        end
    end
end

function Envelope:render()

    love.graphics.setColor(1,.5, 0, 1)
    love.graphics.line(self.curve:render())

    love.graphics.setColor(1,1, 0, 1)
    local verts = {}
    for i, cp in ipairs(self.controls) do
        table.insert(verts, cp.x)
        table.insert(verts, cp.y)
    end
    love.graphics.line(verts)

    for i, cp in ipairs(self.controls) do
        cp:render()
    end
end

function Envelope:asArray(resolution)

    --local points = self.curve:render()
    local array = {}
    local min, max
    for i=1, resolution do
        local x, y = self.curve:evaluate(i/resolution)
        array[i] = 1/y
        if not max then
            max = array[i]
        elseif math.abs(array[i]) > max then
            max = array[i]
        end
        if not min then
            min = array[i]
        elseif math.abs(array[i]) < min then
            min = array[i]
        end
    end

    local range = max - min
    for i, v in ipairs(array) do
        v = (v - min) / range
        array[i] = v
    end

    return array
end

function ControlPoint:init(x,y)
    self.x = x
    self.y = y

    self.r = 10
    self.selected = false
    self.dirty = false
end


function ControlPoint:update(dt)

    if love.mousewaspressed.button==1 then
        local cx, cy = love.mousewaspressed.x, love.mousewaspressed.y
        local x, y = self.x, self.y
        local cr = ((cx - x)^2 + (cy - y)^2)^0.5


        if not self.selected and cr <= self.r then
            self.selected = true
        elseif self.selected and cr >= self.r then
            self.selected = false
        end
    end

    if not self.selected then
        return
    end

    if love.mouse.isDown(1) then
        -- update x,y to cx, cy
        local cx, cy = love.mouse.getPosition()
        self.x, self.y = cx, cy
        self.dirty = true
    end
end

function ControlPoint:render()
    local color = {.5,.5, 0, 1}
    if self.selected then
        color = {0, .5, 1, 1}
    end

    love.graphics.setColor(color)
    love.graphics.circle('fill', self.x, self.y, self.r)

end
