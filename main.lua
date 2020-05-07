require 'src/Dependencies'


function love.load()

    WIDTH, HEIGHT = love.window.getMode()
    love.window.setTitle('Artificial Life')

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


    background = love.graphics.newCanvas()
    love.graphics.setCanvas(background)

    --Render a grid on the screen
    for u=0, WIDTH, 20 do
        for v=0, HEIGHT, 20 do
            local col
            if (((u+v) + (u*20)) % 40)  == 0 then
                col = {.1,.1,.1, 1}
            else
                col = {.2,.2,.2, 1}
            end
            love.graphics.setColor(col)
            love.graphics.rectangle('fill', u,v, 20,20)
        end
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.line(Dish.body:getWorldPoints(Dish.shape:getPoints()))
    love.graphics.setCanvas()


end

function love.update(dt)

    for _, a in pairs(agents) do
        a:update(dt)
    end

    world:update(dt)

end


function love.draw()

    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(background)

    for _, a in pairs(agents) do
        a:render()
    end


end
