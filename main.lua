Class = require "library/class"
require "States/BaseState"
require "library/StateMachine"
require "States/PlayState"
require "States/MenuState"
require "States/EndState"
Sound = require "library/sound"
anim8 = require 'library/anim8-master/anim8'

function love.load()

  love.window.setTitle("MELTDOWN MADNESS")

    gStateMachine = StateMachine
    {
      ['Menu'] = function() return MenuState() end,
      ['Play'] = function() return PlayState() end,
      ['End'] = function() return EndState() end
    }

    gStateMachine:change('Menu')

end

function love.update(dt)

    gStateMachine:update(dt)

end

function love.keypressed(key)
  gStateMachine:check_key_pressed(key)
end

function love.draw()
    gStateMachine:render()
end
