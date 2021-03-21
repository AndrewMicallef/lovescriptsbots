Domain = Class{}

function Domain:init(def)



    -- instantiate the world
    self.world = self:initPhysicsWorld()

    self.BBox = self:genBoundaryBodyFromPoints({0,0,
                                                WIDTH, 0,
                                                WIDTH, HEIGHT,
                                                0, HEIGHT})
    self.texture = self:genTexture({width=WIDTH, height=HEIGHT, gridsize=20})

    self.destroyedBodies = {}

end

function Domain:render()

    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.texture)

end

function Domain:update(dt)
    self.world:update(dt)

end


function Domain:genTexture(def)

    local width = def.width or WIDTH
    local height = def.height or HEIGHT
    local gs = def.gridsize or 20

    local fgcol = def.fgcol or {.1,.1,.1, 1}
    local bgcol = def.bgcol or {.2,.2,.2, 1}

    local texture = love.graphics.newCanvas()
    love.graphics.setCanvas(texture)

    --Render a grid on the screen
    for u=0, width, gs do
        for v=0, height, gs do
            local col
            if (((u+v) + (u*gs)) % (gs*2))  == 0 then
                col = fgcol
            else
                col = bgcol
            end
            love.graphics.setColor(col)
            love.graphics.rectangle('fill', u,v, gs,gs)
        end
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.line(self.BBox.body:getWorldPoints(self.BBox.shape:getPoints()))
    love.graphics.setCanvas()

    return texture
end

function Domain:genBoundaryBodyFromPoints(BBoxPoints)

    local BBox = {}
	BBox.body = love.physics.newBody(self.world, 0, 0, "kinematic")
	BBox.shape = love.physics.newChainShape(true, unpack(BBoxPoints))
	BBox.fixture = love.physics.newFixture(BBox.body, BBox.shape)
    BBox.fixture:setUserData(BBox)
    function BBox:type()
        return 'BBox'
    end

    return BBox
end

function Domain:initPhysicsWorld()

    local world = love.physics.newWorld(0,0, true)

    ----[[
    local function beginContact(a, b, coll)
        local types = {}
        types[a:getUserData():type()] = a:getUserData()
        types[b:getUserData():type()] = b:getUserData()

        if types['Food'] and types['Agent'] then
            local agent = types['Agent']
            local food = types['Food']

            if not food.eaten then
                agent:consume(food)
                food.eaten = true
                table.insert(self.destroyedBodies, food.body)
            end
        end
    end

    local function endContact(a, b, coll) end
    local function preSolve(a, b, coll) end
    local function postSolve(a, b, coll, normalimpulse, tangentimpulse) end

    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    return world
end
