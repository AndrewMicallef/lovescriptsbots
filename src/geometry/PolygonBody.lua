PolygonBody = Class{}

--[[
A PolygonBody is a physical object defined by a collection of vertices,
linked via distance joints
]]
function PolygonBody:init(parent)
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
                                    id = i
                                }
    end

    -- need all verticies to exist before we connect them all together
    self:initEdges()

    self.internal_vol = self:getArea()


--    self.area = {base=polygonArea(self.points)}
--    self.area.current = self.area.base
end


function PolygonBody:update(dt)

    self.pos = Vector(self:getPosition())

    self:calcPressure(PRESSURE_CONSTANT)

    for i, vertex in ipairs(self.verticies) do
        vertex:update(dt)
    end
end

function PolygonBody:render()
    local vcol, ecol = {0,1,1,1}, {1,1,0,1}
    if self.isselected then
        vcol = {1,1,0,1}
        ecol = {1,0,1,1}
    end

    love.graphics.setColor(ecol)
    for j=1, self.res do
        for i=1, self.res do

            local edge = self.edges[i][j]
            if not edge then goto continue end
            --TODO draw edge
            local x0,y0, x1,y1= edge.joint:getAnchors()
            --local r = x0 - x1
            love.graphics.line(x0,y0,x1,y1)
            --love.graphics.circle('line', x0,y0,r)
            ::continue::
        end
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.circle('line', self.pos.x, self.pos.y, 4)
    love.graphics.points(self.pos.x, self.pos.y)

    for i, vertex in ipairs(self.verticies) do
        vertex:render()
    end
end

function PolygonBody:initEdges()
    for j=1, self.res do
        for i=1, self.res do

            if self.edges[i][j] then
                self:linkEdge(i,j)
            end
        end
    end
end

function PolygonBody:linkEdge(vi,vj)

    if vi == vj then
        self.edges[vi][vj] = nil
        return
    -- skip already connected edges
    elseif type(self.edges[vi][vj]) ~= 'boolean' then
        return
    end

    local vert1 = self.verticies[vi]
    local vert2 = self.verticies[vj]

    local x1, y1 = vert1.body:getPosition()
    local x2, y2 = vert2.body:getPosition()

    local edge = {isedge = true}
    --newDistanceJoint(body1, body2, x1, y1, x2, y2, collideConnected)
    local joint = love.physics.newDistanceJoint(vert1.body, vert2.body,
                                                x1, y1, x2, y2, true)
    joint:setDampingRatio(.25)
    joint:setFrequency(2)
    --joint:setLength(30)

    edge.joint = joint

    -- edges are non directed, so ensure my edge matrix reference this
    -- edge from the perspective of both verticies
    self.edges[vi][vj] = edge
    self.edges[vj][vi] = edge
end

---- util ----

-- https://www.mathopenref.com/coordpolygonarea2.html
function PolygonBody:getArea()

    local area = 0 -- Accumulates area
    local verts = self.verticies
    local numpoints = #verts
    local j = numpoints

    for i=1, numpoints do
        local segment_area = (verts[j].x + verts[i].x) * (verts[j].y - verts[i].y)
        area = area + segment_area
        j = i  -- j is previous vertex to i
    end

    return area / 2
end

function PolygonBody:getPosition()
    local cx, cy, N = 0, 0, 0

    for _, vertex in pairs(self.verticies) do
        N = N + 1
        cx = cx + vertex.x
        cy = cy + vertex.y
    end

    local x,y = cx / N, cy / N

    return x,y
end

function PolygonBody:calcPressure(PRESSURE_CONSTANT)

    -- make a global for the specific pwave, this is referenced
    -- inside pressureRayCallback... an inelegant solution methinks
    pwave = {
            hit = nil,
            target = nil,
            fixture = nil,
            fraction = nil
    }

    for i, this_vertex in ipairs(self.verticies) do
        local xi,yi = this_vertex.x, this_vertex.y
        for j, other_vertex in ipairs(self.verticies) do
            if i == j then goto continue end
            local xj,yj = other_vertex.x, other_vertex.y

            pwave.target = other_vertex.fixture
            world:rayCast(xi, yi, xj, yj, pressureRayCallback)

            if pwave.hit then
                -- 1. calcualte the force based on distance
                local dist = math.sqrt((xi-xj)^2 + (yi-yj)^2)
                local pmag = PRESSURE_CONSTANT / math.max(dist, 0.00001)^2
                local force = Vector(xi-xj, yi-yj):normalized() * pmag

                this_vertex.forces['pressure' .. j] = {force=force,
                                                col = {1,1,1,1}}
                pwave = {}
            end
            ::continue::
        end
    end
end

function pressureRayCallback(fixture, x, y, xn, yn, fraction)

    -- select only the first hit in a table of raycast hits
    if pwave.hit then
        if fraction < pwave.fraction then
            pwave.hit = true
            pwave.fraction = fraction
            pwave.fixture = fixture
        end
    else
        pwave.hit = true
        pwave.fraction = fraction
        pwave.fixture = fixture
    end

	return fraction -- Continues with ray cast through all shapes infront of this one.
end
