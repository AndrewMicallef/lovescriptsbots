BindingSite = Class{__includes = Molecule}

-- A binding site is a special type of molecule. It is a sensor that can form a
-- molecular bond with certain types of molecules it comes into contact with.
--[[
   Binding sites must be instantiated with a parent molecule and a radius.
--]]

BindingSite.__type = "BindingSite"

function BindingSite:init(props)
    props.radius = props.radius or 8
    assert(props.parent:typeOf("Molecule"), "BindingSite requires Molecule parent")
    assert(type(props.radius) == 'number', "BindingSite requires numerical radius")
    props.shape = props.shape or love.physics.newCircleShape(props.loc.x,
                                                             props.loc.y,
                                                             props.radius)
    props.body = props.parent.body

    Molecule.init(self, props)

    self.fixture:setSensor(true)

    self.__debug = true
end

--[[
function BindingSite:update(dt)
end
--]]

function BindingSite:render()
    --TODO self.statemachine:render()

    if self.__debug then
        local cx,cy = self.body:getWorldPoints(self.shape:getPoint())
        local r = self.radius

        love.graphics.setColor(gColor['orange'])
        love.graphics.circle('line', cx, cy, r)
    end
end
