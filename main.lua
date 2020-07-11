require 'src.dependancies'

love.keywaspressed = {}
love.mousewaspressed = {b={}, x={}, y={}}

local SR = 44100 -- sample rate

local cursor = {x=0, active=false}
local WIDTH, HEIGHT = love.window.getMode()
local source, song

local verts = {0, 1,
                0.2, 1,
                0.2, 0,
                0.2,.5,
                0.4, 0.5,
                0.4, 1,
                0.4, 0,
                0.6, 1,
               1, 1,
}
for i=1, #verts, 2 do
    verts[i] = verts[i] * WIDTH
    verts[i+1] = verts[i+1] * HEIGHT/2
end

local curve = Envelope(verts)
--[[
function envelope(samples, curve)--attack, decay, sustain, release)

    return samples
end
]]

function updatesound()
    local env = curve:asArray(song:getSampleCount())
    local freq = 261* math.random(-4,4) or 261

    local len = song:getSampleCount()-1

    for i=1, len do -- update 1 sec of data
        local sample = math.sin(i * freq / 44100 *math.pi) * env[i]
        song:setSample(i, sample)
    end
end


function love.load()

    source = love.audio.newQueueableSource(44100, 16, 1, 8)
    song = love.sound.newSoundData(44100, 44100, 16, 1)

    local env = curve:asArray(song:getSampleCount())
    for i=1, song:getSampleCount( )-1 do --fill in 1 sec of data
         -- C5
        song:setSample(i, math.sin(i * 261*2 / 44100 *math.pi ) * env[i])
    end

    --source:queue(song)


    love.keywaspressed = {}
    love.mousewaspressed = {button={}, x={}, y={}}

end

function love.draw()

    curve:render()

    --[[ draw the wave just to see what is happening]]

    love.graphics.setColor(1,1,1,.2)
    local samples = song:getSampleCount()
    local x0, y0 = 0, HEIGHT/2
    local x1, y1
    for i=1, samples do
        x1 = i/samples * WIDTH
        y1 = HEIGHT/2 - song:getSample(i-1) * HEIGHT/3

        love.graphics.line(x0, y0, x1, y1)

        x0, y0 = x1, y1
    end

    if cursor.active then
        love.graphics.setColor(1,0,0,1)
        love.graphics.line(cursor.x, 0, cursor.x, HEIGHT)
    end
    --]]
end

function love.update(dt)

    curve:update(dt)

    local buffers = source:getFreeBufferCount( )


    if love.keywaspressed['space'] then
        cursor.x = 0
        cursor.active = true
        source:queue(song)
        source:play()
        updatesound()
    end

    if cursor.active then
        cursor.x = cursor.x + (WIDTH * dt)

        if cursor.x > WIDTH then
            cursor.active = false
        end
    end

    love.keywaspressed = {}
    love.mousewaspressed = {button={}, x={}, y={}}
end

function love.keypressed(key, scancode, isrepeat)
    love.keywaspressed[key] = true
end

function love.mousepressed(x, y, button, isTouch)
    love.mousewaspressed = {button=button, x=x, y=y}
end
