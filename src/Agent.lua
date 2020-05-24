Agent = Class{}

function Agent:init(def)
    self.world = def.world --maintain reference to the world

    -- position in the world
    self.pos = def.pos or Vector.new(math.random(0, WIDTH), math.random(0, HEIGHT))
    self.angle = def.angle or math.random() * 2 * math.pi

    self.health = def.health or math.random() * HEALTHMAX

    self.col = {red = math.random() or def.parent.col.red,
                gre = math.random() or def.parent.col.gre,
                blu = math.random() or def.parent.col.blu
                }

    self.radius = 8
    self.points = {}
    local points = {}
    for i=1, 16, 2 do
        points[i] = math.cos(i/16 * math.pi * 2) * self.radius + self.pos.x
        points[i+1] = math.sin(i/16 * math.pi * 2) * self.radius + self.pos.y
        self.points[#self.points +1] = {x=points[i], y=points[i+1], dx=0, dy=0}
    end

    self.area = {base=polygonArea(self.points)}
    self.area.current = self.area.base

    local sensors = {"health",
                    "col.red", "col.gre", "col.blu",
                    "velx", "vely",
                    "mousex", "mousey", 'dmouse'
                    }
    local actuators = {"col.red", "col.gre", "col.blu"}

    for i=1, #self.points do
        sensors[#sensors + 1] = 'p'..i..'x'
        sensors[#sensors + 1] = 'p'..i..'y'
        sensors[#sensors + 1] = 'p'..i..'dy'
        sensors[#sensors + 1] = 'p'..i..'dx'

        actuators[#actuators + 1] = 'p'..i..'dx'
        actuators[#actuators + 1] = 'p'..i..'dy'
    end


    self.sensors = Ntable(sensors)
    self.actuators = Ntable(actuators)

    self.brain = Brain{sensors=self.sensors, actuators=self.actuators}

    -- collection of the traits that are able to be mutated
    self.mutable_traits = {}

end

function Agent:update(dt)

    if self.isdead then
        if not self.body:isDestroyed() then
            self.body:destroy()
        end
        return
    end

    -- metabolise
    self:metabolise(dt)

    -- sense
    self:sense()

    -- think
    self:think()

    -- act
    self:act(dt)
end

function Agent:render()

    love.graphics.setColor(self.col.red, self.col.gre, self.col.blu, 1)

    love.graphics.polygon('fill', unpack(self:getPoints()))

end

function Agent:metabolise(dt)

--TODO overtime health declines
--TODO eating food adds to health
--TODO reproducing costs health
end

function Agent:sense()
    -- read out all sensor values
    self.sensors['health'] = cappedvalue(self.health / HEALTHMAX)

    --local vx, vy = self.body:getLinearVelocity()
    --self.sensors['vx'] = vx
    --self.sensors['vy'] = vy
    --self.sensors['angle'] = self.body:getAngle() / 2*math.pi

    self.sensors['col.red'] = self.col.red
    self.sensors['col.gre'] = self.col.gre
    self.sensors['col.blu'] = self.col.blu

    --local mx, my = love.mouse.getPosition()
    --self.sensors["mx"] = mx
    --self.sensors["my"] = my

    --local px, py = self.body:getPosition()
    --self.sensors['dm'] = math.sqrt((mx - px)^2 + (my-py)^2)

    for i=1, #self.points do
        self.sensors['p'..i..'x'] = self.points[i].x
        self.sensors['p'..i..'y'] = self.points[i].y
        self.sensors['p'..i..'dx'] = self.points[i].dx
        self.sensors['p'..i..'dy'] = self.points[i].dy
    end
end

function Agent:think()
    -- brain needs to actuate some properties of the agent
    self.brain:update(self.sensors, self.actuators)
end

function Agent:act(dt)
    -- run all actuators
    self.col.red = self.actuators['col.red']
    self.col.gre = self.actuators['col.gre']
    self.col.blu = self.actuators['col.blu']

    local dxnet, dynet = 0,0
    local px, py = self.pos.x, self.pos.y
    for i=1, #self.points do
        local point = self.points[i]

        point.dx = self.actuators['p'..i..'dx'] * dt
        point.dy = self.actuators['p'..i..'dy'] * dt

        dxnet = dxnet + point.dx
        dynet = dynet + point.dy

        -- each vertex is pulled towards the centre by a force proportional to the current area
        local k = (self.area.current - self.area.base) / self.area.base
        local rc = math.sqrt((point.x-px)^2 + (point.y-py)^2)
        local F_magelastic = k * (self.radius - rc)
        local phi = math.atan2(point.x - px, point.y - py) -- angle from point to centre
        local F_elas = {x = math.cos(phi) * F_magelastic * dt,
                        y = math.sin(phi) * F_magelastic * dt,
                        }

        --push each vertex
        point.x = point.x + point.dx + F_elas.x
        point.y = point.y + point.dy + F_elas.y

    end
    self.pos.x = px + dxnet
    self.pos.y = py + dynet
end

function Agent:reproduce()
end

function Agent:mutate()
end


function Agent:type()
    return 'Agent'
end

function Agent:typeOf(name)
    return name == self:type()
end

function Agent:getPoints()
    local points = {}
    for i=1, #self.points do
        points[#points + 1] = self.points[i].x
        points[#points + 1] = self.points[i].y
    end
    return points
end
