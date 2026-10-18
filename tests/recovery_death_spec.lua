-- A: small finishing ghosts, main-only recovery, interruptions and cleanup.
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
local now=0
local function near(a,b) assert(math.abs(a-b)<1e-7,tostring(a)..' ~= '..tostring(b)) end
local function make(main,overrides)
    local o=settings.snapshot(overrides or {})
    o.healing_effect=true;o.heal_duration=1;o.ghost_hit=true
    return gauge.new(400,{alpha=200,red=255,green=149,blue=151},
        {animation_duration=.18,damage_trail=true,effects=o,ghost_options=o,
        ghost_hit=true,main_bar=main,clock=function() return now end})
end
-- Positive->zero copies the remaining HP exactly once, even when both rules match.
for _,hp in ipairs({.01,.2,.75,1}) do
    local g=make(false)
    g:set_value(hp,true);g:show()
    local first=#all+1
    g:set_value(0,false)
    assert(#all==first+7) -- six ghost parts, plus two scheduled sparkle arms
    near(all[first]._w,(g.width-12)*hp)
    if hp<.75 then assert(all[first+1]._w<=all[first]._w/2) end
    local count=#all;g:set_value(0,false);assert(#all==count)
    g:hide();g:destroy();gauge.update_ghosts()
    assert(not all[first].dead and all[first]._visible)
    gauge.clear_ghosts()
end
local g=make(false)
g:set_value(.2,true);g:show();local count=#all
g:set_value(.01,false);assert(#all==count) -- small nonlethal hit
g:set_value(0,true);assert(#all==count) -- identity/reset must not invent a kill
g:set_value(.2,true);g:hide();g:set_value(0,false);assert(#all==count)
g:destroy()
-- Recovery follows both ends of the green interval and settles as fill catches up.
now=0;g=make(true)
g:move(100,200);g:set_value(.35,true);g:show();g:set_value(.85,false)
assert(g.heal_glow and g.heal_glow[1]._visible)
local span=g.width-12
near(g.heal_glow[1]._w,span*.5)
near(g.heal_glow[2].x+g.heal_glow[2]._w/2,106+span*.35)
near(g.heal_glow[3].x+g.heal_glow[3]._w/2,106+span*.85)
assert(g.heal_glow[2].rgb[1]==255 and g.heal_glow[2].rgb[2]==255)
assert(g.heal_glow[3].rgb[2]==255 and not g.trail_glow[1]._visible)
local alpha,height=g.heal_glow[1].a,g.heal_glow[1]._h
now=.75;g:show()
assert(g.heal_glow[1].a<alpha and g.heal_glow[1]._h<height)
near(g.heal_glow[1]._w,span*.125)
g:move(300,400)
near(g.heal_glow[2].x+g.heal_glow[2]._w/2,306+span*.725)
g:hide();for _,p in ipairs(g.heal_glow) do assert(not p._visible) end
g:show();assert(g.heal_glow[1]._visible)
now=1;g:show();for _,p in ipairs(g.heal_glow) do assert(not p._visible) end
g:set_value(.4,true);g:set_value(.9,false);now=1.2;g:show()
g:set_value(.8,false);assert(not g.heal_glow[1]._visible)
g:set_value(.95,false);assert(g.heal_glow[1]._visible)
g:set_value(.5,true);assert(not g.heal_glow[1]._visible)
g:destroy()
for _,main in ipairs({true,false}) do
    now=0;g=make(main,{healing_glow=false});assert(not g.heal_glow);g:destroy()
end
g=make(false);assert(not g.heal_glow);g:destroy()
g=make(true,{healing_glow_alpha=0,healing_flare_alpha=0})
g:set_value(.2,true);g:show();g:set_value(.6,false)
for _,p in ipairs(g.heal_glow) do assert(not p._visible) end
g:destroy();gauge.clear_ghosts()
for _,p in ipairs(all) do assert(p.dead) end
-- Preview passes real roles through, using positive->zero for finishing hits.
local calls={}
bars={new=function(options,main) calls.main=main;calls.options=options;return {} end,
    update_target=function(_,_,hp) calls[#calls+1]=hp end,
    show=function() end,destroy=function() end}
local preview=require('animationPreview')
preview.start({},0,0,nil,'kill',true)
assert(calls[1]==20 and calls[2]==0 and calls.options.ghost_hit)
preview.start({},0,0,nil,'heal',false)
assert(calls[3]==35 and calls[4]==85 and not calls.options.ghost_hit and not calls.main)
preview.start({death_spark=false},0,0,nil,'spark',true)
assert(calls[5]==20 and calls[6]==0 and calls.options.death_spark and not calls.options.ghost_hit)
preview.clear()
print('recovery_death_spec: killing ghosts, main recovery, interruption, preview and cleanup passed')
