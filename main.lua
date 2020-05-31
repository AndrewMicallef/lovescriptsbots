require "src.Dependancies"

function love.load()

    WIDTH, HEIGHT = love.window.getMode()
    gWorld = love.physics.newWorld()


    gEntities = {
        ['m'] = Molecule{world=gWorld,
                         loc = Vector(WIDTH/2, HEIGHT/2),
                         bindsites = 3
                         }
    }



end

function love.update(dt)

    for k, entity in pairs(gEntities) do
        entity:update(dt)
    end
end

function love.draw()

    for k, entity in pairs(gEntities) do
        entity:render()
    end
end
