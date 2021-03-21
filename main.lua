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
                agent:consume(food)
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

    if not gPaused then
        for _, entity in pairs(entities) do
            entity:update(dt)
        end

        world:update(dt)

        if math.random(0, 30) > 29 then
            table.insert(entities, Food{world=world})
        end
    end
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



end


function love.draw()

    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(background)

    for _, entity in pairs(entities) do
        entity:render()

        if entity.isselected then
            local cx, cy = entity.pos.x, entity.pos.y
            local ir,ig,ib = 1-entity.col.red, 1-entity.col.gre, 1-entity.col.blu
            local lw = love.graphics.getLineWidth()
            love.graphics.setLineWidth(3)
            love.graphics.setColor(1,1,1,1)
            love.graphics.circle('line', cx, cy, 15)
            love.graphics.setLineWidth( lw )
        end

    end
end

function love.mousepressed(x, y, button)
    if button == 2
        and selected
        --and x > selected.pos.x - 10 and x < selected.pos.x + 10
        --and y > selected.pos.y - 10 and y < selected.pos.y + 10
    then
        selected.dragging = {}
    end

    if button == 1
    then

        local bodies = world:getBodies()
        --select the nearest item
        local nearest = {r=20, sel=nil}
        for _, body in pairs(bodies) do
            local px, py = body:getPosition()
            local r = ((px-x)^2 + (py-y)^2)^0.5
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


function love.mousereleased(x, y, button)
   if button == 2
       and selected
   then
       selected.dragging = nil
   end
end

function love.keypressed(key, scancode, isrepeat)
   if key == "escape" then
      love.event.quit("restart")
   end

   if key == "space" and gPaused then
       gPaused = false
   else
       gPaused = true
   end

end
