-- A: real motion/renderer with image mocks; no game state or packets needed.
package.path='./?.lua;'..package.path
local all={}
package.loaded.images={new=function(config)
    local p={config=config,_w=1,_h=1,_visible=false}
    function p:pos(x,y) self.x,self.y=x,y end
    function p:size(w,h) self._w,self._h=w,h end
    function p:width() return self._w end
    function p:color(r,g,b) self.rgb={r,g,b} end
    function p:alpha(a) self.a=a end
    function p:visible(v) self._visible=v end
    function p:destroy() assert(not self.dead);self.dead=true end
    all[#all+1]=p;return p
end}
windower={addon_path='./'}
local gauge=require('ffxiGauge')
local settings=require('animationSettings')
local motion=require('healthMotion')
local now=0
local function near(a,b) assert(math.abs(a-b)<1e-7,tostring(a)..' ~= '..tostring(b)) end
local o=settings.snapshot({foreground_period=.1,underbar_period=.1})
o.low_hp_pulse=true;o.hit_shake=true;o.healing_effect=true;o.ghost_hit=true
local g=gauge.new(400,{alpha=255,red=255,green=149,blue=151},{animation_duration=.18,
    damage_trail=true,trail_delay=2,trail_duration=.5,
    trail_color={alpha=200,red=167,green=57,blue=96},effects=o,ghost_options=o,
    ghost_hit=true,clock=function() return now end})
g:move(100,100);g:set_value(1,true);g:show()
assert(not g.trail_glow[1]._visible)
g:set_value(.5,false)
local width=g.width-12
near(g.trail_glow[1]._w,width*.5)
near(g.trail_glow[2].x+g.trail_glow[2]._w/2,106+width*.5)
near(g.trail_glow[3].x+g.trail_glow[3]._w/2,106+width)
assert(g.trail_glow[1]._visible and g.trail_glow[2]._visible)
local function position(p) for i,part in ipairs(all) do if p==part then return i end end end
assert(position(g.trail[1])<position(g.trail_glow[1]))
assert(position(g.trail_glow[1])<position(g.fill[1]))
assert(g.trail_glow[1].rgb[1]>g.active_trail_color.red)
near(g.trail_glow[2].y,101-o.underbar_flare_height)
assert(g.trail_glow[1].a==math.floor(228*80/255+.5))
-- The halo/flare follows shrinking trail width and drag position, never shake.
now=2.25;g:show()
near(g.trail_glow[1]._w,width*.25)
near(g.trail_glow[3].x+g.trail_glow[3]._w/2,106+width*.75)
g:move(300,200)
near(g.trail_glow[2].x+g.trail_glow[2]._w/2,306+width*.5)
near(g.trail_glow[2].y,201-o.underbar_flare_height)
-- Matching pulse phase at 50% and 5% gives the same red, with increasing alpha.
now=3;g:set_value(.5,true);g:show()
for _,p in ipairs(g.trail_glow) do assert(not p._visible) end
local first=g.active_trail_color
g:set_value(.05,true);g:show()
assert(first.red==g.active_trail_color.red and first.green==g.active_trail_color.green)
assert(g.active_trail_alpha==252)
-- Critical foreground alternates real white/normal at constant full opacity.
now=.05;g:show()
assert(g.feedback.white==1 and g.feedback.alpha==1)
assert(g.critical_fill[1]._visible and not g.fill[1]._visible)
assert(g.critical_fill[1].config.color.red==255 and g.critical_fill[1].config.color.green==255)
assert(g.active_trail_color.red==224 and g.active_trail_color.green==86 and g.active_trail_color.blue==130)
now=.11;g:show()
assert(g.feedback.white==0 and g.fill[1]._visible and not g.critical_fill[1]._visible)
g:set_value(.11,true);g:show();assert(not g.feedback.critical)
-- Healing suppresses the red halo; zero/hide/recreate release every image.
g:set_value(.2,false);g:show();assert(g.feedback.healing and not g.trail_glow[1]._visible)
g:set_value(.0001,true);g:show()
assert(g.trail_glow[2]._w<=g.trail_glow[1]._w/2)
g:set_value(0,true);g:show()
for _,p in ipairs(g.trail_glow) do assert(not p._visible) end
g:set_value(.2,true);g:show();g:hide()
for _,p in ipairs(g.trail_glow) do assert(not p._visible) end
g:destroy();gauge.clear_ghosts()
for _,p in ipairs(all) do assert(p.dead) end
-- Toggle avoids allocating the three glow primitives; threshold stays >=75.
o.underbar_glow=false
g=gauge.new(100,{alpha=128,red=1,green=2,blue=3},{animation_duration=.18,
    effects=o,ghost_options=o,ghost_hit=true,clock=function() return now end})
assert(not g.trail_glow)
g:set_value(1,true);g:show();local count=#all
g:set_value(.26,false);assert(#all==count)
g:set_value(1,true);g:set_value(.25,false);assert(#all==count+6)
g:destroy();gauge.clear_ghosts()
for _,p in ipairs(all) do assert(p.dead) end
-- Preview HP mode keeps low-HP effects but suppresses the detached ghost.
local calls={}
bars={new=function(frame) calls.frame=frame;return {} end,
    update_target=function(_,label,hpp) calls[#calls+1]={label,hpp} end,
    show=function() end,destroy=function() calls.destroyed=true end}
local preview=require('animationPreview')
local frame={ghost_hit=true,low_hp_pulse=true,pos={x=1,y=2}}
preview.start(frame,100,200,5)
assert(not calls.frame.ghost_hit and calls.frame.low_hp_pulse and calls[2][2]==5)
assert(frame.ghost_hit and frame.pos.x==1)
preview.start(frame,100,200)
assert(calls.destroyed and calls.frame.ghost_hit and calls[4][2]==20)
preview.clear()
print('underbar_spec: edges, shrinking, colors, opacity, critical flash, threshold and cleanup passed')
