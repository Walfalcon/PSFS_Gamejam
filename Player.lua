Player = {}

function Player.load()
  Player.x = 3
  Player.y = 3
  Player.weaponDamage = {1, 4}
  currentMap = math.floor(Player.x / Map.width) + math.floor(Player.y / Map.width) * mapWidth + 1
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

function Player.draw()
  local x = (Player.x - camera[1]) * scale
  local y = (Player.y - camera[2]) * scale
  love.graphics.print("@", x, y, 0, scale / fontsize)
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
  local hitWall = false

  if dx ~= 0 and mapX + dx < Map.width and mapX + dx >= 0 and maps[currentMap].tiles[mapX + dx + (mapY * Map.width) + 1].weight == -1 then
    dx = 0
    if dy == 0 then
      hitWall = true
    end
  end
  if dy ~= 0 and mapY + dy < Map.width and mapY + dy >= 0 and maps[currentMap].tiles[mapX + ((mapY + dy) * Map.width) + 1].weight == -1 then
    dy = 0
    if dx == 0 then
      hitWall = true
    end
  end
  if mapX + dx < Map.width and mapX + dx >= 0 and mapY + dy < Map.width and mapY + dy >= 0 and maps[currentMap].tiles[mapX + dx + ((mapY + dy) * Map.width) + 1].weight == -1 then
    dx = 0
    dy = 0
    hitWall = true
  end

  if hitWall then
     pushMessage("It's a wall.")
  else
    for index, enemy in pairs(Enemy.enemies) do
      if (enemy.hp > 0 and enemy.x == Player.x + dx and enemy.y == Player.y + dy) or
        (enemy.hp > 0 and enemy.x == Player.x + dx and enemy.y == Player.y) or
        (enemy.hp > 0 and enemy.x == Player.x and enemy.y == Player.y + dy) then
        Player.attack(enemy)
        return
      end
    end
    Player.x = Player.x + dx
    Player.y = Player.y + dy
    currentMap = math.floor(Player.x / Map.width) + math.floor(Player.y / Map.width) * mapWidth + 1
    updatePath()

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
end

function updatePath()
  for mapi, map in pairs(maps) do
    if map.active then
      for tilei, tile in pairs(map.tiles) do
        if tile.weight ~= -1 then
          tile.weight = math.huge
        end
      end
    end
  end
  local nodeX = Player.x - maps[currentMap].x
  local nodeY = Player.y - maps[currentMap].y
  local currentNode = maps[currentMap].tiles[nodeX + nodeY * Map.width + 1]
  currentNode.weight = 0
  for index, nextTile in pairs({{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}}) do
    checkNode(nodeX + nextTile[1], nodeY + nextTile[2], currentMap, 1)
  end
end

function checkNode(x, y, map, weight)
  if x < 0 then
    if map % mapWidth == 1 then
      return
    end
    map = map - 1
    x = x % Map.width
  end
  if x >= Map.width then
    if map % mapWidth == 0 then
      return
    end
    map = map + 1
    x = x % Map.width
  end
  if y < 0 then
    if math.floor(map / mapWidth) <= 0 then
      return
    end
    map = map - mapWidth
    y = y % Map.width
  end
  if y >= Map.width then
    if math.ceil(map / mapWidth) >= mapWidth then
      return
    end
    map = map + mapWidth
    y = y % Map.width
  end
  local currentNode = maps[map].tiles[x + y * Map.width + 1]
  if weight < currentNode.weight then
    currentNode.weight = weight
    if weight >= pathfindDist then
      return
    end
    for index, nextTile in pairs({{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}}) do
      checkNode(x + nextTile[1], y + nextTile[2], map, weight + 1)
    end
  end
end

function Player.attack(enemy)
  local damage = 0
  for i = 1, Player.weaponDamage[1] do
    damage = damage + math.random(Player.weaponDamage[2])
  end
  pushMessage("You hit " .. enemy.symbol .. " with " .. Player.weaponDamage[1] .. "d" .. Player.weaponDamage[2] .. " for " .. damage .. "!")
  Enemy.damage(enemy, damage)
end

function Player.damage(val)
   pushMessage("You took " .. val .. " damage!")
end
