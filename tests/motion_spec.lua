-- Deterministic feedback timing, interruption, priority and renderer checks.
dofile('tests/gauge_spec.lua')
local motion=require('healthMotion')
local now=0
local options={healing_effect=true,text_effect=true,hit_shake=true,low_hp_pulse=true,
    direction=function() return 1 end,heal_duration=.35,text_duration=.2,pulse_period=1.4}
local m=motion.new(options,function() return now end)
m:update(1,true);m:update(.7)
assert(m:sample().text_value==1 and m:sample().flash==1)
now=.06;assert(m:sample().offset==1)
now=.1;assert(math.abs(m:sample().text_value-.85)<1e-9)
m:update(.4)
assert(math.abs(m:sample().text_value-.85)<1e-9)
now=.3;assert(math.abs(m:sample().text_value-.4)<1e-9 and m:sample().offset==0)
m:update(.8)
assert(m:sample().healing and m:sample().white==1 and m:sample().flash_kind=='heal')
now=.4;assert(math.abs(m:sample().text_value-.6)<1e-9)
m:update(.5) -- damage interrupts count-up and removes the healing tint
assert(not m:sample().healing and m:sample().flash_kind=='damage')
assert(math.abs(m:sample().text_value-.6)<1e-9)
now=.6;assert(math.abs(m:sample().text_value-.5)<1e-9)
m:update(1,true);m:update(.25) -- drop >50 percentage points
now=.66;assert(m:sample().offset==3)
now=.72;assert(m:sample().offset==-4)
now=.8;assert(m:sample().offset==0)
m:update(.25,true);assert(not m:sample().low) -- strict thresholds
m:update(.10,true);now=.7
assert(m:sample().low and math.abs(m:sample().alpha-.5)<1e-9)
m:update(.09,true);assert(m:sample().alpha==0 and m:sample().white==1)
now=1.4;assert(m:sample().alpha==1 and m:sample().white==0)
m:update(0,true);assert(not m:sample().low)
m:update(.5,true);assert(m:sample().flash==0 and m:sample().offset==0)
local off=motion.new({},function() return now end)
off:update(.9,true);off:update(.01)
assert(off:sample().alpha==1 and off:sample().offset==0 and off:sample().flash==0)
m:update(.55,true);m:update(.30)
assert(not m.shake_at, 'exactly 25 points must not shake due to floating-point noise')
m:update(.8,true);m:update(.3)
assert(m.shake_at and not m.shake_large, 'exactly 50 points uses the small shake')

local gauge=require('ffxiGauge')
now=0
local g=gauge.new(180,{red=255,green=149,blue=151,alpha=255},
    {damage_trail=true,animation_duration=.18,effects=options,clock=function() return now end})
g:set_value(.4,true);g:show();g:set_value(.8)
assert(g.value==.4 and g.trail_value==.8)
assert(g.fill[1].rgb[2]==255 and g.trail[1].rgb[2]==224)
now=.175;g:show();assert(math.abs(g.value-.6)<1e-9)
g:set_value(.1)
assert(g.value==.1 and not g.feedback.healing and g.trail[1].rgb[2]<100)
now=.235;g:show()
assert(g.trough[1].y==3 and g.fill[1].y==4)
assert(g.trail[1].y==1, 'underlying trail must not shake')
now=.295;g:show();assert(g.trough[1].y==-4 and g.trail[1].y==1)
g:set_value(.09,true);now=.7;g:show()
assert(g.fill[1]:alpha()==0 and g.fill[1].rgb[2]==255)
assert(g.trail[1]:visible(), 'red underneath remains visible at transparent pulse peak')
g:set_value(.8,true);g:show()
assert(g.fill[1]:alpha()==255 and g.fill[1].rgb[2]==149)
assert(g.trough[1].y==0 and not g.trail[1]:visible())
g:destroy()
now=0
local b=bars.new({skin='ffxi',width=180,color={red=255,green=149,blue=151,alpha=255},
    font='Arial',font_size=14,pos={x=10,y=10},healing_effect=true,text_effect=true,
    hit_shake=true,low_hp_pulse=true,text_duration=.22,heal_duration=.35,pulse_period=1.4})
b.gauge.clock=function() return now end
b.gauge.motion.clock=b.gauge.clock
local base={red=230,green=230,blue=138}
bars.update_target(b,'Rabbit',80,12,1,10);bars.set_name_color(b,base)
bars.update_target(b,'Rabbit',50,12,1,10);bars.set_name_color(b,base)
assert(b.name_text.hpp==80 and b.name_text.rgb[1]==167)
assert(b.action_text.rgb[1]==230, 'supporting labels retain semantic colors')
now=.11;bars.show(b)
assert(b.name_text.hpp==65)
now=.22;bars.show(b);assert(b.name_text.hpp==50)
bars.update_target(b,'Rabbit',70,12,1,10);bars.set_name_color(b,base)
assert(b.name_text.hpp==50 and b.name_text.rgb[2]==224)
now=.33;bars.show(b);assert(b.name_text.hpp==60)
bars.update_target(b,'Rabbit',40,12,1,10);bars.set_name_color(b,base)
assert(b.name_text.hpp==60 and b.name_text.rgb[1]==167)
bars.update_target(b,'Rabbit',90,12,1,11);bars.set_name_color(b,base)
assert(b.name_text.hpp==90 and b.name_text.rgb[1]==230 and not b.gauge.trail_at)
bars.hide(b);bars.destroy(b)
-- Simulate saved settings: requested presets migrate once, later edits survive.
local function clone(value)
    if type(value)~='table' then return value end
    local copy={};for k,v in pairs(value) do copy[k]=clone(v) end;return copy
end
local function merge(base,override)
    for k,v in pairs(override) do
        if type(v)=='table' and type(base[k])=='table' then merge(base[k],v)
        else base[k]=clone(v) end
    end
end
target_bar,subtarget_bar,focustarget_bar,aggro_bars,bar_sets=nil,nil,nil,nil,nil
local disk={subtarget_bar={skin='classic',color={red=12,green=50,blue=101,alpha=255},
    pos={x=123,y=456},width=220},focustarget_bar={skin='classic',color={red=93,green=0,blue=255}}}
local writes=0
package.loaded.config={load=function(defaults)
    local result=clone(defaults);merge(result,disk)
    return setmetatable(result,{__index={save=function(self) writes=writes+1;disk=clone(self) end}})
end,register=function(_,callback) callback() end}
dofile('enemybar2.lua')
assert(subtarget_bar.gauge and subtarget_bar.color.green==180)
assert(focustarget_bar.gauge and focustarget_bar.color.red==255)
assert(subtarget_bar.width==220 and subtarget_bar.x==123 and subtarget_bar.y==456)
assert(writes==1 and disk.subtarget_bar.native_style_revision==1)
for _,group in ipairs(bar_sets) do for _,part in ipairs(group) do bars.destroy(part) end end
target_bar,subtarget_bar,focustarget_bar,aggro_bars,bar_sets=nil,nil,nil,nil,nil
disk.subtarget_bar.skin='classic';disk.subtarget_bar.color={red=11,green=22,blue=33,alpha=255}
dofile('enemybar2.lua')
assert(not subtarget_bar.gauge and subtarget_bar.color.green==22 and writes==1)
for _,group in ipairs(bar_sets) do for _,part in ipairs(group) do bars.destroy(part) end end
print('Healing, text transitions, hit shakes and low-HP feedback checks passed.')
