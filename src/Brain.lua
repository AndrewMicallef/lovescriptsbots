Neuron = Class{}
Brain = Class{}

-- keeps track of the
function Neuron:init()

    self.type = math.random(0,1)
    --type 1 for AND neurons; 0 for OR neurons
    self.dampening = 1 - math.random()*.2 -- 0.8 - 1
    self.bias = math.random(-1, 1)

    self.synapse = {}

    for i=1, CONNECTIONS do
        local synapse_id
        synapse_id = math.random(1, BRAINSIZE)
        -- make at least 20% of neurons link to input sensors
        if (math.random() < 0.2) then
            synapse_id = math.random(1,INPUTSIZE)
        end

        self.synapse[i] = {
            w = randf(0.1, 2), -- input weights
            synapse_id = synapse_id, -- id of synapse
            is_inhibitory = math.random(0,1) -- T/F inhibition
        }
    end

    self.output = 0 -- current output
    self.target = 0 -- target output state
end

function Neuron:update(dt)
    self.output = self.output + (self.target - self.output)*self.dampening
end

--[[
 * Damped Weighted Recurrent AND/OR Network

 initialised with sensors (inputs) and actuators (outputs)
 ]]
function Brain:init(def)

    self.sensors = def.sensors
    self.actuators = def.actuators

    -- local inputsize = #self.sensors
    -- local outputsize = #self.actuators

    self.neurons = {}
    for i=1, BRAINSIZE do
        self.neurons[i] = Neuron()
    end

end

function Brain:update(sensors)

    -- set input layer neurons to sensor activation
    for i=1, INPUTSIZE do
        self.neurons[i].output = sensors[i]
    end

    -- propgate synaptic potentials (values just flow through the network, no firing)
    for i=INPUTSIZE+1, BRAINSIZE do
        local neuron = self.neurons[i]

        if neuron.type == 0 then
            -- AND NEURON
            local res = 1
            for j=1, CONNECTIONS do
                local synapse = neuron.synapse[j]
                local idx, w, inhb = synapse.synapse_id, synapse.w, synapse.is_inhibitory
                local post_syn_pot = self.neurons[idx].output

                -- flip inhibitory synaptic potentials
                if inhb then
                    post_syn_pot = 1 - post_syn_pot
                end


                res = res * post_syn_pot
            end
            res = res * neuron.bias
            neuron.target = res
        else
            -- OR NEURON
            local res = 0
            for j=1, CONNECTIONS do
                local synapse = neuron.synapse[j]
                local idx, w, inhb = synapse.synapse_id, synapse.w, synapse.is_inhibitory
                local post_syn_pot = self.neurons[idx].output

                -- flip inhibitory synaptic potentials
                if inhb then
                    post_syn_pot = 1 - post_syn_pot
                end

                res = res + (post_syn_pot * w)
            end

            res = res + neuron.bias
            neuron.target = res
        end

        -- clamp target between 0 and 1
        neuron.target = math.min(1, math.max(0, neuron.target))

    end

    for i=INPUTSIZE+1, BRAINSIZE do
        self.neurons[i]:update(dt) -- moves nueron towards it's target value
    end

    -- actuators inherit the values of the last neurons in the brain
    for i=1, OUTPUTSIZE do
        self.actuators[i] = self.neurons[BRAINSIZE-i].output
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
