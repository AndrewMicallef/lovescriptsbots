require 'src/Dependencies'

WIDTH = love.graphics.getWidth()
HEIGHT  = love.graphics.getHeight()
function love.load()

    -- instantiate the world
    world = love.physics.newWorld(0,0, true)

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

end


function love.draw()

    for _, a in pairs(agents) do
        a:render()
    end

end
