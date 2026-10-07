-- Awake: native menu/gauge slices, with separate trough and fill pieces.
-- Only the centers stretch. No combat or animation state here.
local images = require('images')
local gauge = {}
local methods = {}
methods.__index = methods

local function image(name, color)
    return images.new({
        pos = {x=0, y=0}, visible = false,
        size = {width=1, height=1},
        color = {alpha=color.alpha or 255, red=color.red,
                 green=color.green, blue=color.blue},
        texture = {path=windower.addon_path..'assets/ffxi/'..name..'.png', fit=true},
        repeatable = {x=1, y=1}, draggable = false,
    })
end

function gauge.new(width, color)
    local self = setmetatable({
        width=math.max(16, width+2), x=0, y=0, value=1, visible=false,
    }, methods)
    -- The shell is deliberately neutral, independent of the resource tint.
    local shell = {alpha=color.alpha, red=255, green=255, blue=255}
    self.trough = {
        image('trough_left', shell), image('trough_mid', shell),
        image('trough_right', shell),
    }
    self.fill = {
        image('fill_left', color), image('fill_mid', color),
        image('fill_right', color),
    }
    self:move(0, 0)
    return self
end

function methods:move(x, y)
    self.x, self.y = x, y
    self.trough[1]:pos(x, y)
    self.trough[1]:size(6, 12)
    self.trough[2]:pos(x+6, y)
    self.trough[2]:size(self.width-12, 12)
    self.trough[3]:pos(x+self.width-6, y)
    self.trough[3]:size(6, 12)
    self:layout_fill()
end

function methods:set_value(value)
    value = math.max(0, math.min(1, value))
    if self.value == value then return end
    self.value = value
    self:layout_fill()
end

function methods:layout_fill()
    local filled = (self.width-12)*self.value
    -- A nearly empty bar must not retain two full-width caps or overfill.
    local cap = math.min(3, filled/2)
    self.fill[1]:pos(self.x+6, self.y+1)
    self.fill[1]:size(cap, 9)
    self.fill[2]:pos(self.x+6+cap, self.y+1)
    self.fill[2]:size(math.max(0, filled-2*cap), 9)
    self.fill[3]:pos(self.x+6+filled-cap, self.y+1)
    self.fill[3]:size(cap, 9)
    self:refresh_visibility()
end

function methods:refresh_visibility()
    for _, part in ipairs(self.trough) do
        part:visible(self.visible and part:width() > 0)
    end
    for _, part in ipairs(self.fill) do
        part:visible(self.visible and part:width() > 0 and self.value > 0)
    end
end

function methods:show()
    self.visible = true
    -- Texture loading can restore a primitive's source-image dimensions
    -- after construction. The images library caches our requested sizes,
    -- so width() cannot detect that reset. Reassert all six sizes on draw,
    -- including a stationary, full-HP target; dragging must not be required.
    self:move(self.x, self.y)
end

function methods:hide()
    if not self.visible then return end
    self.visible = false
    self:refresh_visibility()
end

function methods:hover(x, y)
    return self.visible and x >= self.x and x <= self.x+self.width
        and y >= self.y and y <= self.y+12
end

function methods:destroy()
    for _, part in ipairs(self.trough) do part:destroy() end
    for _, part in ipairs(self.fill) do part:destroy() end
end

return gauge
