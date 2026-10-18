-- A: delayed closing endpoint, independent lifetimes and resource ownership.
package.path='./?.lua;'..package.path
local all={}
package.loaded.images={new=function(config)
    local p={config=config,_w=1,_h=1,_visible=config.visible,a=config.color.alpha}
    function p:pos(x,y) self.x,self.y=x,y end
    function p:size(w,h) self._w,self._h=w,h end
    function p:width() return self._w end
    function p:color(r,g,b) self.rgb={r,g,b} end
    function p:alpha(a) self.a=a end
    function p:visible(v)
        if v then assert(self.x and self._w>0 and self.a>0,'unprepared sparkle') end
        self._visible=v
    end
    function p:destroy() assert(not self.dead,'double destruction');self.dead=true end
    all[#all+1]=p;return p
end}
windower={addon_path='./'}
local settings=require('animationSettings')
local spark=require('deathSpark')
local gauge=require('ffxiGauge')
local now=0
local function near(a,b) assert(math.abs(a-b)<1e-7,tostring(a)..' ~= '..tostring(b)) end
local o=settings.snapshot({death_spark_duration=.2,death_spark_alpha=230,death_spark_size=16})
local clock=function() return now end
spark.spawn(106,105.5,o,128,clock,.15)
assert(#all==2 and all[1].config.texture.path:find('sparkle_gain_arm_h',1,true))
assert(all[2].config.texture.path:find('sparkle_gain_arm_v',1,true))
local h,v=all[1],all[2]
assert(not h._visible and h.a==0)
now=.14;spark.update();assert(not h._visible)
-- Change source settings after birth: queued glints retain their scalar snapshot.
o.death_spark_size=64;o.death_spark_alpha=0;o.death_spark_duration=2
now=.19;spark.update()
assert(h._visible and v._visible and h.a==115)
near(h._w,16);near(v._h,12)
near(h.x+h._w/2,106);near(v.y+v._h/2,105.5)
now=.27;spark.update();assert(h.a<115 and h._w<16)
now=.351;spark.update();assert(h.dead and v.dead)
spark.clear() -- expired parts no longer owned
local count=#all
spark.spawn(0,0,o,255,clock,0);assert(#all==count) -- zero alpha
o.death_spark_alpha=230;o.death_spark=false
spark.spawn(0,0,o,255,clock,0);assert(#all==count)
o.death_spark=true;spark.spawn(0,0,o,0,clock,0);assert(#all==count)
-- Every real visible positive->zero transition schedules exactly one glint,
-- even with ghosts disabled. Hide/reflow/recreation cannot move its endpoint.
o=settings.snapshot({death_spark_duration=.2})
now=0
local g=gauge.new(100,{alpha=255,red=255,green=149,blue=151},
    {animation_duration=.18,damage_trail=true,ghost_hit=false,ghost_options=o,clock=clock})
g:move(100,100);g:set_value(.2,true);g:show();count=#all
g:set_value(0,false);assert(#all==count+2)
h,v=all[count+1],all[count+2]
g:set_value(0,false);assert(#all==count+2)
g:move(400,400);g:hide();g:destroy()
now=.14;gauge.update_ghosts();assert(not h._visible)
now=.19;gauge.update_ghosts();assert(h._visible)
near(h.x+h._w/2,106);near(h.y+h._h/2,105.5)
now=.36;gauge.update_ghosts();assert(h.dead and v.dead)
-- Hidden/immediate observations do not invent death; nonlethal hits do not spark.
g=gauge.new(100,{alpha=255,red=255,green=149,blue=151},
    {animation_duration=.18,damage_trail=true,ghost_options=o,clock=clock})
g:set_value(.3,true);count=#all;g:set_value(0,false);assert(#all==count)
g:show();g:set_value(.3,true);g:set_value(.2,false);assert(#all==count)
g:set_value(0,true);assert(#all==count)
g:destroy()
-- Scene/unload cleanup cancels queued and visible glints, including overlaps.
now=0;spark.spawn(0,0,o,255,clock,0);spark.spawn(0,0,o,255,clock,.15)
now=.04;gauge.update_ghosts();gauge.clear_ghosts();gauge.clear_ghosts()
for _,p in ipairs(all) do assert(p.dead) end
print('death_spark_spec: timing, snapshots, endpoint, independent lifecycle and cleanup passed')
