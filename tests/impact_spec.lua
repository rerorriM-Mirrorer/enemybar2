-- A: deterministic Lua 5.1 checks for impact timing and overlay ownership.
package.path='./?.lua;'..package.path
local settings=require('animationSettings')
local motion=require('healthMotion')
local ghost_motion=require('ghostMotion')
local function close(a,b) assert(math.abs(a-b)<1e-7,tostring(a)..' ~= '..tostring(b)) end
local now=0
local function options(extra)
    local o=settings.snapshot(extra or {})
    o.hit_shake=true;o.ghost_hit=true;o.text_effect=true;o.healing_effect=true
    o.low_hp_pulse=true;o.super_settle='both'
    return o
end
local function start(o,loss,direction)
    now=0;o.direction=function() return direction or 1 end
    local m=motion.new(o,function() return now end)
    m:update(1,true);m:update(1-loss,false)
    return m
end
for _,direction in ipairs({1,-1}) do
    local m=start(options(),.8,direction)
    for _,p in ipairs({{0,8},{.049,8},{.05,-4},{.07,-4},{.05+1/30,2},
        {.05+2/30,-1},{.15,0},{.5,0}}) do
        now=p[1];close(m:sample().offset,p[2]*direction)
    end
end
local o=options({shake_super_px=12,shake_rebound=.5,shake_decay=.5,shake_horizontal=.5})
local m=start(o,.8);now=.05
assert(m:sample().offset==-6 and m:sample().offset_x==-3)
for settle,count in pairs({off=2,small=3,both=4}) do
    o=options();o.super_settle=settle;m=start(o,.8)
    now=.05+(count-1)/30;assert(m:sample().offset==0)
end
for _,loss in ipairs({.1,.25,.5}) do
    m=start(options(),loss);assert(m:sample().offset==1)
    now=.07;assert(m:sample().offset==-1)
end
m=start(options(),.6);assert(m:sample().offset==4)
now=.07;assert(m:sample().offset==-2)
-- New damage restarts immediately; healing and target reassignment cancel it.
m=start(options(),.8);now=.07;m:update(.1,false);assert(m:sample().offset==1)
m:update(.2,false);assert(m:sample().offset==0 and m:sample().healing)
m:update(.9,true);assert(m:sample().offset==0)
o=options();o.hit_shake=false;m=start(o,.8);assert(m:sample().offset==0)
o=options({shake_style='classic'});m=start(o,.8)
now=.025;assert(m:sample().offset==6)
now=.075;assert(m:sample().offset==-8)
now=.14;assert(m:sample().offset==3)
-- Contact survives the flicker minimum; lift starts only after it ends.
o=settings.snapshot({ghost_contact_duration=.08,ghost_period=.1})
local p=ghost_motion.sample(o,.05)
assert(p.contact and p.alpha==1 and p.x==0 and p.y==0 and p.glow==1)
p=ghost_motion.sample(o,.08);close(p.y,0)
p=ghost_motion.sample(o,.13);close(p.alpha,0)
p=ghost_motion.sample(o,.28);close(p.y,-o.ghost_lift_up)
p=ghost_motion.sample(o,.48);close(p.glow,0)
assert(ghost_motion.sample(o,ghost_motion.duration(o)).done)
o=settings.snapshot({ghost_contact_duration=0,ghost_lift_duration=0,ghost_hover_duration=0,
    ghost_fade_duration=.01,ghost_period=0,ghost_glow=false})
assert(not o.ghost_glow)
assert(ghost_motion.sample(o,.01).done)
local copy=settings.snapshot({ghost_glow_color={red=1,green=2,blue=3}})
local frozen=settings.snapshot(copy);copy.ghost_glow_color.red=99
assert(frozen.ghost_glow_color.red==1)
assert(not settings.valid('ghost_glow_alpha','1.5'))
assert(not settings.valid('shake_step','0'))
assert(not settings.valid('shake_super_px','nan'))

-- Render mocks retain actual geometry/color; only Windower's drawing is stubbed.
local all={}
package.loaded.images={new=function(config)
    local p={config=config,_x=0,_y=0,_w=1,_h=1,_alpha=config.color.alpha,
        _color={config.color.red,config.color.green,config.color.blue},_visible=false}
    function p:pos(x,y) self._x,self._y=x,y end
    function p:size(w,h) self._w,self._h=w,h end
    function p:width() return self._w end
    function p:color(r,g,b) self._color={r,g,b} end
    function p:alpha(a) self._alpha=a end
    function p:visible(v) self._visible=v end
    function p:destroy() assert(not self.dead,'double destroy');self.dead=true;self._visible=false end
    all[#all+1]=p;return p
end}
windower={addon_path='./'}
local gauge=require('ffxiGauge')
o=options({ghost_contact_duration=.08,ghost_glow_color={red=240,green=76,blue=100},
    shake_horizontal=.5,ghost_lift_duration=.2,ghost_hover_duration=.3,ghost_fade_duration=1})
now=0
local g=gauge.new(400,{alpha=255,red=255,green=149,blue=151},{animation_duration=.18,
    damage_trail=true,ghost_hit=true,ghost_options=o,effects=o,clock=function() return now end})
g:move(100,100);g:set_value(1,true);g:show()
local base_count=#all
g:set_value(.2,false)
assert(#all==base_count+6)
local glow,left,right=all[base_count+1],all[base_count+2],all[base_count+3]
local chunk_left,chunk_right=all[base_count+4],all[base_count+6]
assert(glow._visible and left._visible and right._visible)
assert(chunk_left._alpha==255 and chunk_left._color[1]==255)
close(left._x+left._w/2,chunk_left._x)
close(right._x+right._w/2,chunk_right._x+chunk_right._w)
assert(g.trough[1]._y==108 and g.trough[1]._x==104)
assert(g.trail[1]._y==101 and g.trail[1]._x==106)
assert(g.fill[1]._y==109 and g.fill[1]._x==110)
local frozen_x=chunk_left._x
g:set_value(.8,true);g:move(500,500);g:hide();g:destroy()
o.ghost_glow_color.red=1
now=.04;gauge.update_ghosts()
assert(chunk_left._x==frozen_x and chunk_left._alpha==255 and glow._color[1]==240)
now=.6;gauge.update_ghosts();assert(not glow._visible and not left._visible)
now=2;gauge.update_ghosts()
for _,p in ipairs(all) do assert(p.dead) end
gauge.clear_ghosts() -- expiry removed ownership: no double destruction
-- Explicit false creates no glow primitives; scene cleanup includes every part.
now=0;o=options({ghost_glow=false})
local previous_count=#all
g=gauge.new(100,{alpha=128,red=1,green=2,blue=3},{animation_duration=.18,
    ghost_hit=true,ghost_options=o,clock=function() return now end})
g:set_value(1,true);g:show();g:set_value(.2,false)
assert(#all==previous_count+9)
gauge.clear_ghosts();g:destroy()
for _,p in ipairs(all) do assert(p.dead) end
-- Zero-duration contact/glow/lift/hover reaches fade without division by zero.
o=options({ghost_contact_duration=0,ghost_glow_duration=0,ghost_lift_duration=0,ghost_hover_duration=0})
now=0;g=gauge.new(100,{alpha=255,red=1,green=2,blue=3},{animation_duration=.18,
    ghost_hit=true,ghost_options=o,clock=function() return now end})
g:set_value(1,true);g:show();g:set_value(0,false)
assert(not all[#all-5]._visible)
gauge.clear_ghosts();g:destroy()
for _,p in ipairs(all) do assert(p.dead) end
print('impact_spec: timing, interruptions, geometry, snapshots and cleanup passed')
