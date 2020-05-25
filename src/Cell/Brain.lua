Brain = Class{}

--[[
 * Damped Weighted Recurrent AND/OR Network

 initialised with sensors (inputs) and actuators (outputs)
 ]]
function Brain:init(def)

    -- Sensors are the first layer
    self.sensors = def.sensors
    -- Actuators are the output layer
    self.actuators = def.actuators

    self.inputsize = tablelength(self.sensors)
    self.outputsize = tablelength(self.actuators)

    -- TODO: for i in layers: for j in layer size
    self.neurons = {}
    for i=1, BRAINSIZE do
        self.neurons[i] = Neuron{inputsize=self.inputsize, brain=self}
    end

end

function Brain:update(sensors, actuators)

    -- set input layer neurons to sensor activation
    for i=1, sensors._count do
        self.neurons[i].output = sensors[sensors._keys[i]]
    end

    -- propgate synaptic potentials (values just flow through the network, no firing)
    for i=self.inputsize+1, BRAINSIZE do
        local neuron = self.neurons[i]

        -- compute each neuron
        if neuron.type == 0 then neuron:compute_AND()
        else neuron:compute_OR() end

        -- clamp target between 0 and 1
        neuron.target = softmax(neuron.target)

    end

    for i=self.inputsize+1, BRAINSIZE do
        self.neurons[i]:update(dt) -- moves nueron towards it's target value
    end

    -- actuators inherit the values of the last neurons in the brain
    -- TODO restructure brain to clean up input and output layer semantics
    for i=1, actuators._count do
        actuators[actuators._keys[i]] = self.neurons[BRAINSIZE-i].output
    end

end

function Brain:mutate(MR, MR2)

    -- TODO: Andrej used normalvariate random values to mutate each neuron property
end

function Brain:crossover(other)

    -- makes a new brain that gets neurons that are inherited from this brain and another
    local newbrain = Brain()

    for i=1, #newbrain.neurons do
        local source_neuron
        if math.random(0,1) then
            source_neuron = self.neurons[i]
        else
            source_neuron = other.neurons[i]
        end

        newbrain.neurons[i] = source_neuron
    end

    return(newbrain)

end
