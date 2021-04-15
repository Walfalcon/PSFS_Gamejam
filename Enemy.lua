Enemy = {}
Enemy.enemies = {}
Enemy.enemyQueue = {}

function Enemy.load(x, y, type)
  local enemy = {}
  enemy.moveclock = 0
  enemy.symbol = type
  enemy.x = x
  enemy.y = y
  enemy.currentMap = math.floor(enemy.x / Map.width) + math.floor(enemy.y / Map.width) * mapWidth + 1
  if type == "a" then
    enemy.hp = 3
    enemy.speed = 1
    enemy.damage = 1
  else
    enemy.hp = 3
    enemy.speed = 1
    enemy.damage = 1
  end
  table.insert(Enemy.enemies, enemy)
end

function Enemy.move(enemy)
  if not maps[currentMap].active then
    return true
  end
  local nodeX = enemy.x - maps[enemy.currentMap].x
  local nodeY = enemy.y - maps[enemy.currentMap].y
  local currentNode = maps[enemy.currentMap].tiles[nodeX + nodeY * Map.width + 1]
  if currentNode.weight == math.huge then
    return true
  end
  local nextWeight = currentNode.weight
  local nextNode = {nodeX, nodeY}
  local nextMap = enemy.currentMap
  for tilen, nextTile in pairs({{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}}) do
    local checkWeight, checkNode, checkMap = Enemy.checkNode(nodeX + nextTile[1], nodeY + nextTile[2], enemy.currentMap)
    if checkWeight == 0 then
      nextNode = {nodeX, nodeY}
      Player.damage(enemy.damage)
      return true
    elseif checkWeight ~= -1 and checkWeight < nextWeight then
      local isBlocked = false
      for enemyn, otherEnemy in pairs(Enemy.enemies) do
        if otherEnemy.hp > 0 and otherEnemy.x == enemy.x + nextTile[1] and otherEnemy.y == enemy.y + nextTile[2] then
          isBlocked = true
          break
        end
      end
      if not isBlocked then
        nextNode = checkNode
        nextMap = checkMap
        nextWeight = checkWeight
      end
    end
  end
  if nextNode[1] ~= nodeX or nextNode[2] ~= nodeY then
    enemy.currentMap = nextMap
    enemy.x = nextNode[1] + maps[enemy.currentMap].x
    enemy.y = nextNode[2] + maps[enemy.currentMap].y
    return true
  end
  return false
end

function Enemy.checkNode(x, y, map)
  if x < 0 then
    if map % mapWidth == 1 then
      return -1, nil, nil
    end
    map = map - 1
    x = x % Map.width
  end
  if x >= Map.width then
    if map % mapWidth == 0 then
      return -1, nil, nil
    end
    map = map + 1
    x = x % Map.width
  end
  if y < 0 then
    if math.floor(map / mapWidth) <= 0 then
      return -1, nil, nil
    end
    map = map - mapWidth
    y = y % Map.width
  end
  if y >= Map.width then
    if math.ceil(map / mapWidth) >= mapWidth then
      return -1, nil, nil
    end
    map = map + mapWidth
    y = y % Map.width
  end
  local node = maps[map].tiles[x + y * Map.width + 1]
  return node.weight, {x, y}, map
end

function Enemy.createQueue()
  for index, enemy in pairs(Enemy.enemyQueue) do
    enemy = nil
  end
  for index, enemy in pairs(Enemy.enemies) do
    if enemy.hp > 0 and maps[enemy.currentMap].active then
      enemy.moveclock = enemy.moveclock + enemy.speed
      table.insert(Enemy.enemyQueue, enemy)
    end
  end
end

function Enemy.draw(enemy)
  local x = (enemy.x - camera[1]) * scale
  local y = (enemy.y - camera[2]) * scale
  if enemy.hp <= 0 then
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", x, y, scale, scale)
    love.graphics.setColor(1, 1, 1)
    return
  end
  love.graphics.print(enemy.symbol, x, y, 0, scale / fontsize)
end

function Enemy.damage(enemy, value)
  enemy.hp = enemy.hp - value
  if enemy.hp <= 0 then
     pushMessage(enemy.symbol .. " died!")
  end
end
