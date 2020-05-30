require "src.Dependancies"

function love.load()
    gWorld = love.physics.newWorld()

    this = Class{__includes = Object}
    print(this.type)
end

function love.update(dt)
end

function love.draw()
end
