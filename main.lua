require 'src/Dependencies'


function love.load()

    WIDTH, HEIGHT = love.window.getMode()

    -- instantiate the world
    world = love.physics.newWorld(0,0, true)


    local DishPoints = { WIDTH, HEIGHT,
                        0, HEIGHT,
                        0,0,
                         WIDTH, 0,
                        }

    Dish = {}
	Dish.body = love.physics.newBody(world, 0, 0, "kinematic")
	Dish.shape = love.physics.newChainShape(true, unpack(DishPoints))
	Dish.fixture = love.physics.newFixture(Dish.body, Dish.shape)
	--Dish.body:setAngularVelocity(0.5)


    -- spawn agents
    agents = {}
    for i=1, POPULATION do
        agents[i] = Agent{world = world, id=i}
    end

end

function love.update(dt)

    for _, a in pairs(agents) do
        a:update(dt)
    end

    world:update(dt)

end


function love.draw()

    for _, a in pairs(agents) do
        a:render()
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.line(Dish.body:getWorldPoints(Dish.shape:getPoints()))

end
