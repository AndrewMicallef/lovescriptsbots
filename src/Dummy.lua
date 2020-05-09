Dummy = Class{}

function Dummy:init(def)
    self.world = def.world --maintain reference to the world

    -- position in the world
    self.pos = def.pos or Vector.new(math.random(0, WIDTH), math.random(0, HEIGHT))
    self.angle = def.angle or math.random() * 2 * math.pi

    self.res = def.res or 8
    self.radius = 90
    self.verticies = {}
    -- note that I am using position 0 as the root vertex...
    self.cent_vert = Vertex{x=self.pos.x, y=self.pos.y,
                                world=self.world, parent=self,
                                id=0}
    --print(self.verticies[0])
    -- place polygon verticies
    for i=1, self.res do
        local l1 = i-1
        local l2 = i+1
        if i == self.res then l2 = 1 end
        if i == 1 then l1 = self.res end

        local phi = i/self.res * math.pi * 2
        local cx = math.cos(phi) * self.radius + self.pos.x
        local cy = math.sin(phi) * self.radius  + self.pos.y
        self.verticies[i] = Vertex{x=cx, y=cy,
                                    world=self.world,
                                    parent=self,
                                    id = i,
                                    edges={0, l1, l2}
                                }
        print(self.verticies[i])
    end

    -- need all verticies to exist before we connect them all together
    self:JoinVerticies()


--    self.area = {base=polygonArea(self.points)}
--    self.area.current = self.area.base

    -- collection of the traits that are able to be mutated
--    self.mutable_traits = {}
end

function Dummy:update(dt)

    for i, vertex in ipairs(self.verticies) do
        vertex:update(dt)
    end
end

function Dummy:render()

    -- light pink, I think
    love.graphics.setColor(.3,0,5, 3)
    love.graphics.polygon('fill', unpack(self:getPoints()))

    for i, vertex in ipairs(self.verticies) do
        vertex:render()
    end
end
--------------------------------------------------------------------------------

function Dummy:JoinVerticies()
    for i, vertex in ipairs(self.verticies) do
        vertex:setEdges()
    end
end
--------------------------------------------------------------------------------

function Dummy:getPoints()
    local points = {}
    for i, vertex in ipairs(self.verticies) do
        local iy = 2*i
        local ix = iy - 1
        --[[ i   2i   2i-1
            1   2     1
            2   4     3
            3   6     5
        ]]
        points[ix] = vertex.x
        points[iy] = vertex.y
    end
    return points
end

--------------------------------------------------------------------------------
function Dummy:type()
    return 'Dummy'
end

function Dummy:typeOf(name)
    return name == self:type()
end
