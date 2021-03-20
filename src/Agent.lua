Agent = Class{}

function Agent:init(def)
    self.world = def.world --maintain reference to the world

    self.id=0

    self.pos = def.pos or Vector.new(math.random(0, WIDTH), math.random(0, HEIGHT))
    self.angle = def.angle or math.random() * 2 * math.pi

    self.energy = 20
    self.health = def.health or math.random() * HEALTHMAX
    self.isdead = false
    self.birth = love.timer.getTime()
    self.gencount = 0 or def.parent.gencount + 1

    self.f_angle = 0
    self.f_thrust = 0

    self.col = {red = math.random() or def.parent.col.red,
                gre = math.random() or def.parent.col.gre,
                blu = math.random() or def.parent.col.blu
                }

    self.radius = 8

    -- physical presence
    self.body = love.physics.newBody(self.world, self.pos.x, self.pos.y, 'dynamic')
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(self)
    self.body:setUserData(self)

    self.sensors = Ntable{"energy",
                           "health",
                           "angle",
                           "flagella.angle",
                           "flagella.thrust",
                           "col.red", "col.gre", "col.blu",
                           "vx", "vy",
                           "mx", "my", 'dm',
                           'dragging'
                         }

    self.actuators = Ntable{
                        "flagella.angle",
                        "flagella.thrust",
                        "col.red", "col.gre", "col.blu",
                        }

    self.brain = Brain{sensors=self.sensors, actuators=self.actuators}

    -- collection of the traits that are able to be mutated
    self.mutable_traits = {}

    self.isselected = nil
    self.dragging = nil


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

    local cx, cy = self.pos.x, self.pos.y
    if self.isdead then
        love.graphics.circle('line', cx, cy, self.shape:getRadius())
    else
        love.graphics.circle('fill', cx, cy, self.shape:getRadius())
    end

end

function Agent:metabolise(dt)

    --TODO overtime health declines
    --TODO eating food adds to health
    --TODO reproducing costs health

    --self.health = self.health - dt * 0.1

    if self.health < 0 then
        self.isdead = true
    end

    if self.isdead then
        self.energy = self.energy - dt * 0.1
    end
end

function Agent:sense()
    -- read out all sensor values
    self.sensors['health'] = cappedvalue(self.health / HEALTHMAX)
    self.sensors['energy'] = cappedvalue(self.energy / HEALTHMAX)

    local vx, vy = self.body:getLinearVelocity()
    self.sensors['vx'] = vx
    self.sensors['vy'] = vy
    self.sensors['angle'] = self.body:getAngle() / 2*math.pi

    self.sensors['col.red'] = self.col.red
    self.sensors['col.gre'] = self.col.gre
    self.sensors['col.blu'] = self.col.blu


    local px, py = self.body:getPosition()

    self.pos.x, self.pos.y = px, py

    if self.dragging then
        local mx, my = love.mouse.getPosition()
        self.dx, self.dy = mx - px, my - py
        self.sensors['dragging'] = 1
        self.sensors["dx"] = self.dx
        self.sensors["dy"] = self.dy
    else
        self.sensors['dragging'] = 0
        self.sensors["dx"] = 0
        self.sensors["dy"] = 0
        self.dx, self.dy = 0, 0
    end

    self.sensors['flagella.angle'] = self.f_angle
    self.sensors['flagella.thrust'] = self.f_thrust

end

function Agent:think()

    -- brain needs to actuate some properties of the agent
    self.brain:update(self.sensors, self.actuators)
end

function Agent:act(dt)

    local Fnet
    -- run all actuators
    if self.dragging then
        Fnet = Vector(self.dx, self.dy)
        local mag = Fnet:len()
        if mag > MAX_THRUST then
            local unitvec = Fnet:normalized()
            Fnet = unitvec * MAX_THRUST
            mag = MAX_THRUST
        end
        self.f_angle = Fnet:angleTo()
        self.f_thrust = mag
    else
        self.f_angle = self.actuators['flagella.angle'] * math.pi * 2
        self.f_thrust = self.actuators['flagella.thrust'] * MAX_THRUST
        Fnet = Vector.fromPolar(self.f_angle, self.f_thrust)
    end

    self.body:applyLinearImpulse(Fnet.x, Fnet.y)

    self.col.red = self.actuators['col.red']
    self.col.gre = self.actuators['col.gre']
    self.col.blu = self.actuators['col.blu']

    self.health = self.health - self.f_thrust * dt
end

function Agent:reproduce()
end

function Agent:mutate()
end

function Agent:consume(food)

    local energy_intake = food.energy or food.health + food.energy

    if self.energy < ENERGYSTORE then
        local deficit = ENERGYSTORE - self.energy
        local balance = energy_intake - deficit

        self.energy = self.energy + deficit
        self.health = self.health + balance
    else
        self.health = self.health + energy_intake
    end

end


function Agent:type()
    return 'Agent'
end

function Agent:typeOf(name)
    return name == self:type()
end
