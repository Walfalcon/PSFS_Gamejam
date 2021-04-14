local moonshine = require 'moonshine'
require 'Map'
require 'Player'
require 'Enemy'

resolution = {16, 15}
realRes = {256, 240}
scale = 1
origin = {0, 0}
camera = {0, 0}
maps = {}
mapWidth = 3
debug = ""
messages = {}
showNodeMap = false
pathfindDist = 30

currentMap = 1
menu = "game"

function love.load()
  love.window.setMode(resolution[1], resolution[2], {fullscreen = true})
  local width, height = love.window.getMode()
  realRes[2] = height
  realRes[1] = resolution[1] * height / resolution[2]
  scale = realRes[2] / resolution[2]
  origin[1] = (width / 2) - (realRes[1] / 2)

  for y = 1, mapWidth do
    for x = 1, mapWidth do
      table.insert(maps, Map:create("Map" .. y .. "-" .. x))
    end
  end

  Player.load()
  love.graphics.setScissor(origin[1], origin[2], realRes[1], realRes[2])
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setColor(1, 1, 1)
  font = love.graphics.newFont("joystix.monospace.ttf", scale)
  love.graphics.setFont(font)
  love.graphics.setLineWidth(scale/16)
  love.graphics.setLineStyle("smooth")

  effect = moonshine(moonshine.effects.glow)
                    .chain(moonshine.effects.vignette)
                    .chain(moonshine.effects.crt)
  updatePath()
end

function love.update(dt)
  if love.keyboard.isDown("escape") then
    love.event.quit()
  end

  if Player.x > camera[1] + 8 then
    camera[1] = Player.x - 8
  elseif Player.x < camera[1] + 6 then
    camera[1] = Player.x - 6
  end
  if Player.y > camera[2] + 8 then
    camera[2] = Player.y - 8
  elseif Player.y < camera[2] + 6 then
    camera[2] = Player.y - 6
  end
end

function love.keypressed(key, scancode, isrepeat)
  if menu == "updates" then
    menu = "game"
    return
  end
  local input = nil

  if scancode == "q" or key == "7" then
    input = "ul"
  elseif scancode == "w" or scancode == "up" or key == "8" then
    input = "u"
  elseif scancode == "e" or key == "9" then
    input = "ur"
  elseif scancode == "a" or scancode == "left" or key == "4" then
    input = "l"
  elseif scancode == "s" or scancode == "space" or key == "5" then
    input = "wait"
  elseif scancode == "d" or scancode == "right" or key == "6" then
    input = "r"
  elseif scancode == "z" or key == "1" then
    input = "dl"
  elseif scancode == "x" or scancode == "down" or key == "2" then
    input = "d"
  elseif scancode == "c" or key == "3" then
    input = "dr"
  elseif scancode == "m" then
    menu = "messages"
    return
  end

  if input and menu == "game" then
    Player.update(input)
    Enemy.createQueue()
    for index, enemy in pairs(Enemy.enemyQueue) do
      if enemy.moveclock >= 1 then
        if Enemy.move(enemy) then
          enemy.moveclock = enemy.moveclock - 1
          if enemy.moveclock >= 1 then
            table.insert(Enemy.enemyQueue, enemy)
          end
        else
          table.insert(Enemy.enemyQueue, enemy)
        end
      end
    end
    for index, map in pairs(maps) do
      if index == currentMap or
        index == currentMap - mapWidth or
        index == currentMap + mapWidth or
        (index == currentMap - 1 and currentMap % mapWidth ~= 1) or
        (index == currentMap + 1 and currentMap % mapWidth ~= 0) or
        (index == currentMap - mapWidth - 1 and currentMap % mapWidth ~= 1) or
        (index == currentMap - mapWidth + 1 and currentMap % mapWidth ~= 0) or
        (index == currentMap + mapWidth - 1 and currentMap % mapWidth ~= 1) or
        (index == currentMap + mapWidth + 1 and currentMap % mapWidth ~= 0) then
        map.active = true
      else
        map.active = false
      end
    end
  end
end

function love.draw()
  effect(function()
    if menu == "game" then
      for index, enemy in pairs(Enemy.enemies) do
        if maps[enemy.currentMap].active then
          Enemy.draw(enemy)
        end
      end

      Player.draw()
      for index, map in pairs(maps) do
        map:draw()
      end
      love.graphics.setColor(0, 0, 0)
      love.graphics.rectangle("fill", origin[1], realRes[2] - scale, realRes[1], scale)
      if messages[2] then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print(messages[2], origin[1], realRes[2] - scale, 0, 0.5)
      end
      love.graphics.setColor(1, 1, 1)
      if messages[1] then
        love.graphics.print(messages[1], origin[1], realRes[2] - (scale/2), 0, 0.5)
      end
    elseif menu == "messages" then
      if messages[1] then
      end

      for index, message in pairs(messages) do
        love.graphics.print(message, origin[1], realRes[2] - (scale/2) * index, 0, 0.5)
        if index == 1 then
          love.graphics.setColor(0.5, 0.5, 0.5)
        end
      end
      love.graphics.setColor(1, 1, 1)
    end
  end)
  love.graphics.print(debug, origin[1], origin[2])
end

function pushMessage(text)
  table.insert(messages, 1, text)
  while #messages > 30 do
    messages[#messages] = nil
  end
end
