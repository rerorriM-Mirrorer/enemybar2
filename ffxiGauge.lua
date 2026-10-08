-- Awake: native menu/gauge slices, with separate trough and fill pieces.
-- Only the centers stretch; combat identity stays in bars.lua.
local images = require('images')
local health_motion = require('healthMotion')
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

function gauge.new(width, color, options)
    options = options or {}
    local self = setmetatable({
        width=math.max(16, width+2), x=0, y=0, value=1, visible=false,
        duration=options.animation_duration or 0,
        clock=options.clock or os.clock, target_value=1,
        slide_duration=options.animation_duration or 0, color=color,
        damage_trail=options.damage_trail or false, trail_value=1,
        trail_delay=options.trail_delay or 1.5, trail_duration=options.trail_duration or .45,
    }, methods)
    if options.effects then self.motion=health_motion.new(options.effects,self.clock) end
    -- The shell is deliberately neutral, independent of the resource tint.
    local shell = {alpha=color.alpha, red=255, green=255, blue=255}
    self.trough = {
        image('trough_left', shell), image('trough_mid', {
            alpha=math.floor((color.alpha or 255)*(options.background_alpha or 128)/255+0.5),
            red=255, green=255, blue=255}),
        image('trough_right', shell),
    }
    if self.damage_trail or self.motion then
        local red = options.trail_color or {red=167,green=57,blue=96,alpha=128}
        local tint = {red=red.red,green=red.green,blue=red.blue,
            alpha=math.floor((color.alpha or 255)*(red.alpha or 128)/255+.5)}
        self.trail_color=tint
        -- Created before the foreground so the current HP covers the trail.
        self.trail = {image('fill_left',tint),image('fill_mid',tint),image('fill_right',tint)}
    end
    self.fill = {
        image('fill_left', color), image('fill_mid', color),
        image('fill_right', color),
    }
    self:move(0, 0)
    return self
end

function methods:move(x, y)
    self.x, self.y = x, y
    self.feedback=self.motion and self.motion:sample() or nil
    local shake=self.feedback and self.feedback.offset or 0
    self.trough[1]:pos(x, y+shake)
    self.trough[1]:size(6, 12)
    self.trough[2]:pos(x+6, y+shake)
    self.trough[2]:size(self.width-12, 12)
    self.trough[3]:pos(x+self.width-6, y+shake)
    self.trough[3]:size(6, 12)
    self:layout_fill()
end

function methods:advance()
    local now = self.clock()
    if self.started_at then
        local progress = math.min(1, math.max(0, (now-self.started_at)/self.slide_duration))
        self.value = self.start_value+(self.target_value-self.start_value)*progress
        if progress == 1 then self.started_at = nil end
    end
    if self.trail_at and now >= self.trail_at then
        local progress = self.trail_duration <= 0 and 1 or math.min(1,(now-self.trail_at)/self.trail_duration)
        self.trail_value = self.trail_start+(self.target_value-self.trail_start)*progress
        if progress == 1 then self.trail_at = nil end
    end
end

function methods:set_value(value, immediate)
    value = math.max(0, math.min(1, value))
    self:advance()
    if self.motion then self.motion:update(value,immediate or self.duration<=0) end
    if immediate or self.duration <= 0 then
        self.value, self.target_value, self.started_at = value, value, nil
        self.trail_value, self.trail_at = value, nil
    elseif self.damage_trail and value < self.target_value then
        -- A hit freezes a moving trail at its current edge and restarts the hold.
        self.trail_value = math.max(self.trail_value,self.value,value)
        self.trail_start, self.trail_at = self.trail_value, self.clock()+self.trail_delay
        self.value, self.target_value, self.started_at = value, value, nil
    elseif self.target_value ~= value then
        self:advance()
        self.start_value, self.started_at, self.target_value = self.value, self.clock(), value
        self.slide_duration=self.motion and self.motion.heal_at and self.motion.heal_duration or self.duration
        if self.slide_duration<=0 then self.value,self.started_at=value,nil end
        self.trail_value, self.trail_at = value, nil
    else
        self:advance()
    end
    self:move(self.x,self.y)
end

function methods:layout_parts(parts, value, offset)
    local filled = (self.width-12)*value
    -- A nearly empty bar must not retain two full-width caps or overfill.
    local cap = math.min(3, filled/2)
    parts[1]:pos(self.x+6, self.y+1+(offset or 0))
    parts[1]:size(cap, 9)
    parts[2]:pos(self.x+6+cap, self.y+1+(offset or 0))
    parts[2]:size(math.max(0, filled-2*cap), 9)
    parts[3]:pos(self.x+6+filled-cap, self.y+1+(offset or 0))
    parts[3]:size(cap, 9)
end

function methods:layout_fill()
    if self.trail then self:layout_parts(self.trail,self.trail_value) end
    self:layout_parts(self.fill,self.value,self.feedback and self.feedback.offset or 0)
    if self.feedback then
        local fill=health_motion.mix(self.color,{red=255,green=255,blue=255},self.feedback.white)
        for _,p in ipairs(self.fill) do
            p:color(fill.red,fill.green,fill.blue)
            p:alpha(math.floor((self.color.alpha or 255)*self.feedback.alpha+.5))
        end
        local trail=self.feedback.healing and {red=209,green=224,blue=151} or
            health_motion.mix(self.trail_color,{red=224,green=86,blue=130},self.feedback.pulse)
        for _,p in ipairs(self.trail) do
            p:color(trail.red,trail.green,trail.blue)
            p:alpha(self.trail_color.alpha)
        end
    end
    self:refresh_visibility()
end

function methods:refresh_visibility()
    for _, part in ipairs(self.trough) do
        part:visible(self.visible and part:width() > 0)
    end
    for _, part in ipairs(self.fill) do
        part:visible(self.visible and part:width() > 0 and self.value > 0)
    end
    for _, part in ipairs(self.trail or {}) do
        part:visible(self.visible and part:width()>0 and (self.trail_value>self.value or
            (self.feedback~=nil and self.feedback.low)))
    end
end

function methods:show()
    self.visible = true
    self:advance()
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
    for _, part in ipairs(self.trail or {}) do part:destroy() end
end

return gauge
