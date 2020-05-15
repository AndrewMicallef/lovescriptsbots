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
    self.edges = {} for i=1, self.res do self.edges[i] = {} end

    -- generate a ring of verticies
    for i=1, self.res do
        local e1 = i-1
        local e2 = i+1
        if i == self.res then e2 = 1 end
        if i == 1 then e1 = self.res end

        self.edges[i][e1] = true
        self.edges[i][e2] = true


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
    -- pressure is negative when area is smaller than internalvol
    local pressure = (self:getArea() - self.internal_vol) * PRESSURE_CONSTANT
    --print(pressure)
    self.pos = Vector(self:getPosition())


    -- surface normal is in the direction opposite the pull of the two springs
    for i, vertex in ipairs(self.verticies) do
        local x0, y0 = vertex.x, vertex.y

        local edges = {}
        local normvec = Vector(0, 0)
        for j, edge in pairs(self.edges[i]) do
            local x1,y1 = self.verticies[j].x, self.verticies[j].y
            normvec = normvec + Vector(x1-x0, y1-y0)
        end
        vertex.norm = normvec
        local pforce = -normvec * pressure / self.res
        vertex.body:applyLinearImpulse(pforce.x, pforce.y)
    end



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
            local r = x0 - x1
            love.graphics.line(x0,y0,x1,y1)
            --love.graphics.circle('line', x0,y0,r)
            ::continue::
        end
    end

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
    joint:setDampingRatio(0)
    joint:setFrequency(1)

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
