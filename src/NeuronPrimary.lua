NeuronPrimary = Class{__includes=Neuron}

function NeuronPrimary:init(def)
    self = Neuron{def}

    self.brain = def.brain -- back reference to brain

    --type 1 for AND neurons; 0 for OR neurons
    self.dampening = 1 - math.random()*.2 -- 0.8 - 1
    self.bias = math.random(-1, 1)

    self.inputs = def.inputs
    self.outputs = def.outputs

    -- synapse types: 'sensor', 'motor', 'inter'
    -- inter neurons are randomly connecteted to any neuron in the brain
    -- sensor neurons recieve input direct from a property of agent
    -- motor neurons output direct to a property of agent
    for i=1, CONNECTIONS do
        local synapse_id
        synapse_id = math.random(1, BRAINSIZE)
        -- make at least 20% of neurons link to input sensors
        if (math.random() < 0.2) then
            synapse_id = math.random(1,def.inputsize)
        end

        self.synapse[i] = {
            w = randf(0.1, 2), -- input weights
            synapse_id = synapse_id, -- id of synapse
            is_inhibitory = math.random(0,1) -- T/F inhibition
        }
    end

    self.output = 0 -- current output
    self.target = 0 -- target output state

    self.insource =
end
