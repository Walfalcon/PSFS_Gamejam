Player = {}
Player.x = 3
Player.y = 3

function Player.load()
  Player.sprite = love.graphics.newImage("Assets/statue face.bmp")
  local width = Player.sprite:getDimensions()
  Player.scale = scale / width
  currentMap = math.floor(Player.x / Map.width) + math.floor(Player.y / Map.width) * mapWidth + 1
  for index, map in pairs(maps) do
    if index == currentMap or index == currentMap - mapWidth or index == currentMap + mapWidth or (index == currentMap - 1 and currentMap % mapWidth ~= 1) or (index == currentMap + 1 and currentMap % mapWidth ~= 0) then
      map.active = true
    else
      map.active = false
    end
  end
end

function Player.draw()
  local x = (Player.x - camera[1]) * scale + origin[1]
  local y = (Player.y - camera[2]) * scale + origin[2]
  love.graphics.draw(Player.sprite, x, y, 0, Player.scale)
end

function Player.update(input)
  local dx = 0
  local dy = 0
  if input == "wait" then
    return
  elseif input == "ul" then
    dx = -1
    dy = -1
  elseif input == "u" then
    dy = -1
  elseif input == "ur" then
    dx = 1
    dy = -1
  elseif input == "l" then
    dx = -1
  elseif input == "r" then
    dx = 1
  elseif input == "dl" then
    dx = -1
    dy = 1
  elseif input == "d" then
    dy = 1
  elseif input == "dr" then
    dx = 1
    dy = 1
  end

  local mapX = Player.x - maps[currentMap].x
  local mapY = Player.y - maps[currentMap].y

  if dx ~= 0 and mapX + dx < Map.width and mapX + dx > 0 and maps[currentMap].tiles[mapX + dx + (mapY * Map.width) + 1] == "#" then
    dx = 0
  end
  if dy ~= 0 and mapY + dy < Map.width and mapY + dy > 0 and maps[currentMap].tiles[mapX + ((mapY + dy) * Map.width) + 1] == "#" then
    dy = 0
  end
  if mapX + dx < Map.width and mapX + dx > 0 and mapY + dy < Map.width and mapY + dy > 0 and maps[currentMap].tiles[mapX + dx + ((mapY + dy) * Map.width) + 1] == "#" then
    dx = 0
    dy = 0
  end
  Player.x = Player.x + dx
  Player.y = Player.y + dy
  currentMap = math.floor(Player.x / Map.width) + math.floor(Player.y / Map.width) * mapWidth + 1
end
