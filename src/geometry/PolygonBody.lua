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
    self.edges = {}

    --[[
    local points = { [1] = {0,0},
                     [2] = {0.3, 0},
                     [3] = {0.3, 0.2},
                     [4] = {0.2, 0.4},
                     [5] = {0.5, 0.5},
                     [6] = {0.8, 0.4},
                     [7] = {0.7, 0.2},
                     [8] = {0.7, 0},
                     [9] = {1, 0},
                     [10] = {0.5, 1},
                 }

    local edges = { Edge(1,10),
                    Edge(1,2),
                    Edge(2,3),
                    Edge(3,4),
                    Edge(4,5),
                    Edge(5,6),
                    Edge(6,7),
                    Edge(7,8),
                    Edge(8,9),
                    Edge(9,10),
                }

    for i, point in ipairs(points) do
        local x,y = unpack(point)
        self.verticies[i] = Vertex{x=x, y=y,
                                    parent=self,
                                    id = i
                                }
    end

    for i, edge in ipairs(edges) do
        self.edges[edge] = true
    end
    ]]
    --[[ generate a ring of verticies
    for i=1, self.res do
        local e1 = i-1
        local e2 = i+1
        if i == self.res then e2 = 1 end
        if i == 1 then e1 = self.res end

        self.edges[Edge(i, e1)] = true
        self.edges[Edge(i, e2)] = true


        local phi = i/self.res * math.pi * 2
        local cx = math.cos(phi) * self.radius + self.pos.x
        local cy = math.sin(phi) * self.radius + self.pos.y
        self.verticies[i] = Vertex{x=cx, y=cy,
                                    parent=self,
                                    id = i
                                }
    end
    --]]

    -- need all verticies to exist before we connect them all together
    self:initEdges()


--    self.area = {base=polygonArea(self.points)}
--    self.area.current = self.area.base
end

function PolygonBody:edgeflip(edgeAB, edgeCD)
    --[[
    --TODO take an edge, list of connected verticies
    -- and swap one vertex with nearest vertex of the neighbouring edge
    -    A ---- B           A        B
    -               ---->>  |        |
    -                       |        |
    -    C -----D           C        D
    ]]

    local A,B = unpack(edgeAB)
    local C,D = unpack(edgeCD)

    self.edges[edgeAB]:destroy()
    self.edges[edgeAB] = nil
    self.edges[edgeCD]:destroy()
    self.edges[edgeCD] = nil

    local vertA = self.vertices[A]
    local vertB = self.vertices[B]
    local vertC = self.vertices[C]
    local vertD = self.vertices[D]

    local dAC, dBC
    dAC = math.abs(vertA.x - vertC.x) + math.abs(vertA.y - vertC.y)
    dBC = math.abs(vertB.x - vertC.x) + math.abs(vertB.y - vertC.y)

    if dAC < dBC then
        self.edges[Edge(A,C)] = true
        self.edges[Edge(B,D)] = true
    else
        self.edges[Edge(A,D)] = true
        self.edges[Edge(B,C)] = true
    end

end

function PolygonBody:removeEdge(edge)
    if self.edges[edge] then
        self.edges[edge]:destroy()
        self.edges[edge]:release()
        self.edges[edge] = nil
    end
end

function PolygonBody:initEdges()
    for edge, _joint in pairs(self.edges) do
        self:linkEdge(edge)
    end
end

function PolygonBody:linkEdge(edge)

    local vidx1, vidx2 = unpack(edge)
    if vidx1 == vidx2 then
        self.edges[edge] = nil
        return
    end

    local vert1 = self.verticies[vidx1]
    local vert2 = self.verticies[vidx2]

    local x1, y1 = vert1.body:getPosition()
    local x2, y2 = vert2.body:getPosition()
    --newDistanceJoint(body1, body2, x1, y1, x2, y2, collideConnected)
    local joint = love.physics.newDistanceJoint(vert1.body, vert2.body,
                                                x1, y1, x2, y2, true)
    joint:setDampingRatio(0)
    joint:setFrequency(1)

    self.edges[edge] = joint
end


function PolygonBody:update(dt)
    --[[
    local newedges = {}
    local removeedges = {}
    for edge1, _joint in pairs(self.edges) do
        local A, B = unpack(edge1)
        local vA, vB = self.verticies[A], self.verticies[B]
        local dAB = math.abs(vA.x - vB.x) + math.abs(vA.y - vB.y)

        for edge2, _joint in pairs(self.edges) do
            if edge2 == edge1 then goto continue end

            local C, D = unpack(edge2)
            local vC, vD = self.verticies[C], self.verticies[D]
            local dCD = math.abs(vC.x - vD.x) + math.abs(vC.y - vD.y)

            dAC = math.abs(vC.x - vA.x) + math.abs(vC.y - vA.y)
            dAD = math.abs(vD.x - vA.x) + math.abs(vD.y - vA.y)

            dBC = math.abs(vB.x - vC.x) + math.abs(vB.y - vC.y)
            dBD = math.abs(vB.x - vD.x) + math.abs(vB.y - vD.y)

            if dAB > dAC and dAB > dBD then
                newedges[Edge(A,C)] = true
                newedges[Edge(B,D)] = true
                removeedges[Edge(A,B)] = true
                removeedges[Edge(C,D)] = true
            elseif dAB > dAD and dAB > dBC then
                newedges[Edge(A,D)] = true
                newedges[Edge(B,C)] = true
                removeedges[Edge(A,B)] = true
                removeedges[Edge(C,D)] = true
            end
            ::continue::
        end
    end

    for edge, _ in pairs(removeedges) do
        self:removeEdge(edge)
    end

    for edge, _ in pairs(newedges) do
        if not self.edges[edge] then
            self:linkEdge(edge)
        end
    end
    ]]
    for _, vertex in pairs(self.verticies) do
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
    for _, joint in pairs(self.edges) do
        --TODO draw edge
        love.graphics.line(joint:getAnchors())
    end

    for i, vertex in ipairs(self.verticies) do
        vertex:render()
    end
end
