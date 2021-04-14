local moonshine = require 'moonshine'
require 'Map'
require 'Player'

resolution = {16, 15}
realRes = {256, 240}
scale = 1
origin = {0, 0}
camera = {0, 0}
maps = {}
mapWidth = 2
debug = ""

enemies = {}
currentMap = 1

function love.load()
  love.window.setMode(resolution[1], resolution[2], {fullscreen = true})
  local width, height = love.window.getMode()
  realRes[2] = height
  realRes[1] = resolution[1] * height / resolution[2]
  scale = realRes[2] / resolution[2]
  origin[1] = (width / 2) - (realRes[1] / 2)

  table.insert(maps, Map:create("Map1"))
  table.insert(maps, Map:create("Map2"))
  table.insert(maps, Map:create("Map2"))
  table.insert(maps, Map:create("Map2"))

  Player.load()

  love.graphics.setScissor(origin[1], origin[2], realRes[1], realRes[2])
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setColor(1, 1, 1)

  effect = moonshine(moonshine.effects.glow)
                    .chain(moonshine.effects.vignette)
                    .chain(moonshine.effects.crt)
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
  end
  if input then
    Player.update(input)
    for index, enemy in pairs(enemies) do

    end
    for index, map in pairs(maps) do
      if index == currentMap or index == currentMap - mapWidth or index == currentMap + mapWidth or (index == currentMap - 1 and currentMap % mapWidth ~= 1) or (index == currentMap + 1 and currentMap % mapWidth ~= 0) then
        map.active = true
      else
        map.active = false
      end
    end
  end
end

function love.draw()
  effect(function()
    for index, map in pairs(maps) do
      map:draw()
    end
    Player.draw()
  end)
  love.graphics.print(debug, origin[1], origin[2], 0, scale / 16)
end
