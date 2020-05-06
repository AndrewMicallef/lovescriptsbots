Agent = Class{}

function Agent:init(def)
    self.world = def.world --maintain reference to the world

    self.id=0

    self.pos = def.pos or Vector.new(math.random(0, WIDTH), math.random(0, HEIGHT))
    self.angle = def.angle or math.random(0, 2) * math.pi

    self.health = def.health or math.random() * HEALTHMAX
    self.age = 0
    self.gencount = 0 or def.parent.gencount + 1

    self.red = math.random() or def.parent.red
    self.gre = math.random() or def.parent.red
    self.blu = math.random() or def.parent.red

    self.radius = 8

    self.w1=0
    self.w2=0

    self.clockf1 = math.random(5,100) or def.parent.clockf1
    self.clockf2 = math.random(5,100) or def.parent.clockf2


    self.MUTRATE1 = 0.003
    self.MUTRATE2 = 0.05

    -- physical presence
    self.body = love.physics.newBody(self.world, self.pos.x, self.pos.y, 'dynamic')
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.sensors = {} for i=1,INPUTSIZE do self.sensors[i] = 0 end
    self.actuators = {} for i=1,OUTPUTSIZE do self.actuators[i] = 0 end

    self.brain = Brain{sensors = self.sensors, actuators=self.actuators}

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

    love.graphics.setColor(self.red, self.gre, self.blu, 1)

    local cx, cy = self.body:getWorldPoints(self.shape:getPoint())
    love.graphics.circle('fill', cx, cy, self.shape:getRadius())


end

function Agent:metabolise(dt)



end

function Agent:sense()
    -- read out all sensor values
    self.sensors[1] = cappedvalue(self.health / HEALTHMAX)

end

function Agent:think()
    -- brain needs to actuate some properties of the agent
    self.brain:update(self.sensors)
end

function Agent:act()
    -- run all actuators
    for i=1, #self.actuators do
        -- move the thing
    end
end

function Agent:reproduce()
end

function Agent:mutate()
end
