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
    self.edges = {}
    for i=1, self.res do
        self.edges[i] = {}
        for j=1, self.res do
            self.edges[i][j] = nil
        end
    end

    -- generate a ring of verticies
    for i=1, self.res do
        local e1 = i-1
        local e2 = i+1
        if i == self.res then e2 = 1 end
        if i == 1 then e1 = self.res end

        self.edges[i][e1] = {}
        self.edges[i][e2] = {}

        local phi = i/self.res * math.pi * 2
        local cx = math.cos(phi) * self.radius + self.pos.x
        local cy = math.sin(phi) * self.radius + self.pos.y
        self.verticies[i] = Vertex{x=cx, y=cy,
                                    parent=self,
                                    id = i,
                                    angle = phi
                                }
    end

    -- need all verticies to exist before we connect them all together
    self:initEdges()

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

function Membrane:initEdges()
    for j=1, self.res do
        for i=1, self.res do

            if self.edges[i][j] then
                self:linkEdge(i,j)
            end
        end
    end
end

function Membrane:linkEdge(vi,vj)

    if vi == vj then
        self.edges[vi][vj] = nil
        return
    -- skip already connected edges
    elseif self.edges[vi][vj].isedge then
        return
    end

    -- reoorders the final vertex to make links in appropriate place
    if vj == 1 and vi == self.res then
        vj = self.res
        vi = 1
    end

    local vert1 = self.verticies[vi]
    local vert2 = self.verticies[vj]

    local x1, y1 = vert1.body:getPosition()
    local phi1 = vert1.body:getAngle()
    local x2, y2 = vert2.body:getPosition()
    local phi2 = vert2.body:getAngle()

    -- x,y mean
    local edge = {isedge = true}

    -- vertexes are anchored at centre - w/4
    local w = 2*VERTEX_RADIUS
    local ax1, ay1 = x1 - math.cos(phi1) * w/4, y1 - math.sin(phi1) * w/4
    local ax2, ay2 = x2 + math.cos(phi2) * w/4, y2 + math.sin(phi2) * w/4

    -- connect rectangles centre to centre
    --newDistanceJoint(body1, body2, x1, y1, x2, y2, collideConnected)
    local joint = love.physics.newDistanceJoint(vert1.body, vert2.body,
                                                ax1, ay1, ax2, ay2, false)
    joint:setDampingRatio(.15)
    joint:setFrequency(60)
    joint:setLength(VERTEX_RADIUS/2)

    edge.joint = joint

    -- edges are non directed, so ensure my edge matrix reference this
    -- edge from the perspective of both verticies
    self.edges[vi][vj] = edge
    self.edges[vj][vi] = edge

    -- allow verticies to keep track of their edges
    vert1:addLink(vert2)
    vert2:addLink(vert1)

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

            local pmag = PRESSURE_CONSTANT / math.max(dist, 0.0001)^2

            if this_vertex.linkcount < 2 and other_vertex.linkcount < 2 then
                pmag = - 3*PRESSURE_CONSTANT / math.max(dist, 0.0001)^.8
            else
                pmag = PRESSURE_CONSTANT / math.max(dist, 0.0001)^2
            end

            local force = Vector(xi-xj, yi-yj):normalized() * pmag

            this_vertex.forces[other_vertex] = {force=force, col={1,1,1,1}}

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
                local edge = self.edges[vi][vj]
                if edge.toremove then goto continue end
                self.edges[vi][vj].toremove = true
                self.edges[vj][vi].toremove = true

                vertexj:remLink(vertexi)
            elseif r <= LINK_DIST then
                self:linkEdge(vi,vj)
            end
        end
        ::continue::
    end

    for i, _edges in ipairs(self.edges) do
        for j, edge in ipairs(_edges) do

            if edge.toremove then
                edge.joint:destroy()
                self.edges[i][j] = nil
                self.edges[j][i] = nil
            end
        end
    end
end
