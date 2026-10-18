-- Awake: smoke the real entry point and its registered lifecycle/mouse handlers.
-- Rendering and game APIs are mocked, but command registration/config are real.
package.path='./?.lua;'..package.path
function S(t)
    function t:contains(v) for _,x in ipairs(self) do if x==v then return true end end;return false end
    return t
end
function L(t) return t end
package.preload.chat=function() function string:color() return self end;return {} end
local events,logs,sent,objects={},{},{},{}
local saved=0
windower={addon_path='./',register_event=function(name,fn)
    events[name]=events[name] or {};events[name][#events[name]+1]=fn
end,add_to_chat=function(channel,s) logs[#logs+1]={channel,s} end,
send_command=function(s) sent[#sent+1]=s end,
get_windower_settings=function() return {ui_x_res=1280,ui_y_res=720} end,
ffxi={get_info=function() return {logged_in=false} end,get_party=function() return {party1_count=0,party2_count=0,party3_count=0} end}}
_addon={}
package.loaded.config={load=function(defaults)
    if not next(defaults) then return {} end
    function defaults:save() saved=saved+1 end
    return defaults
end,register=function(_,fn) fn() end}
package.loaded.images={};package.loaded.texts={};package.loaded.packets={}
package.preload.bars=function()
    bars={new=function(frame,main_bar)
        local b={x=frame.pos.x,y=frame.pos.y,width=frame.width,skin=frame.skin,font_size=frame.font_size,main_bar=main_bar}
        objects[#objects+1]=b;return b
    end,move=function(b,x,y) b.x,b.y=x,y end,
    destroy=function(b) assert(not b.dead,'double destruction');b.dead=true end,
    hover=function() return true end,show=function() end,hide=function() end}
    return bars
end
package.preload.actionTracking=function()
    function reset_tracked_actions() end
    function clean_tracked_actions() end
    return {}
end
assert(loadfile('enemybar2.lua'))()
local function event(name,...)
    for _,fn in ipairs(events[name] or {}) do fn(...) end
end
assert(_addon.version=='1.1.1-a.20261018.14' and target_bar and #aggro_bars==6)
assert(target_bar.main_bar and not subtarget_bar.main_bar and not focustarget_bar.main_bar and not aggro_bars[1].main_bar)
assert(settings.target_bar.foreground_flash_alpha==0 and settings.target_bar.ghost_lift_up==0)
event('addon command','help','layout');assert(logs[#logs][1]==0)
event('addon command','setup','on');assert(logs[#logs][2]:find('Ctrl',1,true))
-- Both Ctrl keys work; releasing one while the other is held retains snapping.
event('keyboard',29,true);event('keyboard',157,true);event('keyboard',29,false)
assert(drag_snap_key_down)
event('mouse',1,target_bar.x,target_bar.y,0,false)
event('mouse',0,target_bar.x+17,target_bar.y+13,0,false)
assert(target_bar.x%10==0 and target_bar.y%10==0)
event('mouse',2,target_bar.x,target_bar.y,0,false)
assert(saved==1 and settings.target_bar.pos.x==target_bar.x)
event('keyboard',157,false);assert(not drag_snap_key_down)
local x,y=target_bar.x,target_bar.y
event('addon command','defaults','animations')
assert(settings.target_bar.pos.x==x and settings.target_bar.pos.y==y)
event('addon command','restart');event('addon command','restart')
assert(#sent==1 and sent[1]=='lua reload enemybar2')
assert(target_bar==nil and bar_sets==nil and not drag_snap_key_down)
for _,b in ipairs(objects) do assert(b.dead) end
event('unload') -- follows the command and must not double-destroy primitives
event('prerender') -- queued render while reloading must not use destroyed bars
assert(#sent==1)
print('entrypoint_spec: load, help, grid drag, presets, restart, unload and queued draw passed')
