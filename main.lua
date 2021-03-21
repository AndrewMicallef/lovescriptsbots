require 'src/Dependencies'


function love.load()

    WIDTH, HEIGHT = love.window.getMode()
    love.window.setTitle('Artificial Life')

    domain = Domain{}

    -- spawn agents
    entities = {}
    for i=1, POPULATION do
        table.insert(entities, Agent{world = domain.world, id=i})
    end

end

function love.update(dt)

    if not gPaused then
        for _, entity in pairs(entities) do
            entity:update(dt)
        end

        domain:update(dt)

        if math.random(0, 30) > 29 then
            table.insert(entities, Food{world=domain.world})
        end
    end

    -- destroy all bodies we calculated to destroy during the update call
    for k, body in pairs(domain.destroyedBodies) do
        if not body:isDestroyed() then
            body:destroy()
        end
    end

    -- reset destroyed bodies to empty table for next update phase
    domain.destroyedBodies = {}

    -- remove all destroyed entities from world
    for i = #entities, 1, -1 do
        if entities[i].eaten then
            table.remove(entities, i)
        end
    end

end


function love.draw()

    domain:render()

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

        local bodies = domain.world:getBodies()
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
