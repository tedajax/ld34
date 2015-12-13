local Class = require 'class'
local Vec2 = require 'vec2'
require 'sprite'

Water = Class {}

function Water:init()
    self.tileCountX = 25
    self.tileCountY = 4

    self.tiles = {}

    for y = self.tileCountY, 1, -1 do
        local image = Images:get("water")
        if y == 1 then
            image = Images:get("water_top")
        end

        for x = 1, self.tileCountX do
            local tile = Sprite(image, Vec2((x - 13) * image:getWidth(), y * image:getHeight()))
            tile.color = { 255, 255, 255, 127 }
            table.insert(self.tiles, tile)
        end
    end

    self.level = 0
    self.offset = 500
end

function Water:update(dt)
    self.level = self.level + 25 * dt

    for _, tile in ipairs(self.tiles) do
        tile.position.x = tile.position.x + 20 * dt
        if tile.position.x > (self.tileCountX - 13) * tile:get_width() then
            tile.position.x = tile.position.x - self.tileCountX * tile:get_width()
        end
    end
end

function Water:get_water_level()
    return -self.level + self.offset
end

function Water:render()
    for _, tile in ipairs(self.tiles) do
        tile:render(Vec2(0, self:get_water_level()))
    end
end