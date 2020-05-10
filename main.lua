require 'src/Dependencies'


function love.load()

    WIDTH, HEIGHT = love.window.getMode()
    love.window.setTitle('Artificial Life')

    -- instantiate the world
    world = love.physics.newWorld(0,0, true)


    destroyedBodies = {}
    ----[[
    local function beginContact(a, b, coll)
        local types = {}
        types[a:getUserData():type()] = a:getUserData()
        types[b:getUserData():type()] = b:getUserData()

        if types['Food'] and types['Agent'] then
            local agent = types['Agent']
            local food = types['Food']

            if not food.eaten then
                agent.health = agent.health + food.health
                food.eaten = true
                table.insert(destroyedBodies, food.body)
            end
        end
    end

    local function endContact(a, b, coll) end
    local function preSolve(a, b, coll) end
    local function postSolve(a, b, coll, normalimpulse, tangentimpulse) end

    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    --]]

    local DishPoints = {WIDTH, HEIGHT,
                        0, HEIGHT,
                        0,0,
                        WIDTH, 0
                        }

    Dish = {}
	Dish.body = love.physics.newBody(world, 0, 0, "kinematic")
	Dish.shape = love.physics.newChainShape(true, unpack(DishPoints))
	Dish.fixture = love.physics.newFixture(Dish.body, Dish.shape)
    Dish.fixture:setUserData(Dish)
    function Dish:type()
        return 'Dish'
    end
	--Dish.body:setAngularVelocity(0.5)

    -- spawn agents
    entities = {}
    for i=1, POPULATION do
        table.insert(entities, Agent{world = world, id=i})
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

    for _, entity in pairs(entities) do
        entity:update(dt)
    end

    world:update(dt)

    ----

    -- destroy all bodies we calculated to destroy during the update call
    for k, body in pairs(destroyedBodies) do
        if not body:isDestroyed() then
            body:destroy()
        end
    end

    -- reset destroyed bodies to empty table for next update phase
    destroyedBodies = {}

    -- remove all destroyed entities from world
    for i = #entities, 1, -1 do
        if entities[i].eaten then
            table.remove(entities, i)
        end
    end

    if math.random(0, 30) > 29 then
        table.insert(entities, Food{world=world, size=6,
                                    col={r=1, g=1,b=1}})
    end

end


function love.draw()

    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(background)

    for _, entity in pairs(entities) do
        entity:render()
    end

end
