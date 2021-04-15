local moonshine = require 'moonshine'
require 'Map'
require 'Player'
require 'Enemy'

resolution = {16, 15}
realRes = {512, 480}
scale = 512 / 16
origin = {0, 0}
camera = {0, 0}
maps = {}
mapWidth = 3
debug = ""
messages = {}
showNodeMap = false
pathfindDist = 30
mute = false
fontsize = 64

currentMap = 1
menu = "main"

function love.load()
  local windowFlags = {}
  windowFlags.resizable = true
  windowFlags.minwidth = resolution[1]
  windowFlags.minheight = resolution[2]
  love.window.setMode(realRes[1], realRes[2], windowFlags)
  love.window.setTitle("UNCHARTED FEAT. DRAKE")
  love.graphics.setScissor(origin[1], origin[2], realRes[1], realRes[2])
  love.graphics.setColor(1, 1, 1)
  font = love.graphics.newFont("joystix.monospace.ttf", fontsize)
  font:setLineHeight(fontsize / font:getHeight())
  love.graphics.setFont(font)
  love.graphics.setLineWidth(scale/16)
  love.graphics.setLineStyle("smooth")
  music = love.audio.newSource("Uncharted1.wav", "stream")
  effect = moonshine(moonshine.effects.glow)
                    .chain(moonshine.effects.crt)

  effect.crt.offset = origin
  effect.crt.resolution = realRes
  effect.crt.feather = 0.05
end

function love.resize(width, height)
  if width / height > resolution[1] / resolution[2] then
    realRes[2] = height
    realRes[1] = resolution[1] * height / resolution[2]
  else
    realRes[1] = width
    realRes[2] = resolution[2] * width / resolution[1]
  end
  scale = realRes[2] / resolution[2]
  origin[1] = (width - realRes[1]) / 2
  origin[2] = (height - realRes[2]) / 2
  effect.crt.offset = origin
  effect.crt.resolution = realRes
  effect.resize(width, height)
end

function setup()
  for index, map in pairs(maps) do
    map = nil
  end
  for y = 1, mapWidth do
    for x = 1, mapWidth do
      table.insert(maps, Map:create("Map" .. y .. "-" .. x))
    end
  end
  Player.load()
  updatePath()
  love.audio.play(music)
end

function love.update(dt)

end

function love.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    love.event.quit()
  end
  if menu == "messages" then
    menu = "game"
    return
  elseif menu == "game" then
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
    elseif scancode == "`" then
      if mute then
        love.audio.play(music)
      else
        love.audio.pause()
      end
      mute = not mute
      return
    end

    if input then
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
  else
    if key == "s" then
      menu = "game"
      setup()
      return
    end
  end
end

function love.draw()
  love.graphics.setScissor(origin[1], origin[2], realRes[1], realRes[2])
  local x, y, w, h = love.graphics.getScissor()
  debug = x .. " " .. y .. "\n" .. w .. " " .. h
  effect(function()
    if menu == "messages" then
      for index, message in pairs(messages) do
        love.graphics.print(message, origin[1], origin[2] + realRes[2] - (scale / 2) * index, 0, 0.5 * scale / fontsize)
        if index == 1 then
          love.graphics.setColor(0.5, 0.5, 0.5)
        end
      end
      love.graphics.setColor(1, 1, 1)
    elseif menu == "game" then
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
      love.graphics.rectangle("fill", origin[1], origin[2] + realRes[2] - scale, realRes[1], scale)
      if messages[2] then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print(messages[2], origin[1], origin[2] + realRes[2] - scale, 0, 0.5 * scale / fontsize)
      end
      love.graphics.setColor(1, 1, 1)
      if messages[1] then
        love.graphics.print(messages[1], origin[1], origin[2] + realRes[2] - (scale/2), 0, 0.5 * scale / fontsize)
      end
    else
      local title = "Press S to Start!"
      love.graphics.print(title, origin[1] + ((realRes[1] - font:getWidth(title) * scale / fontsize) / 2), origin[2] + ((realRes[2] - scale) / 2), 0, scale / fontsize)
    end
  end)
  love.graphics.print(debug, origin[1], origin[2], 0, scale / fontsize)
  love.graphics.setScissor()
end

function pushMessage(text)
  table.insert(messages, 1, text)
  while #messages > 30 do
    messages[#messages] = nil
  end
end
