Membrane = Class{}

--[[
A Membrane is a physical object defined by a collection of vertices,
linked via distance joints
]]

MAX_DIST = VERTEX_RADIUS*2
LINK_DIST = VERTEX_RADIUS
function Membrane:init(parent)
    self.parent = parent
    self.pos = parent.pos
    self.world = parent.world

    self.res = parent.res
    self.radius = parent.radius

    self.verticies = {}

    -- generate a ring of verticies
    for i=1, self.res do

        local phi = i/self.res * math.pi * 2
        local cx = math.cos(phi) * self.radius + self.pos.x
        local cy = math.sin(phi) * self.radius + self.pos.y
        self.verticies[i] = Vertex{x=cx, y=cy,
                                    parent=self,
                                    id = i,
                                    angle = phi
                                }
    end

    self.internal_vol = self:getArea()
end

function Membrane:update(dt)

    self.pos = Vector(self:getPosition())

    self:calcPressure(PRESSURE_CONSTANT)

    for i, vertex in ipairs(self.verticies) do
        vertex:update(dt)
    end

    --check to see if any joints have exceeded max length..
    self:checkMembrane()
end

function Membrane:render()

    love.graphics.setColor(1,1,1,1)
    love.graphics.circle('line', self.pos.x, self.pos.y, 4)
    love.graphics.points(self.pos.x, self.pos.y)

    for i, vertex in ipairs(self.verticies) do
        vertex:render()
    end
end
---- util ----

-- https://www.mathopenref.com/coordpolygonarea2.html
function Membrane:getArea()

    local area = 0 -- Accumulates area
    local verts = self.verticies
    local numpoints = #verts
    local j = numpoints

    for i=1, numpoints do
        local segment_area = (verts[j].pos.x + verts[i].pos.x) * (verts[j].pos.y - verts[i].pos.y)
        area = area + segment_area
        j = i  -- j is previous vertex to i
    end

    return area / 2
end

function Membrane:getPosition()
    local cx, cy, N = 0, 0, 0

    for _, vertex in pairs(self.verticies) do
        N = N + 1
        cx = cx + vertex.pos.x
        cy = cy + vertex.pos.y
    end

    local x,y = cx / N, cy / N

    return x,y
end

function Membrane:calcPressure(PRESSURE_CONSTANT)

    -- fully linked vertices repel other verticies
    -- unlinked vertices are attracted to unlinked vertices
    for i, this_vertex in ipairs(self.verticies) do

        local xi,yi = this_vertex.pos.x, this_vertex.pos.y

        for j, other_vertex in ipairs(self.verticies) do
            if i == j then goto continue end

            local xj,yj = other_vertex.pos.x, other_vertex.pos.y

            -- 1. calcualte the force based on distance
            local dist = math.sqrt((xi-xj)^2 + (yi-yj)^2)

            local pmag
            local col = {}

            if this_vertex.linkcount < 2  and other_vertex.linkcount < 2 then
                pmag = -2*PRESSURE_CONSTANT / math.max(dist, 0.0001)
                col = {1,.5,.5,1}
            else
                pmag = PRESSURE_CONSTANT / math.max(dist, 0.0001)^2
                col = {.5,.5,1,1}
            end

            local force = Vector(xi-xj, yi-yj):normalized() * pmag

            this_vertex.forces[other_vertex] = {force=force, col=col}

            ::continue::
        end
    end
end

function Membrane:checkMembrane()

    -- 1. check if the edges have over extended
    for vi, vertexi in ipairs(self.verticies) do

        local xi, yi = vertexi.body:getPosition()
        for vj, vertexj in ipairs(self.verticies) do
            if vi == vj then goto continue end

            local vertexj = self.verticies[vj]
            local xj, yj = vertexj.body:getPosition()

            local r = math.sqrt((xi-xj)^2 + (yi-yj)^2)

            if vertexi.links[vj] and r >= MAX_DIST then
                -- severe this link

                vertexj:remLink(vertexi)
            elseif r <= LINK_DIST * 2 then
                vertexi:addLink(vertexj)
            end
        end
        ::continue::
    end
end
