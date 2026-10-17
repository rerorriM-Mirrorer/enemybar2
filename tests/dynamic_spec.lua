-- Awake: curve boundaries, synchronized modulation, tint snapshots and flash RGBA.
package.path='./?.lua;'..package.path
local settings=require('animationSettings')
local ghost=require('ghostMotion')
local underbar=require('underbarMotion')
local function close(a,b) assert(math.abs(a-b)<1e-7,tostring(a)..' ~= '..tostring(b)) end
local o=settings.snapshot({ghost_contact_duration=0,ghost_period=.1})
close(ghost.sample(o,0).height_scale,1)
close(ghost.sample(o,.05).height_scale,.35)
o.ghost_height_mode='smooth';close(ghost.sample(o,.025).height_scale,.675)
o.ghost_height_mode='off';close(ghost.sample(o,.05).height_scale,1)
o.ghost_height_mode='snap';o.ghost_height_strength=0;close(ghost.sample(o,.05).height_scale,1)
o.ghost_height_strength=1;o.ghost_period=0;close(ghost.sample(o,.05).height_scale,1)
o.ghost_period=.1;o.ghost_contact_duration=.08
local contact=ghost.sample(o,.05);assert(contact.contact and contact.flicker==1 and contact.height_scale==1)
o=settings.snapshot({underbar_glow_height=33,underbar_flare_height=45,underbar_flare_width=30})
local full=underbar.sample(o,100,400)
close(full.glow_height,33);close(full.flare_height,45);close(full.flare_width,30)
local reused={};assert(underbar.sample(o,100,400,reused)==reused)
close(reused.glow_height,full.glow_height)
local quarter=underbar.sample(o,25,400)
close(quarter.glow_height,2+(33-2)*.5)
close(quarter.flare_height,4+(45-4)*.5)
close(quarter.flare_width,1+(30-1)*.25)
local previous={glow_height=0,flare_height=0,flare_width=0}
for width=0,400 do
    local s=underbar.sample(o,width,400)
    for key,value in pairs(s) do assert(value>=previous[key] and value>=0);previous[key]=value end
    assert(s.flare_width<=width/2 and s.flare_height<=45 and s.glow_height<=33)
end
o.underbar_size_mode='fixed';local fixed=underbar.sample(o,5,400)
close(fixed.glow_height,33);close(fixed.flare_height,45);close(fixed.flare_width,2.5)
o.underbar_glow_height=0;close(underbar.sample(o,5,400).glow_height,0)

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
local now=0
o=settings.snapshot({foreground_period=.1,foreground_flash_color={red=20,green=40,blue=60},foreground_flash_alpha=80})
o.low_hp_pulse=true
local g=gauge.new(400,{alpha=128,red=255,green=149,blue=151},{animation_duration=.18,
    effects=o,ghost_options=o,clock=function() return now end})
g:set_value(.05,true);g:show();now=.05;g:show()
assert(g.critical_fill[1]._visible and not g.fill[1]._visible)
assert(g.critical_fill[1].config.color.red==20 and g.critical_fill[1].config.color.blue==60)
assert(g.critical_fill[1].config.color.alpha==40)
now=.11;g:show();assert(g.fill[1]._visible and not g.critical_fill[1]._visible)
g:destroy()
-- White retention and legacy red fade use independent per-hit snapshots.
for _,mode in ipairs({'white','trail'}) do
    now=0;o=settings.snapshot({ghost_fade_to=mode,ghost_contact_duration=0,ghost_lift_duration=0,
        ghost_hover_duration=0,ghost_fade_duration=1,ghost_period=0,ghost_glow=false})
    g=gauge.new(100,{alpha=255,red=255,green=149,blue=151},{animation_duration=.18,
        ghost_hit=true,ghost_options=o,clock=function() return now end})
    g:set_value(1,true);g:show();local first=#all+1;g:set_value(.2,false)
    o.ghost_fade_to=mode=='white' and 'trail' or 'white'
    now=.5;gauge.update_ghosts()
    assert(all[first].a==128)
    if mode=='white' then assert(all[first].rgb[1]==255 and all[first].rgb[2]==255)
    else assert(all[first].rgb[1]<255 and all[first].rgb[2]<255) end
    gauge.clear_ghosts();g:destroy()
end
-- Height and glow opacity share one sampled phase, then can be uncoupled.
now=0;o=settings.snapshot({ghost_contact_duration=0,ghost_lift_duration=0,
    ghost_hover_duration=1,ghost_fade_duration=1,ghost_glow_duration=10})
g=gauge.new(100,{alpha=255,red=255,green=149,blue=151},{animation_duration=.18,
    ghost_hit=true,ghost_options=o,clock=function() return now end})
g:set_value(1,true);g:show();local first=#all+1;g:set_value(.2,false)
local tall=all[first]._h
now=.05;gauge.update_ghosts();assert(all[first]._h<tall and all[first].a==0)
gauge.clear_ghosts();g:destroy()
for _,p in ipairs(all) do assert(p.dead) end
local cleaned,sent=0,{}
local life=require('lifecycle').new(function() cleaned=cleaned+1 end,function(c) sent[#sent+1]=c end,function() end)
life:request('unload');life:request('restart');life:dispose()
assert(cleaned==1 and #sent==1 and sent[1]=='lua unload enemybar2')
local external=require('lifecycle').new(function() cleaned=cleaned+1 end,function() error('unexpected dispatch') end,function() end)
external:dispose();external:dispose();assert(external.pending and cleaned==2)
print('dynamic_spec: scaling, flicker, custom flash, fade modes, snapshots and lifecycle passed')
