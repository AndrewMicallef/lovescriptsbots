NeuronPrimary = Class{__includes=Neuron}

function NeuronPrimary:init(def)
    self = Neuron{def}

    self.brain = def.brain -- back reference to brain

    --type 1 for AND neurons; 0 for OR neurons
    self.dampening = 1 - math.random()*.2 -- 0.8 - 1
    self.bias = math.random(-1, 1)

    self.inputs = def.inputs
    self.outputs = def.outputs

    self.output = 0 -- current output
    self.target = 0 -- target output state

    self.synapses = {}
    --self.insource =
end

function NeuronPrimary:setSynapses()
    -- synapse types: 'sensor', 'motor', 'inter'
    -- inter neurons are randomly connected to any neuron in the brain
    -- sensor neurons recieve input direct from a property of agent
    -- motor neurons output direct to a property of agent
    for i, input in ipairs(self.inputs) do

        local synapse = Synapse()

        table.insert(self.synapses, synapse)
        
    end
end


Synapse = Class{}

function Synapse:init(def)
    -- number between 0 - 2
    self.weight = def.weight

    -- string; one of 'excitatory' or 'inhibitory'
    self.transmitter = def.transmitter

    self.pre = def.pre
    self.post = def.post

    -- allows for transduction function in the case of sensors / actuators
    self.pre_func = def.pre_func
    self.post_func = def.post_func
end
