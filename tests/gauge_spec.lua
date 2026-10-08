-- Run from the repository root with Lua 5.1+ (no game client required).
-- These stubs model the images/texts API and a deferred texture-size reset;
-- they do not claim to reproduce Direct3D filtering.
local live = {}
local function primitive(settings)
    local p = {settings=settings, showing=settings.visible or false}
    live[p] = true
    function p:pos(x,y) self.x,self.y=x,y end
    function p:size(w,h)
        assert(w >= 0 and h >= 0, 'negative primitive size')
        self.w,self.h=w,h
        self.render_w,self.render_h=w,h
    end
    function p:width(w) if w then self.w=w end return self.w or self.settings.size.width end
    function p:visible(v) if v ~= nil then self.showing=v end return self.showing end
    function p:show() self.showing=true end
    function p:hide() self.showing=false end
    function p:color(r,g,b) self.rgb={r,g,b} end
    function p:alpha(a) if a then self.settings.color.alpha=a end return self.settings.color.alpha end
    function p:path(path) self.path_value=path end
    function p:hover(x,y)
        return self.showing and x>=self.x and x<=self.x+(self.w or 0)
            and y>=self.y and y<=self.y+(self.h or 0)
    end
    function p:destroy() assert(live[self], 'double destroy'); live[self]=nil end
    return p
end
images = {new=primitive}
texts = {new=function(_,settings) return primitive(settings) end}
package.loaded.images = images
windower = {addon_path='./', get_windower_settings=function()
    return {ui_x_res=1920,ui_y_res=1080}
end}
local function count_live()
    local count=0
    for _ in pairs(live) do count=count+1 end
    return count
end

local gauge = require('ffxiGauge')
local now = 0
local animated = gauge.new(180,{alpha=255,red=209,green=224,blue=151},
    {animation_duration=.18, background_alpha=128, clock=function() return now end})
assert(animated.trough[2].settings.color.alpha==128)
assert(animated.trough[1].settings.color.alpha==255)
assert(animated.fill[1].settings.color.alpha==255)
animated:set_value(1,true); animated:set_value(.4)
now=.09; animated:show()
assert(math.abs(animated.value-.7)<1e-9)
animated:set_value(.4) -- unchanged samples must not restart the slide
now=.18; animated:show()
assert(math.abs(animated.value-.4)<1e-9)
animated:set_value(1)
now=.27; animated:show()
assert(math.abs(animated.value-.7)<1e-9)
animated:set_value(.2) -- interrupted changes start at the displayed edge
assert(math.abs(animated.value-.7)<1e-9)
now=.36; animated:show()
assert(math.abs(animated.value-.45)<1e-9)
now=.6; animated:show()
assert(math.abs(animated.value-.2)<1e-9)
animated:set_value(.8,true)
assert(animated.value==.8 and animated.started_at==nil)
animated:destroy()
now=0
local trail=gauge.new(180,{alpha=255,red=255,green=149,blue=151},
    {damage_trail=true,animation_duration=.18,trail_delay=1.5,trail_duration=.5,
     clock=function() return now end})
assert(count_live()==9 and trail.trail[1].settings.color.red==167)
trail:set_value(1,true);trail:show();trail:set_value(.8)
assert(trail.value==.8 and trail.trail_value==1)
now=1;trail:show();trail:set_value(.8)
assert(trail.trail_at==1.5 and trail.trail_value==1)
trail:set_value(.6)
assert(trail.trail_at==2.5)
now=2.4;trail:show();assert(trail.trail_value==1)
now=2.75;trail:show();assert(math.abs(trail.trail_value-.8)<1e-9)
trail:set_value(.4)
assert(math.abs(trail.trail_value-.8)<1e-9 and trail.trail_at==4.25)
now=4.5;trail:show();assert(math.abs(trail.trail_value-.6)<1e-9)
now=5;trail:show();assert(trail.trail_value==.4 and not trail.trail_at)
for _,p in ipairs(trail.trail) do assert(not p:visible()) end
trail:set_value(0);assert(trail.value==0 and trail.trail_value==.4)
trail:hide();for _,p in ipairs(trail.trail) do assert(not p:visible()) end
trail:set_value(.9,true);trail:show()
assert(trail.trail_value==.9 and not trail.trail_at)
trail:set_value(.2);trail:set_value(.7) -- batch 1 healing clears stale damage
assert(not trail.trail_at and trail.target_value==.7)
for _,p in ipairs(trail.trail) do p.render_w,p.render_h=32,56 end
trail:show()
for _,p in ipairs(trail.trail) do assert(p.render_w==p.w and p.render_h==p.h) end
trail:destroy();assert(count_live()==0)
for _, width in ipairs({1,16,180,300,600}) do
    local g = gauge.new(width,{alpha=255,red=255,green=149,blue=151})
    assert(count_live()==6)
    g:move(101,202)
    assert(not g:hover(102,202), 'hidden gauges cannot be dragged')
    g:show()
    assert(g:hover(102,202))
    assert(not g:hover(100,202))
    for _, value in ipairs({0,.0001,.01,.53,1,2,-1}) do
        g:set_value(value)
        local filled=(g.width-12)*math.max(0,math.min(1,value))
        local total=0
        for _, part in ipairs(g.fill) do
            total=total+part:width()
            assert(part.x>=g.x+6-1e-9)
            assert(part.x+part:width()<=g.x+6+filled+1e-9,
                'fill must not exceed the HP proportion')
            assert(part:visible()==(part:width()>0 and value>0))
        end
        assert(math.abs(total-filled)<1e-9)
        assert(g.trough[1]:width()==6 and g.trough[3]:width()==6)
        assert(g.fill[1]:width()<=3 and g.fill[3]:width()<=3)
        assert(g.fill[2].x==g.fill[1].x+g.fill[1]:width())
        assert(math.abs(g.fill[3].x-g.fill[2].x-g.fill[2]:width())<1e-9)
    end
    g:set_value(0)
    g:hide(); g:show()
    for _, part in ipairs(g.fill) do assert(not part:visible()) end
    g:hide(); g:set_value(.7)
    for _, part in ipairs(g.fill) do assert(not part:visible()) end
    g:move(51,60)
    assert(g.fill[1].x==57 and g.fill[1].y==61)
    -- Simulate texture loading changing GPU sizes while the Lua-side cached
    -- dimensions still look correct. No HP change and no dragging occurs.
    for _, value in ipairs({1,.5,0}) do
        g:set_value(value); g:show()
        for _, parts in ipairs({g.trough,g.fill}) do
            for _, part in ipairs(parts) do part.render_w,part.render_h=32,56 end
        end
        g:show(); g:set_value(value)
        for _, parts in ipairs({g.trough,g.fill}) do
            for _, part in ipairs(parts) do
                assert(part.render_w==part.w and part.render_h==part.h,
                    'drawing must recover source-size resets at unchanged HP')
            end
        end
    end
    g:destroy()
    assert(count_live()==0)
end

require('bars')
local function new_bar(skin)
    return bars.new({skin=skin,width=600,color={alpha=255,red=255,green=149,blue=151},
        font='Arial',font_size=14,pos={x=10,y=20},show_dist=false,
        show_target=false,show_target_icon=false,show_action=false,show_debuff=false})
end
local sentinel = {}
local identity_bar = new_bar('ffxi')
bars.update_target(identity_bar,'Rabbit',90,12,1,101)
assert(identity_bar.gauge.value==.9)
bars.update_target(identity_bar,'Rabbit',30,12,1,101)
assert(identity_bar.gauge.target_value==.3 and identity_bar.gauge.trail_at)
assert(identity_bar.gauge.value==.3 and identity_bar.gauge.trail_value==.9)
bars.update_target(identity_bar,'Rabbit',60,12,1,102)
assert(identity_bar.gauge.value==.6 and not identity_bar.gauge.started_at)
bars.hide(identity_bar)
bars.update_target(identity_bar,'Rabbit',20,12,1,102)
assert(identity_bar.gauge.value==.2)
bars.destroy(identity_bar)
o=sentinel
for _=1,10 do
    local modern, classic = new_bar('ffxi'), new_bar('classic')
    assert(o==sentinel, 'bar creation must not overwrite global o')
    assert(modern.gauge and not classic.gauge)
    assert(not modern.name_text:visible() and not classic.name_text:visible())
    bars.show(modern); bars.show(classic)
    bars.update_target(modern,'Rabbit',0,12.1,1)
    bars.update_target(classic,'Rabbit',50,12.1,1)
    assert(classic.foreground_body_image:width()==300)
    for _, part in ipairs(modern.gauge.fill) do assert(not part:visible()) end
    bars.move(modern,100,200)
    assert(bars.hover(modern,101,200))
    bars.hide(modern)
    assert(not bars.hover(modern,101,200))
    bars.show(modern)
    for _, part in ipairs(modern.gauge.fill) do assert(not part:visible()) end
    bars.set_name_color(modern,{red=230,green=230,blue=138})
    assert(modern.name_text.rgb[1]==230)
    assert(modern.gauge.trough[1].settings.color.red==255)
    bars.destroy(modern); bars.destroy(classic)
    assert(count_live()==0, 'recreating bars must release every primitive')
end
-- Exercise the real command handler and renderer recreation as well.
local saves=0
package.loaded.config = {
    load=function(defaults)
        return setmetatable(defaults,{__index={save=function() saves=saves+1 end}})
    end,
    register=function(settings,callback) callback(settings) end,
}
package.loaded.texts=texts
package.loaded.packets={}
package.loaded.actionTracking=true
clean_tracked_actions=function() end
reset_tracked_actions=function() end
S=function(values)
    return {contains=function(_,value)
        for _,entry in ipairs(values) do if entry==value then return true end end
        return false
    end}
end
L=function(values) return values end
_addon={}
windower.ffxi={get_info=function() return {logged_in=false} end,
    get_party=function() return {} end}
local events={}
windower.register_event=function(name,callback)
    events[name]=events[name] or {}; table.insert(events[name],callback)
end
unpack=unpack or table.unpack
windower.add_to_chat=function() end
dofile('enemybar2.lua')
assert(settings.aggro_bar.show and aggro_bars[1].gauge)
assert(settings.target_bar.pos.x==659 and settings.target_bar.pos.y==1008)
local original_ui = windower.get_windower_settings
windower.get_windower_settings=function() return {ui_x_res=1280,ui_y_res=720} end
settings.target_bar.pos={x=1800,y=1200}
local reset_saves=saves
handle_command('resetpos')
assert(saves==reset_saves+1)
assert(settings.target_bar.pos.x==339 and settings.target_bar.pos.y==346)
assert(target_bar.x==339 and target_bar.y==346)
assert(settings.target_bar.width==600 and settings.target_bar.color.green==149)
settings.target_bar.width=400
initialize_bars()
handle_command('resetpos','t')
assert(settings.target_bar.pos.x==439)
settings.aggro_bar.stack_dir='down'
initialize_bars()
local before_spacing=aggro_bars[6].y-aggro_bars[1].y
local before_sub_offset=subtarget_bar.y-target_bar.y
handle_command('resetpos','all')
assert(subtarget_bar.y-target_bar.y==before_sub_offset)
assert(aggro_bars[6].y-aggro_bars[1].y==before_spacing)
settings.aggro_bar.stack_dir='up'
initialize_bars()
handle_command('resetpos','a')
assert(aggro_bars[1].y-aggro_bars[6].y==135)
local valid_saves=saves
handle_command('resetpos','bogus')
assert(saves==valid_saves)
settings.target_bar.width=600
windower.get_windower_settings=original_ui
initialize_bars()
saves=0
assert(aggro_bars[1].gauge.fill[1].settings.color.green==224)
local original_update = update_bar
local assigned = {}
update_bar=function(_,target) assigned[#assigned+1]=target.id end
get_ordered_aggro=function() return {{mob=10},{mob=99},{mob=20},{mob=30}} end
windower.ffxi.get_mob_by_target=function() return {id=10} end
windower.ffxi.get_mob_by_id=function(id) if id~=99 then return {id=id} end end
update_aggro_bars(true)
assert(#assigned==2 and assigned[1]==20 and assigned[2]==30)
assigned={}; settings.target_bar.show=false
update_aggro_bars(true)
assert(#assigned==3 and assigned[1]==10)
settings.target_bar.show=true; update_bar=original_update
assert(target_bar.gauge and subtarget_bar.gauge and focustarget_bar.gauge)
local original_count=count_live()
handle_command('set','skin','t','invalid')
assert(saves==0 and count_live()==original_count)
handle_command('set','skin','t','classic')
assert(saves==1 and not target_bar.gauge)
handle_command('s','skin','target','FFXI')
assert(saves==2 and target_bar.gauge and count_live()==original_count)
handle_command('set','color','t','255','149','151')
assert(target_bar.gauge.fill[1].settings.color.green==149)
handle_command('set','background_alpha','t','64')
assert(target_bar.gauge.trough[2].settings.color.alpha==64)
handle_command('set','animation_duration','t','0')
assert(target_bar.gauge.duration==0)
local before_invalid=saves
handle_command('set','background_alpha','t','256')
handle_command('set','animation_duration','t','-1')
assert(saves==before_invalid)
handle_command('width','420')
assert(settings.target_bar.width==420)
handle_command('pos','100','200','st')
assert(subtarget_bar.x==100 and subtarget_bar.y==200)
handle_command('pos','st','110','210')
assert(subtarget_bar.x==110 and subtarget_bar.y==210)
handle_command('bold','off','all');handle_command('italic','off','st')
assert(not target_bar.name_text.settings.flags.bold)
assert(not subtarget_bar.name_text.settings.flags.italic)
handle_command('bounds','off','all')
handle_command('setup','all','on')
for _,group in ipairs(bar_sets) do for _,b in ipairs(group) do update_bar(b,nil,false) end end
assert(target_bar.name_text:visible() and subtarget_bar.name_text:visible())
local old_positions={}
for _,group in ipairs(bar_sets) do for _,b in ipairs(group) do old_positions[b]={b.x,b.y} end end
local mouse=events.mouse[1]
local mx,my=target_bar.x+10,target_bar.y+1
assert(mouse(1,mx,my,0,false))
assert(mouse(0,mx+11,my+7,0,false))
for b,pos in pairs(old_positions) do assert(b.x==pos[1]+11 and b.y==pos[2]+7) end
assert(mouse(2,mx+11,my+7,0,false))
handle_command('setup','st','on')
for _,group in ipairs(bar_sets) do for _,b in ipairs(group) do update_bar(b,nil,false) end end
assert(not target_bar.name_text:visible() and subtarget_bar.name_text:visible())
local before_target_x=target_bar.x
mx,my=subtarget_bar.x+10,subtarget_bar.y+1
assert(mouse(1,mx,my,0,false));mouse(0,mx+4,my+2,0,false);mouse(2,mx+4,my+2,0,false)
assert(target_bar.x==before_target_x)
handle_command('setup','off')
bars.show(target_bar)
handle_command('lock','t');bars.show(target_bar)
mx,my=target_bar.x+10,target_bar.y+1
assert(not mouse(1,mx,my,0,false))
handle_command('unlock','t');bars.show(target_bar)
assert(mouse(1,mx,my,0,false));mouse(2,mx,my,0,false)
handle_command('bounds','on','all')
handle_command('pos','9999','9999')
local ui=windower.get_windower_settings()
assert(target_bar.x+target_bar.gauge.width<=ui.ui_x_res)
assert(target_bar.y+target_bar.font_size*2<=ui.ui_y_res)
windower.get_windower_settings=function() return {ui_x_res=800,ui_y_res=600} end
events.prerender[1]()
assert(target_bar.x+target_bar.gauge.width<=800 and target_bar.y+28<=600)
handle_command('bounds','off')
handle_command('pos','1200','900')
assert(target_bar.x==1200 and target_bar.y==900)
handle_command('resetpos')
assert(target_bar.x>=0 and target_bar.x+target_bar.gauge.width<=800)
windower.get_windower_settings=original_ui
handle_command('set','skin','all','ffxi')
assert(target_bar.gauge and subtarget_bar.gauge and focustarget_bar.gauge)
for _,b in ipairs(aggro_bars) do assert(b.gauge) end
handle_command('set','skin','all','classic')
assert(not target_bar.gauge and not subtarget_bar.gauge and not focustarget_bar.gauge)
for _,b in ipairs(aggro_bars) do assert(not b.gauge) end
for _,group in ipairs(bar_sets) do for _,b in ipairs(group) do bars.destroy(b) end end
assert(count_live()==0)
print('Gauge geometry, bar lifecycle and skin command checks passed.')
