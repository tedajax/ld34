local Class = require 'class'
local Vec2 = require 'vec2'

Sprite = Class {}

function Sprite:init(image, position, rotation, scale, origin, color)
    assert(image, "Cannot create sprite with nil image.")

    self.image = image
    self.position = position or Vec2.zero()
    self.rotation = rotation or 0
    self.scale = scale or Vec2.one()
    self.origin = origin or Vec2(image:getWidth() / 2, image:getHeight() / 2)
    self.color = color or { 255, 255, 255, 255 }
end

function Sprite:get_width()
    return self.image:getWidth() * self.scale.x
end

function Sprite:get_height()
    return self.image:getHeight() * self.scale.y
end

function Sprite:get_dimensions()
    return self:get_width(), self:get_height()
end

function Sprite:render(nudge)
    local nudge = nudge or Vec2(0, 0)
    love.graphics.setColor(unpack(self.color))
    love.graphics.draw(self.image,
        self.position.x + nudge.x, self.position.y + nudge.y,
        self.rotation,
        self.scale.x, self.scale.y,
        self.origin.x, self.origin.y)
end