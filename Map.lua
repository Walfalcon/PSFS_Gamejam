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
    for n = 1, #line do
      table.insert(mapp.tiles, line:sub(n, n))
    end
  end

  return mapp
end

function Map:draw()
  if not self.active then
    return
  end
  for index, tile in pairs(self.tiles) do
    if tile == '#' then
      local x = ((((index - 1) % Map.width) + self.y - camera[1]) * scale) + origin[1]
      local y = ((math.floor((index - 1) / Map.width) + self.y - camera[2]) * scale) + origin[2]

      love.graphics.rectangle("fill", x, y, scale, scale)
    end
  end
end
