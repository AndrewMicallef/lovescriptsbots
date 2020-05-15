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

    ----[[
    local points = { [1] = {0,0},
                     [2] = {0.45, 0},
                     [3] = {0.45, 0.2},
                     [4] = {0.2, 0.3},
                     [5] = {0.5, 0.5},
                     [6] = {0.8, 0.3},
                     [7] = {0.55, 0.2},
                     [8] = {0.55, 0},
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
        x = (x-.5)*230 + self.pos.x
        y = (y-.5)*230 + self.pos.y
        self.verticies[i] = Vertex{x=x, y=y,
                                    parent=self,
                                    id = i
                                }
    end

    for i, edge in ipairs(edges) do
        self.edges[edge] = true
    end
    --]]
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

    local newedges = {}
    local removeedges = {}

    -- distance between unconnected verticies is less than threshold
    -- calulate the convex hull and redistribute verts to it's perimeter!
    -- AND

    for edge1, _joint1 in pairs(self.edges) do
        local A, B = unpack(edge1)
        local vA, vB = self.verticies[A], self.verticies[B]
        local dAB = ((vA.x - vB.x)^2 + (vA.y - vB.y)^2)^0.5

        for edge2, _joint2 in pairs(self.edges) do

            local C, D = unpack(edge2)
            if A == C or A == D or B == C or B == D then goto continue end

            local vC, vD = self.verticies[C], self.verticies[D]
            local dCD = ((vC.x - vD.x)^2 + (vC.y - vD.y)^2)^0.5

            dAC = ((vC.x - vA.x)^2 + (vC.y - vA.y)^2)^0.5
            dAD = ((vD.x - vA.x)^2 + (vD.y - vA.y)^2)^0.5
            dBC = ((vB.x - vC.x)^2 + (vB.y - vC.y)^2)^0.5
            dBD = ((vB.x - vD.x)^2 + (vB.y - vD.y)^2)^0.5

            if math.abs(dAD - dBC) < 10 then
                edge1.col = {1,0,1,1}
                edge2.col = {1,0,1,1}
            else
                edge1.col = nil
                edge2.col = nil
            end



            --[[
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
            --]]
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
    --]]
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
        if _.col then
            love.graphics.setColor(_.col)
        else
            love.graphics.setColor(ecol)
        end
        love.graphics.line(joint:getAnchors())
    end

    for i, vertex in ipairs(self.verticies) do
        vertex:render()
    end
end


function ccw(a,b,c)
    return (b.x - a.x) * (c.y - a.y) > (b.y - a.y) * (c.x - a.x)
end

function pop_back(ta)
    table.remove(ta,#ta)
    return ta
end

function convexHull(pl)
    --pl is assumed to be a table of points with x and y fields
    if #pl == 0 then
        return {}
    end
    table.sort(pl, function(left,right)
        return left.x < right.x
    end)

    local h = {}

    -- lower hull
    for i,pt in pairs(pl) do
        while #h >= 2 and not ccw(h[#h-1], h[#h], pt) do
            table.remove(h,#h)
        end
        table.insert(h,pt)
    end

    -- upper hull
    local t = #h + 1
    for i=#pl, 1, -1 do
        local pt = pl[i]
        while #h >= t and not ccw(h[#h-1], h[#h], pt) do
            table.remove(h,#h)
        end
        table.insert(h,pt)
    end

    table.remove(h,#h)
    return h
end
