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
                  res=25
              }
    d2 = Dummy{world=world,
                  pos=Vector.new(WIDTH/2+250, HEIGHT/2+50),
                  res=20
              }

    entities = {}

    ball = {}
    ball.body = love.physics.newBody(world, 5, HEIGHT/2, 'dynamic')
    ball.shape = love.physics.newCircleShape(10)
    ball.fixture =love.physics.newFixture(ball.body, ball.shape)
    ball.body:applyLinearImpulse(300, 0)

    entities[d1] = d1
    entities[d2] = d2
    entities[ball] = ball

end

function love.update(dt)

    for _, v in pairs(entities) do
        if v.update then v:update(dt) end
    end

    world:update(dt)
end


function love.draw()
    for _, v in pairs(entities) do
        if v.render then v:render(dt) end
    end

    local cx, cy = ball.body:getPosition()
    love.graphics.setColor(1,1,1,1)
    love.graphics.circle('fill', cx, cy, 10)
end


function love.mousepressed(x, y, button)
    if button == 1
        and selected
        and x > selected.x - 10 and x < selected.x + 10
        and y > selected.y - 10 and y < selected.y + 10
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
    end
end
