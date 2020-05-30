Molecule = Class{}

function Molecule:init(props)

    self.loc = props.loc or Vector.zero
    self.weight = props.weight or 1

    self.bindsites = props.bindsites
end

function Molecule:update(dt)
end

function Molecule:render()
end
