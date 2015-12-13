local Class = require 'class'
local Vec2 = require 'vec2'
require 'sprite'
require 'plant'
require 'water'
require 'background'

Game = Class {}

function Game:init()
    self.groundSprites = {}
    for i = 1, 25 do
        local sprite = Sprite(Images:get("ground"))
        sprite.position.x = (i - 13) * sprite:get_width()
        sprite.position.y = love.graphics.getHeight() / 2 - sprite:get_height() / 2
        table.insert(self.groundSprites, sprite)
    end

    self.groundLevel = self.groundSprites[1].position.y - self.groundSprites[1]:get_height() / 2

    self.sunMeter = 3
    self.maxSuns = 6

    self.background = create_background()
    self.background:set_time(9, 0)
end

function Game:start()
    self.plant = Plant()
    self.water = Water()
end

function Game:sun_count()
    return math.floor(self.sunMeter)
end

function Game:mousepressed(x, y, button)
end

function Game:mousereleased(x, y, button)
    if self:sun_count() <= 0 then
        return
    end

    local world = GameCamera:to_world(Vec2(x, y))
    local parent = self.plant:get_closest_branch(world, function(branch) return branch:get_tip().y > world.y end)
    self.plant:add_branch_towards(parent, world)

    self.sunMeter = self.sunMeter - 1
end

function Game:mousemoved(x, y, dx, dy)

end

function Game:update(dt)
    self.background:update(dt)
    self.plant:update(dt, self.water:get_water_level())
    self.water:update(dt)

    local growth = self.plant:get_current_growth()
    self.sunMeter = self.sunMeter + growth * dt
    self.sunMeter = clamp(self.sunMeter, 0, self.maxSuns)

    GameCamera.position.y = math.min(self.water:get_water_level() - 200, 0)
end

function Game:render()
    self.background:render()

    GameCamera:push()

    for _, sprite in ipairs(self.groundSprites) do
        sprite:render()
    end

    self.plant:render()

    local mouseWorld = GameCamera:to_world(Vec2(love.mouse.getPosition()))

    local closest = self.plant:get_closest_branch(mouseWorld, function(branch) return branch:get_tip().y > mouseWorld.y end)
    local tip = self.plant:get_tip(closest)

    love.graphics.setColor(0, 0, 255)
    love.graphics.line(mouseWorld.x, mouseWorld.y, tip.x, tip.y)

    local angle = math.deg(math.atan2(tip.y - mouseWorld.y, tip.x - mouseWorld.x)) - 90
    love.graphics.setColor(255, 0, 0)
    local nx = math.cos(math.rad(angle - 90)) * self.plant.branchLength + tip.x
    local ny = math.sin(math.rad(angle - 90)) * self.plant.branchLength + tip.y

    love.graphics.line(tip.x, tip.y, nx, ny)

    self.water:render()

    GameCamera:pop()

    self:render_hud()
end

function Game:render_hud()
    local x = 5
    local y = 5
    local r = 2
    local scale = 100
    local height = 25

    love.graphics.setColor(63, 63, 63)
    love.graphics.rectangle("fill", x, y, self.maxSuns * scale + r * 2, height + r * 2)

    love.graphics.setColor(200, 200, 0)
    love.graphics.rectangle("fill", x + r, y + r, self.sunMeter * scale, height)

    love.graphics.setColor(255, 255, 200)
    for i = 1, self.maxSuns - 1 do
        love.graphics.line(i * scale + x + r, y + r, i * scale + x + r, y + r + height)
    end
end

function Game:render_debug()
end