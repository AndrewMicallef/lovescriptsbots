require 'src/Dependencies'


function love.load()

    WIDTH, HEIGHT = love.window.getMode()
    love.window.setTitle('Artificial Life')

    -- instantiate the world
    World = love.physics.newWorld(0,0, true)

    world_bounds = {}
    world_bounds.body = love.physics.newBody(World, 0, 0, 'static')
    world_bounds.shape = love.physics.newChainShape(true, {0,0, 0,HEIGHT, WIDTH, HEIGHT, WIDTH, 0})
    world_bounds.fixture = love.physics.newFixture(world_bounds.body, world_bounds.shape)

    -- spawn agents
    entities = {}

    for i=1, 60 do
        local lipid = Lipid{pos = Vector.randomDirection(10, 250) + Vector(WIDTH/2, HEIGHT/2),
                            angle = math.random() * math.pi * 2,
                            id = i,
                            world = World
                            }

        table.insert(entities, lipid)
    end

end

function love.update(dt)

    for _, entity in pairs(entities) do
        entity:update(dt)
    end

    World:update(dt)
end


function love.draw()

    for _, entity in pairs(entities) do
        entity:render()
    end
end


function love.mousepressed(x, y, button)
    if button == 1
        and selected
        and x > selected.pos.x - 10 and x < selected.pos.x + 10
        and y > selected.pos.y - 10 and y < selected.pos.y + 10
    then
    selected.dragging.active = true
    end

    if button == 2
    then
        local bodies = World:getBodies()
        --select the nearest item
        local nearest = {r=20, sel=nil}
        for _, body in pairs(bodies) do
            local px, py = body:getPosition()
            local r = math.abs(px-x) + math.abs(py-y)
            if r < nearest.r then
                nearest.r = r
                nearest.sel = body:getUserData()
            end
        end

        if nearest.sel then
            if selected then selected.isselected = nil end
            selected = nearest.sel
            selected.isselected = true
        else
            if selected then selected.isselected = nil end
        end
    end
end


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit('restart')
    end
end
