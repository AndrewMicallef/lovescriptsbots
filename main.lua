require 'src/Dependencies'


function love.load()

    WIDTH, HEIGHT = love.window.getMode()
    love.window.setTitle('Artificial Life')

    -- instantiate the world
    world = love.physics.newWorld(0,0, true)

    world_bounds = {}
    world_bounds.body = love.physics.newBody(world, 0, 0, 'static')
    world_bounds.shape = love.physics.newChainShape(true, {0,0, 0,HEIGHT, WIDTH, HEIGHT, WIDTH, 0})
    world_bounds.fixture = love.physics.newFixture(world_bounds.body, world_bounds.shape)

    -- spawn agents
    d1 = Dummy{world=world,
                  pos=Vector.new(WIDTH/2, HEIGHT/2),
                  res=35
              }

    entities = {}

    entities[d1] = d1

    love.keywaspressed = {}
    physics = true
end

function love.update(dt)

    for _, v in pairs(entities) do
        if v.update then v:update(dt) end
    end

    if love.keywaspressed['space'] then physics = not physics end

    if physics then world:update(dt) end

    love.keywaspressed = {}
    
end


function love.draw()
    for _, v in pairs(entities) do
        if v.render then v:render(dt) end
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("EDGE LINKING TEST", WIDTH-150, 10)
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
        local bodies = world:getBodies()
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
    else
        love.keywaspressed[key] = true
    end
end
