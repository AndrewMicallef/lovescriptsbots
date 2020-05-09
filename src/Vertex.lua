Vertex = Class{}

--[[
A vertex is a physical object with a body, circleshape, which is connected to
0 or more other verticies via spring joints
]]
function Vertex:init(def)
    self.world = def.world
    self.parent = def.parent
    self.id = def.id --some unique ID
    self.x = def.x
    self.y = def.y
    self.edges = def.edges or {}
    self.edgelist = {}

    self.body = love.physics.newBody(self.world, self.x, self.y, 'dynamic')
    self.shape = love.physics.newCircleShape(VERTEX_RADIUS)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    --joint =
end

function Vertex:setEdges()
    -- verticies is a table of vertex objects
    local sx, sy = self.body:getPosition()
    for i, vid in ipairs(self.edges) do
        if vid == 0 then
            vertex = self.parent.cent_vert
        else
            vertex = self.parent.verticies[vid]
        end

        if self.edgelist[vertex.id] then goto continue end

        local vx, vy = vertex.body:getPosition()
        --newDistanceJoint(body1, body2, x1, y1, x2, y2, collideConnected)
        local joint = love.physics.newDistanceJoint(self.body, vertex.body,
                                              sx, sy, vx, vy, true)

        joint:setDampingRatio(0)
        joint:setFrequency(1)
        if vid == 0 then
            joint:setLength(self.parent.radius-3)
        else
            joint:setLength(40)
        end

        -- TODO replace with vertex.id instead
        -- I think each table will have a unique location in memory
        -- need to test this
        self.edgelist[vertex.id] = joint
        vertex.edgelist[self.id] = joint
        print('connect ' .. self.id .." to "..vid)
        ::continue::
    end
end

function Vertex:update(dt)
    self.x, self.y = self.body:getPosition()
end

function Vertex:render()
    love.graphics.setColor(0,1,1,1)
    local cx, cy = self.body:getPosition()
    love.graphics.circle("line", cx, cy, VERTEX_RADIUS)

    love.graphics.setColor(1,1,0,1)
    for _, joint in pairs(self.edgelist) do
        --TODO draw edge
        love.graphics.line(joint:getAnchors())
    end
end


function Vertex:__tostring()
    local s = 'vertex'..self.id.. ' ('.. string.format("%.3f", self.x)
                .. ', ' ..
                string.format("%.3f", self.y)..')'
    return s
end
