--[[
Copyright © 2015, Mike McKee
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.
    * Neither the name of enemybar nor the
        names of its contributors may be used to endorse or promote products
        derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mike McKee BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

_addon.name = 'enemybar2'
_addon.author = 'mmckee,akaden,A'
_addon.version = '1.1.1-a.20261018.14'
_addon.language = 'English'
_addon.commands = {'enemybar','eb'}

config = require('config')
images = require('images')
texts = require('texts')
table = require('table')
packets = require('packets')

require('bars')
require('actionTracking')
local bar_layout = require('barLayout')
local frame_names = {'target','subtarget','focustarget','aggro'}
local last_ui_width, last_ui_height
local animation_settings=require("animationSettings")
local animation_preview=require("animationPreview")
local gauge_effects=require("ffxiGauge")
local help_text=require('helpText')
local animation_preset=require('animationPreset')
local function save_positions()
    for i, name in ipairs(frame_names) do
        local b=bar_sets[i][1]
        if b then settings[name..'_bar'].pos={x=b.x,y=b.y} end
    end
    settings:save()
end
local function move_group(group,dx,dy,constrain)
    local ui=windower.get_windower_settings()
    if constrain then dx,dy=bar_layout.clamp(group,dx,dy,ui.ui_x_res,ui.ui_y_res) end
    for _,b in ipairs(group) do bars.move(b,b.x+dx,b.y+dy) end
    return dx,dy
end
local function recover_bounds()
    if not bar_sets then return end
    local ui=windower.get_windower_settings()
    bars.x_res,bars.y_res=ui.ui_x_res,ui.ui_y_res
    for i,group in ipairs(bar_sets) do
        if settings[frame_names[i]..'_bar'].bounds ~= false then move_group(group,0,0,true) end
    end
    last_ui_width,last_ui_height=ui.ui_x_res,ui.ui_y_res
end

player_id = nil
party_members = {}
debug_string = ''

local state = {}
state.setup = false
state.focustarget = nil
state.in_cs = false
local snap_keys={}

local function destroy_live_bars()
    if target_bar then 
        bars.destroy(target_bar) 
        target_bar = nil
    end
    if subtarget_bar then 
        bars.destroy(subtarget_bar)
        subtarget_bar = nil 
    end
    if focustarget_bar then 
        bars.destroy(focustarget_bar) 
        focustarget_bar = nil
    end
    if aggro_bars then
        for i,b in ipairs(aggro_bars) do
            bars.destroy(b)
        end
    end
    aggro_bars,bar_sets=nil,nil
end

local lifecycle=require('lifecycle').new(function()
    if dragged and bar_sets then save_positions() end
    dragged,drag_snap_key_down=nil,false
    snap_keys={}
    state.setup=false
    animation_preview.clear();gauge_effects.clear_ghosts();destroy_live_bars()
end,windower.send_command,function(message) windower.add_to_chat(207,message) end)

function initialize_bars()
    destroy_live_bars()
    target_bar = bars.new(settings.target_bar,true)
    subtarget_bar = bars.new(settings.subtarget_bar)
    focustarget_bar = bars.new(settings.focustarget_bar)
    local y = settings.aggro_bar.pos.y
    aggro_bars = {}
    for i = 1, settings.aggro_bar.count do
        aggro_bars[i] = bars.new(settings.aggro_bar)
        bars.move(aggro_bars[i], settings.aggro_bar.pos.x, y)
        if settings.aggro_bar.stack_dir == 'down' then
            y = y + settings.aggro_bar.stack_padding
        elseif settings.aggro_bar.stack_dir == 'up' then
            y = y - settings.aggro_bar.stack_padding
        end
    end

    bar_sets = {{target_bar}, {subtarget_bar}, {focustarget_bar}, aggro_bars}
    for i,group in ipairs(bar_sets) do
        for _,b in ipairs(group) do b.frame_name=frame_names[i] end
    end
    dragged=nil
    recover_bounds()
end

function update_bar(bar, target, show)
    if state.setup then
        -- Setup keeps every frame visible; mouse handling limits draggable groups.
            bars.show(bar)
            if bar == target_bar then bars.update_target(bar, "Target Name", 79, 12.1, 1)
            elseif bar == subtarget_bar then bars.update_target(bar, "Subtarget Name", 53, 11.4, 2)
            elseif bar == focustarget_bar then bars.update_target(bar, "Focus Target Name", 36, 8.6, 1)
            else bars.update_target(bar, "Aggro Target Name", 47, 6.6, 1) end
            bars.update_action(bar, "Action Name", '')
            bars.update_enmity(bar, "Mob Target", {red=102, green=255, blue=255})
            bars.update_status(bar, {})
            bars.set_name_color(bar, {red=255, green=180, blue=180})
    else
        if target and target.hpp==0 and bar~=target_bar then
            if show and not state.in_cs and bar.target_id==target.id then
                bars.update_target(bar,target.name,0,0,nil,target.id)
            end
            bars.hide(bar);bar.death_id,bar.death_at=nil,nil;return
        end
        if target and show and not state.in_cs and target.hpp==0
            and bar.death_id==target.id and bar.death_at and os.clock()-bar.death_at>=.65 then
            bars.hide(bar);return
        end
        if target ~= nil and show and not state.in_cs then     
            bars.show(bar)

            local dist = get_distance(windower.ffxi.get_mob_by_target('me'), target)

            local t = windower.ffxi.get_mob_by_target('t')
            local st = windower.ffxi.get_mob_by_target('st')
            local target_type = nil
            if t and t.id == target.id then 
                target_type = 1
            elseif st and st.id == target.id then
                target_type = 2
            end
            bars.update_target(bar, target.name, target.hpp, dist, target_type, target.id)

            local action = tracked_actions[target.id]
            if action and not action.complete then
                bars.update_action(bar, action.ability.name, '')
            else
                bars.update_action(bar, nil, '')
            end

            local enmity_target = tracked_enmity[target.id]
            if enmity_target and enmity_target.pc then
                local pc = windower.ffxi.get_mob_by_id(enmity_target.pc)
                if pc then
                    bars.update_enmity(bar, pc.name, get_tint_by_target(pc))
                else
                    bars.update_enmity(bar, nil)
                end
            elseif not target.is_npc then
                local target_target = windower.ffxi.get_mob_by_index(target.target_index)
                if target_target then
                    bars.update_enmity(bar, target_target.name, get_tint_by_target(target_target))
                else
                    bars.update_enmity(bar, nil)
                end
            else
                bars.update_enmity(bar, nil)
            end

            bars.update_status(bar, tracked_debuff[target.id])

            bars.set_name_color(bar, get_tint_by_target(target))
        elseif bar==target_bar and not target and show and not state.in_cs and bar.death_at
            and os.clock()-bar.death_at<.65 then
            -- Keep the observed dead target's own text counting after auto-detarget.
            bars.show(bar)
        else
            bars.hide(bar)
            if not show or state.in_cs then bar.death_id,bar.death_at=nil,nil end
        end
    end
end

function update_aggro_bars(show)
    if state.setup then
        for i=1, (aggro_bars and #aggro_bars or 0) do
            update_bar(aggro_bars[i], nil, show)
        end
    else
        local ordered_aggro = get_ordered_aggro()
        -- Capture a killing-hit ghost before compacting surviving aggro rows.
        for _,bar in ipairs(aggro_bars) do
            -- Setup uses a label as rendering identity, not a numeric entity ID.
            local mob=type(bar.target_id)=='number' and windower.ffxi.get_mob_by_id(bar.target_id)
            if mob and mob.hpp==0 then
                if show and not state.in_cs then bars.update_target(bar,mob.name,0,0,nil,mob.id) end
                bars.hide(bar);bar.death_id,bar.death_at=nil,nil
            end
        end
        local selected = settings.target_bar.show and windower.ffxi.get_mob_by_target('t')

        local e_bar_i = 1
        if show and not state.in_cs then
            for i,v in ipairs(ordered_aggro) do
                if e_bar_i > settings.aggro_bar.count then
                    break
                end
                local bar = aggro_bars[e_bar_i]
                local target = windower.ffxi.get_mob_by_id(v.mob)
                if target and target.hpp and target.hpp>0
                    and (not selected or selected.id ~= target.id) then
                    update_bar(bar, target, show)
                    e_bar_i = e_bar_i + 1
                end
            end
        end
        -- hide bars not updated (all of them, if show is off)
        for i=e_bar_i, (aggro_bars and #aggro_bars or 0) do
            local bar = aggro_bars[i]
            if bar then
                update_bar(bar,nil,show)
            end
        end
    end
end

-- sort by hpp (lowest -> highest) then group by debuff status.
function get_ordered_aggro()
    local debuffed = {}
    local ordered = {}
    for k,n in pairs(tracked_enmity) do
        local mob = windower.ffxi.get_mob_by_id(k)
        if mob then
            n.hpp = mob.hpp
            local is_debuffed = false
            if tracked_debuff[k] then
                for id,debuff in pairs(tracked_debuff[k]) do
                    if tracked_debuff_ids:contains(id) then
                        table.insert(debuffed,n)
                        is_debuffed = true
                        break
                    end
                end
            end
            if not is_debuffed then
                table.insert(ordered,n) 
            end
        end
    end
    local hpp_sort = function(left,right)
            return left.hpp < right.hpp
        end
    table.sort(ordered, hpp_sort)
    table.sort(debuffed, hpp_sort)
    for i,n in ipairs(debuffed) do
        table.insert(ordered, n)
    end
    return ordered
end

function check_claim(claim_id)
    if player_id == claim_id then
            return 1
    else
        local m, p = is_party_member_or_pet(claim_id)
        if m and p == 1 then
            return 2
        elseif m and p > 1 then
            return 3
        end
    end
    return 0
end

function get_tint_by_target(target)
    if target.hpp == 0 then
        return {red=155, green=155, blue=155}
    elseif check_claim(target.claim_id) == 1 or check_claim(target.claim_id) == 2 then
        return {red=255, green=130, blue=130}
    elseif check_claim(target.claim_id) == 3 then
        return {red=255, green=142, blue=205}
    elseif is_party_member_or_pet(target.id) and target.id ~= player_id then
        return {red=102, green=255, blue=255}
    elseif not target.is_npc then
        return {red=255, green=255, blue=255}
    elseif target.spawn_type == 2 or target.spawn_type == 34 then
        return {red=150, green=225, blue=150} --Green town NPCs and doors
    elseif target.claim_id == 0 then
        return {red=230, green=230, blue=138} 
    elseif target.claim_id ~= 0 then
        return {red=153, green=102, blue=255}
    end    
end

function get_distance(player, target)
    local dx = player.x-target.x
    local dy = player.y-target.y
    return math.sqrt(dx*dx + dy*dy)
end

function looking_at(a, b)
    if not a or not b then return false end
    local h = a.facing % math.pi
    local h2 = (math.atan2(a.x-b.x,a.y-b.y) + math.pi/2) % math.pi
    return math.abs(h-h2) < 0.15
end

function is_npc(mob_id)
    local is_pc = mob_id < 0x01000000
    local is_pet = mob_id > 0x01000000 and mob_id % 0x1000 > 0x700

    -- filter out pcs and known pet IDs
    if is_pc or is_pet then return false end

    -- check if the mob is charmed
    local mob = windower.ffxi.get_mob_by_id(mob_id)
    if not mob then return nil end
    return mob.is_npc and not mob.charmed
end

function is_party_member_or_pet(mob_id)
    if mob_id == player_id then return true, 1 end

    if is_npc(mob_id) then return false end

    if party_members[mob_id] == nil then return false end

    return party_members[mob_id], party_members[mob_id].party
end

function handle_party_packets(id, data)
    if id == 0x0DD then
        -- cache party 
        cache_party_members:schedule(1)
    elseif id == 0x067 then
        local p =  packets.parse('incoming', data)
        if p['Owner Index'] > 0 then
            local owner = windower.ffxi.get_mob_by_index(p['Owner Index'])
            if owner and is_party_member_or_pet(owner.id) then
                party_members[p['Pet ID']] = {is_pet = true, owner = owner.id}
            end
        end
    end
end

function cache_party_members()
    party_members = {}
    local party = windower.ffxi.get_party()
    if not party then return end
    for i=0, (party.party1_count or 0) - 1 do
        cache_party_member(party['p'..i], 1)            
    end
    for i=0, (party.party2_count or 0) - 1 do
        cache_party_member(party['a1'..i], 2)            
    end
    for i=0, (party.party3_count or 0) - 1 do
        cache_party_member(party['a2'..i], 3)            
    end
end

function cache_party_member(p, party_number)
    if p and p.mob then
        party_members[p.mob.id] = {is_pc = true, party=party_number}
        if p.mob.pet_index then
            local pet = windower.ffxi.get_mob_by_index(p.mob.pet_index)
            if pet then
                party_members[pet.id] = {is_pet = true, owner = p.id, party=party_number}
            end
        end
    end
end

-- A: use UI dimensions, not the render buffer. Saved positions remain
-- explicit; resetpos is the escape hatch after moving to a smaller client.
local function default_bar_position(name, frame)
    local ui = windower.get_windower_settings()
    local width = frame.skin == 'ffxi' and math.max(16, frame.width+2) or frame.width+2
    local bottom = math.max(0, ui.ui_y_res-72)
    local x = math.max(0, math.floor((ui.ui_x_res-width)/2))
    local y = bottom
    if name == 'subtarget' then y = math.max(0, bottom-30)
    elseif name == 'focustarget' then y = math.max(0, bottom-60)
    elseif name == 'aggro' then
        x = math.max(0, ui.ui_x_res-width-20)
        local span = math.max(0, (frame.count-1)*frame.stack_padding)
        if frame.stack_dir == 'down' then y = math.max(0, bottom-span)
        else y = math.max(bottom, math.min(span, ui.ui_y_res-12)) end
    end
    return {x=x, y=y}
end

-- Shared validation keeps both short and legacy commands on one path.
local function valid_rgb(r,g,b)
    for _,raw in ipairs({r,g,b}) do
        local v=tonumber(raw)
        if not v or v~=math.floor(v) or v<0 or v>255 then return false end
    end
    return true
end
local function valid_dimension(setting,raw)
    local v=tonumber(raw)
    local limits={width={16,4096},font_size={1,72},count={1,32},stack_padding={0,4096}}
    local range=limits[setting]
    return v and v==math.floor(v) and v>=range[1] and v<=range[2]
end

function handle_command(c, ...)
    if not c then c='help' end
    local args = L{...}
    c = c:lower()
    if c=='restart' or c=='unload' then lifecycle:request(c);return end
    if lifecycle.pending then return end
    if c=='defaults' then
        local frame=normalize_bar_name(args[2] or 't')
        if args[1]~='animations' or not frame then
            windower.add_to_chat(123,'EnemyBar: //eb defaults animations [t/st/ft/a/all]');return
        end
        animation_preset.apply(settings,frame)
        settings:save();initialize_bars()
        windower.add_to_chat(207,'EnemyBar: animation defaults applied to '..frame..'; layout retained')
        return
    end
    if c=='preview' then
        if args[1]=='off' then animation_preview.clear();return end
        local hpp=args[1]=='hp' and tonumber(args[2]) or nil
        -- Lua's a-and-b-or-c idiom falls through when b is nil: omitted HP
        -- preview frame must default to target, not reuse the HP argument.
        local frame_arg
        if args[1]=='hp' then frame_arg=args[3] else frame_arg=args[2] end
        local name=normalize_bar_name(frame_arg or 't')
        if not S{'ghost','hp','heal','kill','spark'}:contains(args[1]) or not name or name=='all' or
            (args[1]=='hp' and (not hpp or hpp<1 or hpp>100 or hpp~=math.floor(hpp))) then
            windower.add_to_chat(123,'EnemyBar: preview ghost/heal/kill/spark [bar], preview hp <1..100> [bar], or preview off');return
        end
        if state.in_cs then windower.add_to_chat(123,'EnemyBar: preview unavailable during cutscenes');return end
        local frame=settings[name..'_bar']
        if frame.skin~='ffxi' then windower.add_to_chat(123,'EnemyBar: ghost preview requires ffxi skin');return end
        local index=({target=1,subtarget=2,focustarget=3,aggro=4})[name]
        local b=bar_sets[index][1]
        animation_preview.start(frame,b.x,b.y,hpp,args[1],name=='target')
        if hpp then windower.add_to_chat(207,'EnemyBar: '..name..' HP preview '..hpp..'% (8 seconds)') end
        return
    end
    local aliases={targetof='show_target',targeticon='show_target_icon',action='show_action',
        distance='show_dist',debuffs='show_debuff',fontsize='font_size',spacing='stack_padding',edit='setup',move='setup'}
    c=aliases[c] or c
    if c=='hide' then return handle_command('set','show',args[1] or 't','off') end
    if c=='show' and (#args==0 or (#args==1 and normalize_bar_name(args[1]))) then
        return handle_command('set','show',args[1] or 't','on')
    end
    local toggles=S{'show_target','show_target_icon','show_action','show_dist','show_debuff',
        'bold','italic','bounds','damage_trail','healing_effect','text_effect','hit_shake','low_hp_pulse','ghost_hit','ghost_glow','underbar_glow','ghost_glow_flicker','healing_glow','death_spark'}
    if toggles:contains(c) and (#args==0 or (#args==1 and normalize_bar_name(args[1]))) then
        local frame=normalize_bar_name(args[1] or 't')
        local value=not settings[(frame=='all' and 'target' or frame)..'_bar'][c]
        return handle_command('set',c,frame,value and 'on' or 'off')
    end
    if c=='stack_padding' then
        if not args[1] then windower.add_to_chat(207,'EnemyBar: spacing '..settings.aggro_bar.stack_padding);return end
        return handle_command('set',c,'a',args[1])
    end
    if c=='stack' then
        local direction=args[1] or (settings.aggro_bar.stack_dir=='up' and 'down' or 'up')
        if direction~='up' and direction~='down' then
            windower.add_to_chat(123,'EnemyBar: stack [up/down]'); return
        end
        return handle_command('set','stack_dir','a',direction)
    end
    if c=='trail_alpha' then
        if #args==0 or (#args==1 and normalize_bar_name(args[1])) then
            local frame=normalize_bar_name(args[1] or 't')
            for _,name in ipairs(frame_names) do
                if frame=='all' or frame==name then
                    windower.add_to_chat(207,'EnemyBar: '..name..' trail_alpha '..settings[name..'_bar'].trail_color.alpha)
                end
            end
            return
        end
        local alpha=tonumber(args[1])
        if not alpha or alpha<0 or alpha>255 then
            windower.add_to_chat(123,'EnemyBar: trail_alpha 0..255 [frame]'); return
        end
        local frame=normalize_bar_name(args[2] or 't')
        if not frame then windower.add_to_chat(123,'EnemyBar: unknown frame'); return end
        for _,name in ipairs(frame_names) do
            if frame=='all' or frame==name then settings[name..'_bar'].trail_color.alpha=alpha end
        end
        settings:save(); initialize_bars(); return
    end
    -- Short forms use values first, with an optional frame last. Legacy set
    -- syntax still uses setting/frame/values. Keep one validation path.
    local arity={pos=2,color=3,trail_color=3,skin=1,width=1,font=1,font_size=1,count=1,
        stack_dir=1,stack_padding=1,show=1,bold=1,italic=1,bounds=1,locked=1,
        background_alpha=1,animation_duration=1,damage_trail=1,trail_delay=1,trail_duration=1,
        show_target=1,show_action=1,show_dist=1,show_debuff=1,show_target_icon=1,
        healing_effect=1,text_effect=1,hit_shake=1,low_hp_pulse=1,
        heal_duration=1,text_duration=1,pulse_period=1,ghost_hit=1}
    for name in pairs(animation_settings.defaults) do arity[name]=1 end
    arity.ghost_glow_color=3
    arity.foreground_flash_color=3
    if arity[c] then
        local n=arity[c]
        if #args==0 or (#args==1 and normalize_bar_name(args[1])) then
            local frame=normalize_bar_name(args[1] or 't')
            for _,name in ipairs(frame_names) do
                if frame=='all' or frame==name then
                    local value=settings[name..'_bar'][c]
                    if type(value)=='table' then
                        value=c=='pos' and (value.x..' '..value.y) or (value.red..' '..value.green..' '..value.blue)
                    end
                    windower.add_to_chat(207,'EnemyBar: '..name..' '..c..' '..tostring(value))
                end
            end
            return
        end
        if #args==n or #args==n+1 then
            if #args==n+1 and normalize_bar_name(args[1]) then
                return handle_command('set',c,args[1],unpack(args,2,n+1))
            end
            local frame=args[n+1] or 't'
            return handle_command('set',c,frame,unpack(args,1,n))
        end
        windower.add_to_chat(123,'EnemyBar: '..c..' needs '..n..' value(s), then optional frame')
        return
    end
    if c == 'lock' or c == 'unlock' then
        return handle_command('set','locked',args[1] or 'all',c=='lock' and 'on' or 'off')
    end
    if c == 'status' then
        windower.add_to_chat(207,'EnemyBar '.._addon.version..': setup '..(state.setup and (state.setup_scope or 'all') or 'off'))
        for _,name in ipairs(frame_names) do
            local f=settings[name..'_bar']
            windower.add_to_chat(207,string.format('%s: %s, width %g, saved pos %g %g, locked %s, bounds %s, trail %s',
                name,f.skin,f.width,f.pos.x,f.pos.y,tostring(f.locked),tostring(f.bounds),tostring(f.damage_trail)))
            windower.add_to_chat(207,string.format('  feedback: healing %s, text %s, shake %s, pulse %s',
                tostring(f.healing_effect),tostring(f.text_effect),tostring(f.hit_shake),tostring(f.low_hp_pulse)))
            if name=='target' then
                windower.add_to_chat(207,string.format('  main healing glow %s: alpha %g, height %g; flares alpha %g, height %g, width %g',
                    tostring(f.healing_glow),f.healing_glow_alpha,f.healing_glow_height,
                    f.healing_flare_alpha,f.healing_flare_height,f.healing_flare_width))
            end
            windower.add_to_chat(207,string.format('  trail alpha %g, pulse period %g, ghost %s',
                f.trail_color.alpha,f.pulse_period,tostring(f.ghost_hit)))
            windower.add_to_chat(207,string.format('  death sparkle %s: alpha %g, size %gpx, duration %gs',
                tostring(f.death_spark),f.death_spark_alpha,f.death_spark_size,f.death_spark_duration))
            windower.add_to_chat(207,string.format('  seconds: fill %g, trail hold %g, trail slide %g, healing %g, text %g',
                f.animation_duration,f.trail_delay,f.trail_duration,f.heal_duration,f.text_duration))
            windower.add_to_chat(207,string.format('  split periods: foreground %g, underbar %g; settle %s',f.foreground_period,f.underbar_period,f.super_settle))
            windower.add_to_chat(207,string.format('  foreground flash RGB %g/%g/%g alpha %g; ghost fades to %s; height %s, min %g, strength %g, glow flicker %s',
                f.foreground_flash_color.red,f.foreground_flash_color.green,f.foreground_flash_color.blue,f.foreground_flash_alpha,
                f.ghost_fade_to,f.ghost_height_mode,f.ghost_height_min,f.ghost_height_strength,tostring(f.ghost_glow_flicker)))
            windower.add_to_chat(207,string.format('  underbar size %s: full at %g%% exposed; minima glow/flare/width %g/%g/%gpx; curves height/width %g/%g',
                f.underbar_size_mode,f.underbar_size_reference,f.underbar_glow_min_height,f.underbar_flare_min_height,
                f.underbar_flare_min_width,f.underbar_height_curve,f.underbar_width_curve))
            windower.add_to_chat(207,string.format('  underbar glow %s: alpha %g, height %gpx; flare alpha %g, height %gpx, width %gpx',
                tostring(f.underbar_glow),f.underbar_glow_alpha,f.underbar_glow_height,
                f.underbar_flare_alpha,f.underbar_flare_height,f.underbar_flare_width))
            windower.add_to_chat(207,string.format('  ghost: lift %g up/%g right in %gs, hover %gs, drift %g up/%g right in %gs; alpha %g, period %g',
                f.ghost_lift_up,f.ghost_lift_right,f.ghost_lift_duration,f.ghost_hover_duration,
                f.ghost_drift_up,f.ghost_drift_right,f.ghost_fade_duration,f.ghost_alpha,f.ghost_period))
            windower.add_to_chat(207,string.format('  shake: %s; small/large/super %g/%g/%gpx; rebound %g, decay %g, hold %gs, step %gs, horizontal %g',
                f.shake_style,f.shake_small_px,f.shake_large_px,f.shake_super_px,
                f.shake_rebound,f.shake_decay,f.shake_hold,f.shake_step,f.shake_horizontal))
            windower.add_to_chat(207,string.format('  ghost glow %s: contact %gs; RGB %g/%g/%g, alpha %g, height %gpx, duration %gs; flare alpha %g, height %gpx, width %gpx',
                tostring(f.ghost_glow),f.ghost_contact_duration,f.ghost_glow_color.red,f.ghost_glow_color.green,f.ghost_glow_color.blue,
                f.ghost_glow_alpha,f.ghost_glow_height,f.ghost_glow_duration,f.ghost_flare_alpha,f.ghost_flare_height,f.ghost_flare_width))
        end
        return
    end
    if c == 'resetpos' then
        local name = normalize_bar_name(args[1] or 't')
        if not name then
            windower.add_to_chat(123, 'EnemyBar: Unknown bar name')
            return
        end
        local group={}
        for i, frame_name in ipairs(frame_names) do
            if name == 'all' or name == frame_name then
                for _,b in ipairs(bar_sets[i]) do group[#group+1]=b end
            end
        end
        local ui=windower.get_windower_settings()
        local dx,dy=bar_layout.center(group,ui.ui_x_res,ui.ui_y_res)
        move_group(group,dx,dy,true)
        save_positions()
        windower.add_to_chat(207, 'EnemyBar: position reset for "'..name..'" bar')
    elseif S{'set','s'}:contains(c) and args[1] and args[2] then
        local setting = args[1]:lower()
        local bar = normalize_bar_name(args[2])
        if not bar then
            windower.add_to_chat(123, 'EnemyBar: Unknown bar name: "'..args[2]:lower()..'"')
            return
        end
        if setting == 'pos' then
            if args[3] and args[4] then
                if not tonumber(args[3]) or not tonumber(args[4]) then
                    windower.add_to_chat(123, 'EnemyBar: value is not numeric for "'..setting..'"')
                else
                    set_setting(bar, setting, {x=tonumber(args[3]),y=tonumber(args[4])})
                end
            else
                windower.add_to_chat(123, 'EnemyBar: not enough arguments for "'..setting..'"')
            end
        elseif setting == 'color' or setting == 'trail_color' or setting=='ghost_glow_color' or setting=='foreground_flash_color' then
            if args[3] and args[4] and args[5] then
                if not valid_rgb(args[3],args[4],args[5]) then
                    windower.add_to_chat(123, 'EnemyBar: '..setting..' requires three integers from 0 to 255')
                else
                    set_setting(bar, setting, {red=tonumber(args[3]),green=tonumber(args[4]),blue=tonumber(args[5])})
                end
            else
                windower.add_to_chat(123, 'EnemyBar: not enough arguments for "'..setting..'"')
            end
        elseif setting == 'skin' then
            local skin = args[3] and args[3]:lower()
            if skin == 'ffxi' or skin == 'classic' then
                set_setting(bar, setting, skin)
            else
                windower.add_to_chat(123, 'EnemyBar: skin must be "ffxi" or "classic"')
            end
        elseif animation_settings.ranges[setting] then
            if animation_settings.valid(setting,args[3]) then set_setting(bar,setting,tonumber(args[3]))
            else
                local range=animation_settings.ranges[setting]
                windower.add_to_chat(123,'EnemyBar: '..setting..' must be '..range[1]..'..'..range[2])
            end
        elseif animation_settings.enums[setting] then
            if S(animation_settings.enums[setting]):contains(args[3]) then set_setting(bar,setting,args[3])
            else windower.add_to_chat(123,'EnemyBar: '..setting..' '..table.concat(animation_settings.enums[setting],'/')) end
        elseif setting=='super_settle' then
            if S{'off','small','both'}:contains(args[3]) then set_setting(bar,setting,args[3])
            else windower.add_to_chat(123,'EnemyBar: super_settle off/small/both') end
        elseif setting=='shake_style' then
            if args[3]=='impact' or args[3]=='classic' then set_setting(bar,setting,args[3])
            else windower.add_to_chat(123,'EnemyBar: shake_style impact/classic') end
        elseif S{'background_alpha','animation_duration','trail_delay','trail_duration','heal_duration','text_duration','pulse_period'}:contains(setting) then
            local value = tonumber(args[3])
            local maximum = setting == 'background_alpha' and 255 or 10
            if value and value >= 0 and value <= maximum and (setting~='pulse_period' or value>0) then
                set_setting(bar, setting, value)
            else
                windower.add_to_chat(123, 'EnemyBar: '..setting..' must be between 0 and '..maximum)
            end
        elseif S{'font','stack_dir'}:contains(setting) then
            if setting=='stack_dir' and args[3]~='up' and args[3]~='down' then
                windower.add_to_chat(123,'EnemyBar: stack direction must be up/down');return
            end
            if args[3] then
                set_setting(bar, setting, args[3])
            else
                windower.add_to_chat(123, 'EnemyBar: not enough arguments for "'..setting..'"')
            end
        elseif S{'font_size','width','count','stack_padding'}:contains(setting) then
            if args[3] then
                if not valid_dimension(setting,args[3]) then
                    windower.add_to_chat(123, 'EnemyBar: invalid '..setting..' (width 16..4096, font size 1..72, aggro count 1..32, spacing 0..4096; integers)')
                else
                    set_setting(bar, setting, tonumber(args[3]))
                end
            else
                windower.add_to_chat(123, 'EnemyBar: not enough arguments for "'..setting..'"')
            end
        elseif S{'show','show_target_icon','show_target','show_debuff','show_action','show_dist','bold','italic','bounds','locked','damage_trail','healing_effect','text_effect','hit_shake','low_hp_pulse','ghost_hit','ghost_glow','underbar_glow','ghost_glow_flicker','healing_glow','death_spark'}:contains(setting) then
            if args[3] then
                local b = normalize_boolean(args[3])
                if b == nil then
                    windower.add_to_chat(123, 'EnemyBar: unknown value for "'..setting..'"')
                else
                    set_setting(bar, setting, b)
                end
            else
                windower.add_to_chat(123, 'EnemyBar: not enough arguments for "'..setting..'"')
            end
        else
            windower.add_to_chat(123, 'EnemyBar: Unknown setting: "'..setting..'"')
        end
    elseif S{'focustarget','ft','f'}:contains(c) then
        if args[1] then
            if args[1]:lower() == "clear" then
                state.focustarget = nil
                windower.add_to_chat(207, 'EnemyBar: focus target is now off')
            elseif tonumber(args[1]) then
                local t = windower.ffxi.get_mob_by_id(tonumber(args[1]))
                if t then
                    state.focustarget = t.id
                    windower.add_to_chat(207, 'EnemyBar: focus target is now "'..t.name..'"')
                else
                    windower.add_to_chat(123, 'EnemyBar: could not find a target with that ID')
                end    
            else
                local t = get_mob_by_name(args[1])
                if t then
                    state.focustarget = t.id
                    windower.add_to_chat(207, 'EnemyBar: focus target is now "'..t.name..'"')
                else
                    windower.add_to_chat(123, 'EnemyBar: could not find a target by that name')
                end                
            end
        else 
            local t = windower.ffxi.get_mob_by_target('t')
            if t then
                state.focustarget = t.id
                windower.add_to_chat(207, 'EnemyBar: focus target is now "'..t.name..'"')
            else
                windower.add_to_chat(123, 'EnemyBar: no target selected to focustarget')
            end
        end
    elseif S{'demo','setup','debug','test'}:contains(c) then
        local scope = args[1] and normalize_bar_name(args[1]) or 'individual'
        local enabled = args[1] and normalize_boolean(args[1])
        if args[1] and not scope and enabled==nil then
            windower.add_to_chat(123,'EnemyBar: setup [t/st/ft/a/all] [on/off]'); return
        end
        if enabled~=nil then state.setup=enabled; state.setup_scope='individual'
        else
            local explicit=args[2] and normalize_boolean(args[2])
            if args[2] and explicit==nil then
                windower.add_to_chat(123,'EnemyBar: setup state must be on/off'); return
            end
            if explicit~=nil then state.setup=explicit
            else state.setup=not (state.setup and state.setup_scope==scope) end
            state.setup_scope=scope
        end
        dragged=nil
        windower.add_to_chat(207, 'EnemyBar: setup mode is now "'..(state.setup and 'on' or 'off')..'"')
        if state.setup then windower.add_to_chat(207,'EnemyBar: hold Ctrl while dragging for a 10px grid; release mouse to save') end
    elseif S{'help','h','man','manual'}:contains(c) then
        help_text.show(args[1])
    else
        windower.add_to_chat(123,'EnemyBar: unknown command '..c)
        help_text.show()
    end
end

function get_mob_by_name(n)
    n = n:lower()
    local worse_match = nil
    local worser_match = nil
    for _,mob in pairs(windower.ffxi.get_mob_array()) do
        local mobname = mob.name:lower()
        if n == mobname then
            return mob
        elseif not worse_match and mobname:sub(1, #n) == n then
            worse_match = mob
        elseif not worser_match and mobname:match(n) then
            worser_match = mob
        end
    end
    return worse_match or worser_match
end

function normalize_bar_name(n)
    n = n:lower()
    if n == 't' then
        n = 'target'
    elseif n == 'st' then
        n = 'subtarget'
    elseif n == 'a' then
        n = 'aggro'
    elseif S{'f','ft'}:contains(n) then
        n = 'focustarget'
    elseif not S{'target','subtarget','aggro','focustarget','all'}:contains(n) then
        n = nil
    end

    return n
end

function normalize_boolean(b)
    b = b:lower()
    if S{'true','t','yes','y','on'}:contains(b) then
        return true
    elseif S{'false','f','no','n','off'}:contains(b) then
        return false
    else return nil end
end

function set_setting(bar, setting, v)
    for _,name in ipairs(frame_names) do
        if bar=='all' or bar==name then
            if setting=='color' or setting=='trail_color' then
                -- Changing RGB preserves this frame's independently saved alpha.
                local existing=settings[name..'_bar'][setting]
                existing.red,existing.green,existing.blue=v.red,v.green,v.blue
            elseif setting=='ghost_glow_color' or setting=='foreground_flash_color' then
                settings[name..'_bar'][setting]={red=v.red,green=v.green,blue=v.blue}
            else
                settings[name..'_bar'][setting]=v
                if setting=='pulse_period' then
                    settings[name..'_bar'].foreground_period=v
                    settings[name..'_bar'].underbar_period=v
                end
            end
        end
    end
    windower.add_to_chat(207, 'EnemyBar: "'..setting..'" updated for "'..bar..'" bar')
    settings:save()
    initialize_bars()
end

windower.register_event('prerender', function()
    if lifecycle.pending then return end
    gauge_effects.update_ghosts()
    animation_preview.update()
    local ui=windower.get_windower_settings()
    if ui.ui_x_res~=last_ui_width or ui.ui_y_res~=last_ui_height then
        recover_bounds() -- runtime recovery; keep saved layouts for larger clients
    end
    if player_id then
        update_bar(target_bar, windower.ffxi.get_mob_by_target('t'), settings.target_bar.show)
        update_bar(subtarget_bar, windower.ffxi.get_mob_by_target('st'), settings.subtarget_bar.show)
        update_bar(focustarget_bar, state.focustarget and windower.ffxi.get_mob_by_id(state.focustarget) or nil, settings.focustarget_bar.show)
        update_aggro_bars(settings.aggro_bar.show)
    else
        update_bar(target_bar, nil, false)
        update_bar(subtarget_bar, nil, false)
        update_bar(focustarget_bar, nil, false)
        update_aggro_bars(false)
    end
end)
windower.register_event('prerender', clean_tracked_actions)
windower.register_event('incoming chunk', function(id, data)
    handle_action_packet(id, data)
    handle_party_packets(id, data)
end)
windower.register_event('zone change', function() reset_tracked_actions();animation_preview.clear();gauge_effects.clear_ghosts() end)
windower.register_event('unload', function() lifecycle:dispose() end)
windower.register_event('addon command', handle_command)
windower.register_event('logout', function(...)
    animation_preview.clear();gauge_effects.clear_ghosts()
    player_id = nil    
    state = {}      
end)
windower.register_event('login', function(...)
    if windower.ffxi.get_info().logged_in then
        player_id = windower.ffxi.get_player().id
    end
    state = {}

    cache_party_members()
end)
windower.register_event('status change', function(new_status_id)
    if new_status_id == 4 then
        state.in_cs = true
        animation_preview.clear();gauge_effects.clear_ghosts()
    else
        state.in_cs = false
    end
end)

-- Handle drag and drop
windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked or not bar_sets then
        return
    end

    -- Mouse drag
    if type == 0 then
        if dragged then
            local d_x = 0
            local d_y = 0
            if drag_snap_key_down then
                -- snap
                d_x = math.floor(((x - dragged.x) + dragged.bars[1].x)/10)*10 - dragged.bars[1].x
                d_y = math.floor(((y - dragged.y) + dragged.bars[1].y)/10)*10 - dragged.bars[1].y
            else
                -- no snap
                d_x = x - dragged.x
                d_y = y - dragged.y
            end

            d_x,d_y=move_group(dragged.bars,d_x,d_y,dragged.constrain)
            dragged.x = dragged.x + d_x
            dragged.y = dragged.y + d_y
            return true
        end

    -- Mouse left click
    elseif type == 1 then
        for group_index, s in ipairs(bar_sets) do
            for _, b in ipairs(s) do
                local allowed=not state.setup or state.setup_scope=='individual' or
                    state.setup_scope=='all' or state.setup_scope==b.frame_name
                if allowed and bars.hover(b, x, y) and (state.setup or not settings[frame_names[group_index]..'_bar'].locked) then
                    local group=s
                    local constrain=settings[frame_names[group_index]..'_bar'].bounds~=false
                    if state.setup and state.setup_scope=='all' then
                        group={}; constrain=false
                        for i,set in ipairs(bar_sets) do
                            constrain=constrain or settings[frame_names[i]..'_bar'].bounds~=false
                            for _,part in ipairs(set) do group[#group+1]=part end
                        end
                    end
                    dragged = {bars = group, x = x , y = y, constrain=constrain}
                    return true
                end
            end
        end

    -- Mouse left release
    elseif type == 2 then
        if dragged then
            save_positions()
            dragged = nil
            return true
        end
    end

    return false
end)
windower.register_event('keyboard', function(dik, down) -- lol diks
    if dik == 29 or dik == 157 then -- left/right Ctrl
        snap_keys[dik]=down
        drag_snap_key_down=snap_keys[29] or snap_keys[157] or false
    end
end)

if windower.ffxi.get_info().logged_in then
    player_id = windower.ffxi.get_player().id
    party_members = {}
end

defaults = require('defaultPreset')()
settings_old = config.load({})
for _, name in ipairs({'target','subtarget','focustarget','aggro'}) do
    local frame = defaults[name..'_bar']
    frame.pos = default_bar_position(name, frame)
end
if settings_old.pos then
    -- settings.pos was the old position setting. if it's set that means we're upgrading from 1.0
    defaults.target_bar.pos = settings_old.pos
    defaults.target_bar.font = settings_old.font
    defaults.subtarget_bar.font = settings_old.font
    defaults.target_bar.font_size = settings_old.font_size
    defaults.subtarget_bar.font_size = settings_old.font_size
end
settings = config.load(defaults)
-- Seed split clocks from each old saved shared period once; preserve experimentation.
for _,name in ipairs(frame_names) do
    local old=settings_old[name..'_bar']
    if old and old.pulse_period then
        for _,key in ipairs({'foreground_period','underbar_period'}) do
            if old[key]==nil then settings[name..'_bar'][key]=old.pulse_period end
        end
    end
end
-- A: adopt the requested native subtarget/focus presets once for existing
-- installs. A saved revision marker preserves later user color/skin edits.
local migrated=false
for _,name in ipairs({'subtarget','focustarget'}) do
    local old=settings_old[name..'_bar']
    local frame=settings[name..'_bar']
    if old and not old.native_style_revision then
        frame.skin='ffxi'
        frame.color={alpha=frame.color.alpha or 255,red=defaults[name..'_bar'].color.red,
            green=defaults[name..'_bar'].color.green,blue=defaults[name..'_bar'].color.blue}
        migrated=true
    end
    frame.native_style_revision=1
end
if migrated then settings:save() end
config.register(settings, initialize_bars)

cache_party_members()
