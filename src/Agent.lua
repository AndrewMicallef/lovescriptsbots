Agent = Class{}

function Agent:init(def)
    self.world = def.world --maintain reference to the world

    self.id=0

    self.pos = def.pos or Vector.new(math.random(0, WIDTH), math.random(0, HEIGHT))
    self.angle = def.angle or math.random() * 2 * math.pi

    self.health = def.health or math.random() * HEALTHMAX
    self.age = 0
    self.gencount = 0 or def.parent.gencount + 1

    self.col = {red = math.random() or def.parent.col.red,
                gre = math.random() or def.parent.col.gre,
                blu = math.random() or def.parent.col.blu
                }

    self.radius = 8

    self.clockf1 = math.random(5,100) or def.parent.clockf1
    self.clockf2 = math.random(5,100) or def.parent.clockf2

    self.MUTRATE1 = 0.003
    self.MUTRATE2 = 0.05

    -- physical presence
    self.body = love.physics.newBody(self.world, self.pos.x, self.pos.y, 'dynamic')
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.body:setUserData(self)

    self.sensors = Ntable{"health",
                           "angle",
                           "flagella.angle",
                           "flagella.thrust",
                           "col.red", "col.gre", "col.blu",
                           "vx", "vy",
                           "mx", "my"
                         }

    self.actuators = Ntable{
                        "flagella.angle",
                        "flagella.thrust",
                        "col.red", "col.gre", "col.blu",
                        }

    self.brain = Brain{sensors=self.sensors, actuators=self.actuators}

    -- collection of the traits that are able to be mutated
    self.mutable_traits = {}

end

function Agent:update(dt)

    -- metabolise
    self:metabolise(dt)

    -- sense
    self:sense()

    -- think
    self:think()

    -- act
    self:act()
end

function Agent:render()

    love.graphics.setColor(self.col.red, self.col.gre, self.col.blu, 1)

    local cx, cy = self.body:getWorldPoints(self.shape:getPoint())
    love.graphics.circle('fill', cx, cy, self.shape:getRadius())

end

function Agent:metabolise(dt)

--TODO overtime health declines
--TODO eating food adds to health
--TODO reproducing costs health


end

function Agent:sense()
    -- read out all sensor values
    self.sensors['health'] = cappedvalue(self.health / HEALTHMAX)

    local vx, vy = self.body:getLinearVelocity()
    self.sensors['vx'] = vx
    self.sensors['vy'] = vy
    self.sensors['angle'] = self.body:getAngle() / 2*math.pi

    self.sensors['col.red'] = self.col.red
    self.sensors['col.gre'] = self.col.gre
    self.sensors['col.blu'] = self.col.blu

    local mx, my = love.mouse.getPosition()
    self.sensors["mx"] = mx
    self.sensors["my"] = my
end

function Agent:think()
    -- brain needs to actuate some properties of the agent
    self.brain:update(self.sensors, self.actuators)
end

function Agent:act(dt)
    -- run all actuators
    local f_angle = self.actuators['flagella.angle'] * math.pi * 2
    local f_thrust = self.actuators['flagella.thrust'] * MAX_THRUST
    -- ...
    local Fnet = Vector.fromPolar(f_angle, f_thrust)
    self.body:applyLinearImpulse(Fnet.x, Fnet.y)

    self.col.red = self.actuators['col.red']
    self.col.gre = self.actuators['col.gre']
    self.col.blu = self.actuators['col.blu']
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
