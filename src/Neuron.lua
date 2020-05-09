Neuron = Class{}

-- keeps track of the
function Neuron:init(def)

    self.brain = def.brain -- back reference to brain
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
end

function Neuron:update(dt)
    self.output = self.output + (self.target - self.output)*self.dampening
end

function Neuron:compute_AND()
    local res = 1
    for j=1, CONNECTIONS do
        local synapse = self.synapse[j]
        local idx, w, inhb = synapse.synapse_id, synapse.w, synapse.is_inhibitory
        local post_syn_pot = self.brain.neurons[idx].output

        -- flip inhibitory synaptic potentials
        if inhb then
            post_syn_pot = 1 - post_syn_pot
        end

        res = res * post_syn_pot
    end
    res = res * self.bias
    self.target = res
end

function Neuron:compute_OR()
    local res = 0
    for j=1, CONNECTIONS do
        local synapse = self.synapse[j]
        local idx, w, inhb = synapse.synapse_id, synapse.w, synapse.is_inhibitory
        local post_syn_pot = self.brain.neurons[idx].output
        -- flip inhibitory synaptic potentials
        if inhb then
            post_syn_pot = 1 - post_syn_pot
        end

        res = res + (post_syn_pot * w)
    end

    res = res + self.bias
    self.target = res
end
