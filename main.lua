require 'src/Dependencies'


function love.load()

    WIDTH, HEIGHT = love.window.getMode()
    love.window.setTitle('Artificial Life')

    -- instantiate the world
    world = love.physics.newWorld(0,0, true)

    -- spawn agents
    agent = Dummy{world=world,
                  pos=Vector.new(WIDTH/2, HEIGHT/2),
                  res=10
              }
end

function love.update(dt)

    agent:update(dt)

    world:update(dt)
end


function love.draw()
    agent:render()
end


function love.mousepressed(x, y, button)
    --[[get selected item
    if button == "l"
        and x > selected.x and x < selected.x + selected.width
        and y > selected.y and y < selected.y + selected.height
    then
    selected.dragging.active = true
    selected.dragging.diffX = x - selected.x
    selected.dragging.diffY = y - selected.y
    end
    ]]

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
        end
    end
end
