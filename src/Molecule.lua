Molecule = Class{__includes = GameObject}

Molecule.__type = "Molecule"

function Molecule:init(props)
    self.parent = props.parent
    self.loc = props.loc or Vector.zero
    self.weight = props.weight or 1
    self.radius = props.radius or 25

    self.world = props.world
    self.body = props.body or love.physics.newBody(self.world, self.loc.x, self.loc.y, 'dynamic')
    self.shape = props.shape or love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    --self.statemachine = props.statemachine or StateMachine()
    self.bindsites = {}

    if props.bindsites then
        local N = props.bindsites
        for i=1, N do
            -- locate around a circle of radius = self.radius
            local r = self.radius
            local phi = (i/N) * 2*math.pi
            local loc = Vector.fromPolar(phi,  r)
            local site = BindingSite{parent=self, loc=loc}
            table.insert(self.bindsites, site)
        end
    end
end

function Molecule:update(dt)
    -- arrange bindsites in a circular pattern at the edge of the molecule
    -- TODO self.statemachine:update(dt)
end

function Molecule:render()
    -- TODO self.statemachine:render()

    love.graphics.setColor(gColor['white'])
    love.graphics.circle('line', self.loc.x, self.loc.y, self.radius)

    for k, site in pairs(self.bindsites) do
        site:render()
    end
end
