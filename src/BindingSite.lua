BindingSite = Class{__includes = Molecule}

-- A binding site is a special type of molecule. It is a sensor that can form a
-- molecular bond with certain types of molecules it comes into contact with.

function BindingSite:init(props)
    self = Molecule(props)

    self.body = love.phsyics.newBody(self.loc.x, self.loc.y)
    self.shape = nil
    self.fixture = {}
    self.fixture:setSensor(true)

end

function BindingSite:update(dt)
end

function BindingSite:render()
end
