-- An enyzme is a molecule with a binding site. It's actions modify the molecule
-- it is bound to
Enzyme = Class{__includes = Molecule}

Enzyme.__type = 'Enzyme'

function Enzyme:init(props)
    self = Molecule(props)
end
