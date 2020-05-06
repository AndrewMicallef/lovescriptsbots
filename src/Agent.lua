Agent = Class{}

function Agent:init(def)
    self.world = def.world --maintain reference to the world

    self.id=0

    self.pos = def.pos--Vector.new(math.random(0,WIDTH), math.random(0,HEIGHT))
    self.angle = def.angle--math.random(0, 2) * math.pi

    self.health = 2
    self.age = 0
    self.gencount = 0

    self.red = 0
    self.gre = 0
    self.blu = 0

    self.w1=0
    self.w2=0

    self.clockf1= math.random(5,100)
    self.clockf2= math.random(5,100)
    --self.repcounter= herbivore*randf(conf::REPRATEH-0.1,conf::REPRATEH+0.1) + (1-herbivore)*randf(conf::REPRATEC-0.1,conf::REPRATEC+0.1)


    self.MUTRATE1= 0.003
    self.MUTRATE2= 0.05

    self.sensors = {} for i=1,INPUTSIZE do self.sensors[i] = 0 end
    self.actuators = {} for i=1,OUTPUTSIZE do self.actuators[i] = 0 end

    self.brain = Brain{sensors = self.sensors, actuators=self.actuators}
end

function Agent:update(dt)
    -- brain needs to actuate some properties of the agent
    self.brain:update(self.sensors)

    for i=1, #self.actuators do
        -- update actuator i by the value
    end
end

function Agent:render()
end

function Agent:sense()
    -- read out all sensor values
end

function Agent:act()
    -- run all actuators
end

function Agent:reproduce()
end
