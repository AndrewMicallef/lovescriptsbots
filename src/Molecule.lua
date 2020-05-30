Molecule = Class{__includes = GameObject}

Molecule.__type = "Molecule"

function Molecule:init(props)

    self.loc = props.loc or Vector.zero
    self.weight = props.weight or 1
    self.radius = props.radius or 1

    self.statemachine = props.statemachine or StateMachine()
    self.bindsites = props.bindsites
end

function Molecule:update(dt)
    -- arrange bindsites in a circular pattern at the edge of the molecule
    self.statemachine:update(dt)
end

function Molecule:render()
    self.statemachine:render()
end
