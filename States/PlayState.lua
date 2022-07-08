PlayState = Class{__includes = BaseState}

-------------- window size -------------------
local window_width = 1000
local window_height = 800
---------------------------------------------
----------------player health----------------
max_health=10
player_health=10
----------------------------------------------
math.randomseed(os.time())

  platforminfo={}

------ function to create platforms -------------
function createplatform()
    platform={}
    platform.width=150
    platform.height=50
    platform.x=math.random(50,800)
    platform.y=firstspawn
    platform.scored=true
    platform.windfield = world:newRectangleCollider(platform.x,platform.y,platform.width,platform.height)
    platform.windfield:setType('static')
    platform.windfield:setCollisionClass('Platform')
    return platform
  end
-------------------------------------------------
---------create wave------------------------------
waves={}
waves.x=0
waves.y=200
waves.speed=15
---------------------------------------------------
score=0
----------create player----------------------------
character={}
character.x=475
character.y=100
character.width=50
character.height=50
character.health=10
character.grounded=true
-------- parameters for platform spawing ---------
  gap = -150
  firstspawn = -150
------------------------------------------------

------------- function to create icicles ---------------------
  icicleinfo = {}
  function createicicle()
    local icicles = {}
    icicles.x1 = math.random(player:getX()-30,player:getX()+40)
    icicles.y1 = player:getY()-500
    icicles.x2 = icicles.x1+30
    icicles.y2 = icicles.y1
    icicles.x3 = (icicles.x1+icicles.x2)/2
    icicles.y3 = player:getY()-360
    icicles.height=icicles.y3-icicles.y2
    icicles.width=icicles.x2-icicles.x1
    icicles.windfield = world:newPolygonCollider({icicles.x1,icicles.y1,icicles.x2,icicles.y2,icicles.x3,icicles.y3})
    icicles.windfield:setCollisionClass('Icicles')
    return(icicles)

  end
---------------------------------------------------



function PlayState:init()

  score_font=love.graphics.newFont(28)

  platformbase1x=math.random(0,800)

  love.window.setMode(window_width, window_height)

--------------- create world -----------------------
  wf = require "library/windfield-master/windfield"
  world = wf.newWorld(0, 550, false)
  world:setQueryDebugDrawing(false)
---------------------------------------------------

----------- Collision Classes --------------------
  world:addCollisionClass('Icicles')
  world:addCollisionClass('Platform')
  world:addCollisionClass('Player')
  world:addCollisionClass('BasePlatform')
  -------------------------------------------------

-------- Camera Initialization -----------------------
  camera = require "library/camera"
  cam = camera()
  ----------------------------------------------------

--------------- create player ---------------------------
  player = world:newRectangleCollider(character.x, character.y,character.width,character.height)
  player:setCollisionClass('Player')
  player:setFixedRotation(true)
---------------------------------------------------------

---------------- Create Ground -----------------------------------------
  platformbase = world:newRectangleCollider(0, 150, window_width, 100)
  platformbase:setCollisionClass('BasePlatform')
  platformbase:setType('static')
------------------------------------------------------------------------

------------------- Create first platform -------------------------------------
  platformbase1 = world:newRectangleCollider(platformbase1x,0,150 ,50)
  platformbase1:setCollisionClass('Platform')
  platformbase1:setType('static')

-------------------------------------------------------------------------------
-------------------Create wave------------------------------------------------
  wave_image=love.graphics.newImage("Assets/bg_mltdown_real.png")
-------------------------------------------------------------------------------
--[[
--------------------- world borders -----------------------------------
  wall_left = world:newLineCollider(-1, player:getY() - window_width/2 , -1, window_height)
  wall_right = world:newLineCollider(window_width + 1, player:getY() - window_width/2 , window_width+1, window_height)
  wall_left:setType('static')
  wall_right:setType('static')
  ------------------------------------------------------------------------
  ]]

--------- timers initialization ---------------
  icicles_timer = 0
  platformtimer = 0
  wave_timer = 0
  ice_cracking_timer = 0
  -------------------------------------------

-----------------  One-way platforms ------------------------------
  --[[player:setPreSolve(function(collider_1, collider_2, contact)
    if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Platform' then
      local px, py = collider_1:getPosition()
      local pw, ph = 20, 40
      local tx, ty = collider_2:getPosition()
      local tw, th = 100, 20
      if py + ph/2 > ty - th/2 then contact:setEnabled(false) end
    end
  end)]]
----------------------------------------------------------------------

-------------- Sounds Initialization ------------------------------------------------------------
  Sound:init("Ice Cracking", {"Assets/Sounds/ice-cracking-01.mp3", "Assets/Sounds/ice-cracking-02.mp3"}, "stream")
  Sound:init("Icicle Hit", "Assets/Sounds/ice-hit.mp3", "stream")
--------------------------------------------------------------------------------

--------------------- Background Image-----------------------------
bg=love.graphics.newImage('Assets/background main.jpg')
-------------------------------------------------------------------
--------------------- Platform Image-----------------------------
plat=love.graphics.newImage('Assets/platform.png')
platbase=love.graphics.newImage('Assets/ground.png')
-------------------------------------------------------------------
--------------------- Icicle Image-----------------------------
icle=love.graphics.newImage('Assets/icicle.png')
-------------------------------------------------------------------
--------------------- healthbar Image-----------------------------
healthbar=love.graphics.newImage('Assets/healthbar.png')
-------------------------------------------------------------------

player_image = love.graphics.newImage('Assets/playerSheet.png')
local grid = anim8.newGrid(614, 564, player_image:getWidth(), player_image:getHeight())
player.animations = {}
player.animations.idle = anim8.newAnimation(grid('1-15',1), 0.05)
player.animations.jump = anim8.newAnimation(grid('1-7', 2), 0.05)
player.animations.run = anim8.newAnimation(grid('1-15', 3), 0.05)
player.current_animation = player.animations.idle

flag = 1

end

function PlayState:update(dt)
  player.current_animation = player.animations.idle

  colliders = world:queryRectangleArea(player:getX()-character.width/2,player:getY()+25,character.width,5,{'Platform','BasePlatform'})

  if #colliders>0 then
    character.grounded=true
else
    character.grounded=false
end

---------- paltform y update ----------------------
  --firstspawn = firstspawn + gap*dt
--------------------------------------------------

  ------------- timers update ---------------------
  platformtimer = platformtimer + dt
  icicles_timer = icicles_timer + dt
  wave_timer = wave_timer + dt
  ice_cracking_timer = ice_cracking_timer + dt
-------------------------------------------------

----------- Ice cracking sound --------------------
  if ice_cracking_timer > 8 then
    ice_cracking = Sound:play("Ice Cracking", "Background", 0.2, 1, false)
    ice_cracking_timer = 0
  end
---------------------------------------------------

---------------player movement --------------------
  local px,py=player:getPosition()
  if love.keyboard.isDown('d') then
    player:setX(px+300*dt)
    flag = 1
    if character.grounded then
      player.current_animation = player.animations.run
    else
      player.current_animation = player.animations.jump
    end
  end

  if love.keyboard.isDown('a') then
    player:setX(px-300*dt)
    flag = -1
    if character.grounded then
      player.current_animation = player.animations.run
    else
      player.current_animation = player.animations.jump
    end
  end

  if px<0 then
    player:setX(0)
  end

  if px>window_width then
    player:setX(window_width)
  end

----------------------------------------------------

--------------------platform spawing ---------------
  if platformtimer>0.5 then
    table.insert(platforminfo,createplatform())
    firstspawn = firstspawn + gap
    platformtimer=0
  end
-----------------------------------------------------


  world:update(dt)
-------------------wave spawning----------------------
  if wave_timer>3 then
    waves.y=math.min(player:getY() + window_height/2, waves.y-waves.speed*dt)
  end
-----------------------------------------------------
------------ camera position ------------------------
  cam:lookAt(window_width/2, player:getY())
-----------------------------------------------------

-------------- icicles spawing ----------------------
    if icicles_timer>2 then
        table.insert(icicleinfo,createicicle())
        icicles_timer = 0
    end
-----------------------------------------------------

----------------- Platform deletion ------------------------
  for key,values in pairs(platforminfo) do
    if values.windfield:getY() > (player:getY()+window_height) then
        values.windfield:destroy()
        table.remove(platforminfo,key)

    end
  end
-------------------------------------------------------------

  -------------collision of icicles and platform-----------------
  for k,v in pairs(icicleinfo) do
    if v.windfield:enter('Platform') then
      icicle_hit = Sound:play("Icicle Hit", "sfx", 0.8, 1, false)
      v.windfield:destroy()
      table.remove(icicleinfo,k)
    end
  end
  for k,v in pairs(icicleinfo) do
    if v.windfield:enter('BasePlatform') then
      icicle_hit = Sound:play("Icicle Hit", "sfx", 0.8, 1, false)
      v.windfield:destroy()
      table.remove(icicleinfo,k)
    end
  end
  -----------------------------------------------------------------
  ----------------collision of icicles and player------------------
  for k,v in pairs(icicleinfo) do
    if v.windfield:enter('Player') then
      icicle_hit = Sound:play("Icicle Hit", "sfx", 0.5, 1, false)
      player_health=player_health-1
      v.windfield:destroy()
      table.remove(icicleinfo,k)
    end
  end
  for k,v in pairs(platforminfo) do
    if v.windfield:enter('Player') and v.scored==true then
        score=score+1
        v.scored=false
    end
  end
  ------------------------------------------------------------------
  if player:getY()+character.height/2>=waves.y+50 then
    player_health=0
    waves.y=200
  end
  if player_health==0 then
    gStateMachine:change('End')
    Sound:clean("Ice Cracking")
    Sound:clean("Background Music")
    Sound:clean("Icicle Hit")
    firstspawn = 0
    player_health=max_health
    platforminfo={}
  end

  player.current_animation:update(dt)

end

function PlayState:check_key_pressed(key)--------------------------------updates Akshay
  -------------------------------updates Akshay
  if #colliders>0 then-------------------------------------updates Akshay
    character.grounded = true-------------------------------updates Akshay
  else-------------------------------updates Akshay
    character.grounded = false-------------------------------updates Akshay
  end-------------------------------updates Akshay
-------------- player jumping --------------
  if key == 'space' and character.grounded == true then
    player:applyLinearImpulse(0,-2500)
    player.current_animation = player.animations.jump
  end
-------------------------------------------

end

function PlayState:render()
  love.graphics.setColor(1,1,1)
  love.graphics.draw(bg,0,0)
  cam:attach()
      -- world:draw()
      love.graphics.setColor(1,1,1)
      love.graphics.draw(plat,platformbase1x,0)
      love.graphics.draw(platbase,0,150)
      for i,v in ipairs(platforminfo) do
        love.graphics.draw(plat,v.x,v.y)
      end
      for i,v in ipairs(icicleinfo) do
        love.graphics.setColor(1,1,1)
        love.graphics.draw(icle,v.windfield:getX()+v.x1,v.windfield:getY()+v.y1)
      end

      player.current_animation:draw(player_image, player:getX() - flag*25, player:getY() - 50, 0, flag*0.15, 0.15)
      love.graphics.draw(wave_image,waves.x,waves.y,0,window_width/wave_image:getWidth(),window_height/wave_image:getHeight())

  cam:detach()
  love.graphics.setColor(0,1,0)
  love.graphics.rectangle("fill",70,20,player_health*23.3,60)
  love.graphics.setColor(1,0,0)
  love.graphics.print("Score:"..score,score_font,880,20)
  love.graphics.draw(healthbar,10,10)
end
