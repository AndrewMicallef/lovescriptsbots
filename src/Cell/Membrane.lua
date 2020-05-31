Membrane = Class{}

--[[
A Membrane is a physical object defined by a collection of vertices,
linked via distance joints
]]

MAX_DIST = SEGMENT_W*4
LINK_DIST = SEGMENT_W*2
function Membrane:init(parent)
    self.parent = parent
    self.pos = parent.pos
    self.world = parent.world

    self.res = parent.res
    self.radius = parent.radius

    self.segments = {}

    -- generate a ring of segments
    for i=1, self.res do

        local phi = i/self.res * math.pi * 2
        local cx = math.cos(phi) * self.radius + self.pos.x
        local cy = math.sin(phi) * self.radius + self.pos.y
        self.segments[i] = MembraneSegment{x=cx, y=cy,
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

    for i, segment in ipairs(self.segments) do
        segment:update(dt)
    end

    --check to see if any joints have exceeded max length..
    self:checkMembrane()
end

function Membrane:render()

    love.graphics.setColor(1,1,1,1)
    love.graphics.circle('line', self.pos.x, self.pos.y, 4)
    love.graphics.points(self.pos.x, self.pos.y)

    for i, segment in ipairs(self.segments) do
        segment:render()
    end
end
---- util ----

-- https://www.mathopenref.com/coordpolygonarea2.html
function Membrane:getArea()

    local area = 0 -- Accumulates area
    local verts = self.segments
    local numpoints = #verts
    local j = numpoints

    for i=1, numpoints do
        local segment_area = (verts[j].pos.x + verts[i].pos.x) * (verts[j].pos.y - verts[i].pos.y)
        area = area + segment_area
        j = i  -- j is previous segment to i
    end

    return area / 2
end

function Membrane:getPosition()
    local cx, cy, N = 0, 0, 0

    for _, segment in pairs(self.segments) do
        N = N + 1
        cx = cx + segment.pos.x
        cy = cy + segment.pos.y
    end

    local x,y = cx / N, cy / N

    return x,y
end

function Membrane:calcPressure(PRESSURE_CONSTANT)

    -- fully linked vertices repel other segments
    -- unlinked vertices are attracted to unlinked vertices
    for i, this_segment in ipairs(self.segments) do

        local xi,yi = this_segment.pos.x, this_segment.pos.y

        for j, other_segment in ipairs(self.segments) do
            if i == j then goto continue end

            local xj,yj = other_segment.pos.x, other_segment.pos.y

            -- 1. calcualte the force based on distance
            local dist = (xi-xj)^2 + (yi-yj)^2

            local pmag
            local col = {}

            if this_segment.linkcount < 2 and other_segment.linkcount < 2 then
                pmag = -PRESSURE_CONSTANT / math.max(dist, 0.0001)
                col = {1,.5,.5,1}
            else
                pmag = PRESSURE_CONSTANT / math.max(dist, SEGMENT_H)^.5
                col = {.5,.5,1,1}
            end

            local force = Vector(xi-xj, yi-yj):normalized() * pmag

            this_segment.forces[other_segment] = {force=force, col=col}

            ::continue::
        end
    end
end

function Membrane:checkMembrane()

    -- 1. check if the edges have over extended
    for vi, segmenti in ipairs(self.segments) do

        local xi, yi = segmenti.body:getPosition()
        for vj, segmentj in ipairs(self.segments) do
            if vi == vj then goto continue end

            local segmentj = self.segments[vj]
            local xj, yj = segmentj.body:getPosition()

            local r = math.sqrt((xi-xj)^2 + (yi-yj)^2)

            if segmenti.links[segmentj] and r >= MAX_DIST then
                -- severe this link

                segmentj:remLink(segmenti)
            elseif r <= LINK_DIST and not segmenti.links[segmentj] then
                segmenti:addLink(segmentj)
            end
        end
        ::continue::
    end
end
