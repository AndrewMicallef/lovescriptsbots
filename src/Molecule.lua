Molecule = Class{__includes = GameObject}

Molecule.__type = "Molecule"

function Molecule:init(props)

    self.loc = props.loc or Vector.zero
    self.weight = props.weight or 1
    self.radius = props.radius or 25

    self.world = props.world
    self.body = love.physics.newBody(self.world, self.loc.x, self.loc.y, 'dynamic')
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    --self.statemachine = props.statemachine or StateMachine()
    self.bindsites = props.bindsites or {}
end

function Molecule:update(dt)
    -- arrange bindsites in a circular pattern at the edge of the molecule
    --self.statemachine:update(dt)
end

function Molecule:render()
    --self.statemachine:render()

    love.graphics.setColor(gColor['white'])
    love.graphics.circle('line', self.loc.x, self.loc.y, self.radius)

    for k, site in pairs(self.bindsites) do
        site:render()
    end
end
