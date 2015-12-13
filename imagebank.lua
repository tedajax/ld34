local Class = require 'class'

ImageBank = Class {}

function ImageBank:init()
    self.images = {}
end

function ImageBank:load(filename, assetname)
    local assetname = assetname or filename

    if self.images[assetname] == nil then
        self.images[assetname] = love.graphics.newImage(filename)
    end

    return self.images[assetname]
end

function ImageBank:unload(assetname)
    self.images[assetname] = nil
end

function ImageBank:clear()
    self.images = {}
end

function ImageBank:get(assetname)
    return self.images[assetname]
end
