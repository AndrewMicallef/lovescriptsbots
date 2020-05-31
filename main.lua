require "src.Dependancies"

function love.load()

    WIDTH, HEIGHT = love.window.getMode()
    math.randomseed(os.time())

    gWorld = love.physics.newWorld(0, 0)

    gEntities = {}
    for i=1, 150 do
        local m = Molecule{world=gWorld,
                            loc = Vector(WIDTH/2, HEIGHT/2) + Vector.randomDirection(250),
                            radius = 5,
                            bindsites = 3,
                            bs_r = 3,
                            angle = math.random() * 2*math.pi
                         }

        table.insert(gEntities, m)
    end

end

function love.update(dt)

    gWorld:update(dt)

    for k, entity in pairs(gEntities) do
        entity:update(dt)
    end
end

function love.draw()

    for k, entity in pairs(gEntities) do
        entity:render()
    end
end
