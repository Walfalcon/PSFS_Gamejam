Map = {}
Map.__index = Map
Map.width = 24

function Map:create(path)
  local mapp = {}
  setmetatable(mapp, Map)
  mapp.x = (#maps % mapWidth) * Map.width
  mapp.y = math.floor(#maps / mapWidth) * Map.width
  mapp.tiles = {}
  mapp.active = false
  for line in love.filesystem.lines(path) do
    for n = 1, Map.width do
      local type = line:sub(n, n)
      local x = #mapp.tiles % Map.width + mapp.x
      local y = math.floor(#mapp.tiles / Map.width) + mapp.y
      if type == " " then
        weight = math.huge
      elseif type == "#" then
        weight = -1
      elseif type == "a" then
        Enemy.load(x, y, "a")
        type = " "
        weight = math.huge
      elseif type == "@" then
        Player.x = x
        Player.y = y
        type = " "
        weight = math.huge
      end
      if n > #line then
        type = " "
        weight = math.huge
      end
      local tile = {}
      tile.type = type
      tile.weight = weight
      table.insert(mapp.tiles, tile)
    end
  end
  return mapp
end

function Map:draw()
  if not self.active then
    return
  end
  for index, tile in pairs(self.tiles) do
    local x = ((((index - 1) % Map.width) + self.x - camera[1]) * scale) + origin[1]
    local y = ((math.floor((index - 1) / Map.width) + self.y - camera[2]) * scale) + origin[2]
    if tile.type == "#" then
      love.graphics.rectangle("fill", x, y, scale, scale)
    else
      love.graphics.setColor(0.2, 0.2, 0.2)
      love.graphics.rectangle("line", x, y, scale, scale)
      love.graphics.setColor(1, 1, 1)
    end
    if showNodeMap then
      love.graphics.print(tile.weight, x, y, 0, 0.5)
    end
  end
end
