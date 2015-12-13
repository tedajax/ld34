local Class = require 'class'
local Vec2 = require 'vec2'
require 'util'

Flower = Class {}

function Flower:init(branch)
    self.branch = branch
    self.growth = 0
    self.growthDelay = 2
    self.growthRate = 0.25
    self.isFallen = false
    self.position = Vec2.zero()
    self.velocity = Vec2.zero()
end

function Flower:update(dt)
    if self.isFallen then
        self.velocity.y = self.velocity.y + 750 * dt
        self.position = self.position + self.velocity * dt
        if self.position.y > GrowthGame.groundLevel then
            self.position.y = GrowthGame.groundLevel
            self.velocity.y = 0
        end
    else
        if self.growthDelay > 0 then
            self.growthDelay = self.growthDelay - dt
        else
            self.growth = self.growth + self.growthRate * dt
            if self.growth > 1 then
                self:fall()
            end
            self.position = self.branch:get_tip()
        end
    end
end

function Flower:render()
    if self.growth > 0 then
        local flower = Images:get("flower")
        local scale = self.growth
        love.graphics.draw(flower, self.position.x, self.position.y, 0, scale, scale, flower:getWidth() / 2, flower:getHeight() / 2)
    end
end

function Flower:fall()
    self.isFallen = true
    self.branch:try_create_flower()
end

Branch = Class {}

function Branch:init(plant, parent, angle)
    self.plant = plant
    self.parent = parent
    self.angle = angle
    self.currentLength = 0
    self.isDead = false
    self.growthRate = 50
    self:try_create_flower()
end

function Branch:get_tip()
    return self.plant:get_tip(self)
end

function Branch:try_create_flower()
    if self.isDead then
        self.flower = nil
        return
    end

    self.flower = Flower(self)
    self.plant:add_flower(self.flower)
end

function Branch:die()
    self.isDead = true
    if self.flower then
        self.flower:fall()
    end
end

function Branch:update(dt, baseLength)
    local targetLength = baseLength

    if self.currentLength < targetLength then
        self.currentLength = self.currentLength + self.growthRate * dt
        self.currentLength = clamp(self.currentLength, 0, targetLength)
    elseif self.currentLength > targetLength then
        self.currentLength = self.currentLength - self.growthRate * dt
        self.currentLength = clamp(self.currentLength, targetLength, math.huge)
    end
end

function Branch:get_length()
    return self.currentLength
end

Plant = Class {}

function Plant:init()
    self.branchLength = 100

    self.root = Vec2(0, GrowthGame.groundLevel)

    self.branches = {}
    self.flowers = {}

    local rootBranch = Branch(self, nil, 0)
    rootBranch.currentLength = self.branchLength
    table.insert(self.branches, rootBranch)
end

function Plant:add_flower(flower)
    table.insert(self.flowers, flower)
end

function Plant:add_branch(parent, angle)
    assert(parent, "parent cannot be nil")
    parent:die()
    local branch = Branch(self, parent, angle)
    table.insert(self.branches, branch)
    return branch
end

function Plant:add_branch_towards(parent, position)
    local tip = self:get_tip(parent)
    local angle = math.deg(math.atan2(tip.y - position.y, tip.x - position.x)) - 90
    return self:add_branch(parent, angle)
end

function Plant:get_closest_branch(position, condition)
    local closest = nil
    local minDist = math.huge
    for _, branch in ipairs(self.branches) do
        local tip = self:get_tip(branch)
        local dist = Vec2.dist(position, tip)
        local conditionResult = true
        if type(condition) == "function" then
            conditionResult = condition(branch)
        end
        if dist < minDist and conditionResult then
            closest = branch
            minDist = dist
        end
    end

    return closest
end

function Plant:get_base(branch)
    if branch.parent == nil then
        return self.root
    else
        return self:get_tip(branch.parent)
    end
end

function Plant:get_tip(branch)
    if branch == nil then
        return self.root
    end

    local rads = math.rad(branch.angle - 90)

    local length = branch:get_length()

    local x = math.cos(rads) * length
    local y = math.sin(rads) * length

    return Vec2(x, y) + self:get_tip(branch.parent)
end

function Plant:get_current_growth()
    local sum = 0
    for _, flower in ipairs(self.flowers) do
        if not flower.isFallen and flower.growthDelay <= 0 then
            sum = sum + flower.growthRate
        end
    end
    return math.max(sum, 0.1)
end

function Plant:update(dt, water)
    for _, branch in ipairs(self.branches) do
        branch:update(dt, self.branchLength)

        if not self.isDead and self:get_tip(branch).y > water then
            branch:die()
        end
    end

    for _, flower in ipairs(self.flowers) do
        flower:update(dt)
    end
end

function Plant:render()
    love.graphics.setColor(0, 255, 0)

    for _, branch in ipairs(self.branches) do
        local base = self:get_base(branch)
        local tip = self:get_tip(branch)

        if branch.isDead then
            love.graphics.setColor(153, 76, 0)
        else
            love.graphics.setColor(0, 255, 0)
        end

        love.graphics.line(base.x, base.y, tip.x, tip.y)
    end

    love.graphics.setColor(255, 255, 255)
    for _, flower in ipairs(self.flowers) do
        flower:render()
    end
end