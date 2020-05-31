Molecule = Class{__includes = GameObject}

Molecule.__type = "Molecule"

function Molecule:init(props)
    self.parent = props.parent
    self.loc = props.loc or Vector.zero
    self.weight = props.weight or 1
    self.radius = props.radius or 25
    self.angle = props.angle or 0

    self.world = props.world
    self.body = props.body or love.physics.newBody(self.world, self.loc.x, self.loc.y, 'dynamic')
    self.shape = props.shape or love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.body:setUserData(self.parent)

    --self.statemachine = props.statemachine or StateMachine()
    self.bindsites = {}

    if props.bindsites then
        local N = props.bindsites
        for i=1, N do
            -- locate around a circle of radius = self.radius
            local r = self.radius
            local phi = (i/N) * 2*math.pi
            local loc = Vector.fromPolar(phi,  r)
            local site = BindingSite{parent=self, loc=loc, radius=props.bs_r}
            table.insert(self.bindsites, site)
        end
    end

    self.body:setAngle(self.angle)

    self.forces = {}
    self.bonds = {}

    --self.bonds.__dirty = false
    --self.bonds.__count = 0
end

function Molecule:update(dt)
    -- arrange bindsites in a circular pattern at the edge of the molecule
    self.forces = {}
    -- TODO self.statemachine:update(dt)
    self.loc = Vector(self.body:getPosition())
    self.angle = self.body:getAngle()

    -- calculate forces
    for _, body in ipairs(self.world:getBodies()) do
        local other = body:getUserData()
        if other.typeOf then
            if other:typeOf('Molecule') then
                self:exertForce(other)

            end
        end
    end

    local fnet = Vector.zero
    for _, f in ipairs(self.forces) do
        fnet = f + fnet
    end


    -- apply forces
    self.body:applyLinearImpulse(fnet.x, fnet.y)

end

function Molecule:render()
    -- TODO self.statemachine:render()

    love.graphics.setColor(gColor['white'])
    love.graphics.circle('line', self.loc.x, self.loc.y, self.radius)

    for k, site in pairs(self.bindsites) do
        site:render()
    end
end

function Molecule:exertForce(other)

    if self.bonds[other] then
        return
    end

    local dist = self.loc:dist2(other.loc)
    local dir = (self.loc - other.loc):normalized()

    local fmag = ELEC_FIELD_K --/ math.min(dist, 1)
    local force
    if countitems(self.bonds) < 2 then
        -- this molecule has available binding sites so should attract others
        force = - fmag * dir
    else
        -- this molecule has no available binding sites so should repel others
        force = fmag * dir
    end

    table.insert(self.forces, force)
end
