MenuState = Class{__includes = BaseState}

local window_width = 1000
local window_height = 800

local Buttons = {}

local function NewButton(string, func)
  return {
    text = string,
    fnc = func,

    now = false,
    last = false
  }
end

function MenuState:init()

  game_start = love.graphics.newFont("Assets/arcade.ttf",52)

  love.window.setMode(window_width, window_height)

  background_image = love.graphics.newImage("Assets/glacier.png")

  font = love.graphics.newFont(16)

  table.insert(Buttons, NewButton("Start Game",
    function()
        gStateMachine:change('Play')
        Sound:clean("button")
    end))

    table.insert(Buttons, NewButton("Exit",
    function()
       love.event.quit()
    end))

  Sound:init("button", {"Assets/Sounds/button_click.mp3", "Assets/Sounds/button_click_2.mp3"}, "static")
  Sound:init("Background Music", "Assets/Sounds/background_music.mp3", "stream")
  background_music = Sound:play("Background Music", "Background", 0.3, 1, true)
end

function MenuState:update(dt)
end

function MenuState:render()

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(background_image, 0, 0, 0, window_width/background_image:getWidth(), window_height/background_image:getHeight())

  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.printf("MELTDOWN MADNESS",game_start, 2, window_height/2 - 200, window_width, "center")
  love.graphics.setColor(0.5, 0.5, 0.5, 1)
  love.graphics.printf("MELTDOWN MADNESS",game_start, 0, window_height/2 - 200, window_width, "center")

  local ww = love.graphics.getWidth()
  local wh = love.graphics.getHeight()

  local button_width = ww/3
  local button_height = 30
  local margin = 15
  local cursor = 0
  local y_offset = 100

  local total_height = (button_height +margin) * #Buttons

  for i, button in pairs(Buttons) do
    button.last = button.now

    local bx = ww/2 - button_width/2
    local by = wh/2 - total_height/2 + cursor + y_offset

    local color = {0.4, 0.4, 0.5, 1}

    local mx, my = love.mouse.getPosition()

    local hot = mx > bx and mx < bx + button_width and
                my > by and my < by + button_height

    if hot then
      color = {0.8,0.8,0.9,1}
    end

    button.now = love.mouse.isDown(1)
      if button.now and not button.last and hot then
        Sound:play("button", "sfx", 1, 1, false)
        button.fnc()
      end


      love.graphics.setColor(unpack(color))
      love.graphics.rectangle("fill", bx, by, button_width, button_height)

      love.graphics.setColor(0, 0, 0, 1)
      local textH = font:getHeight(button.text)
      love.graphics.printf(button.text,font, bx, by + 5, button_width, "center")

      cursor = cursor + (button_height+margin)
  end
end
