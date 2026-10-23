-- A: BattleStations-style chat-only help, with independently colored fragments.
require('chat')
local help={}
local sections={}
local order={'general','flash','ghost','underbar','shake','timing','layout','appearance'}
local function add(topic,syntax,description)
    sections[topic]=sections[topic] or {}
    sections[topic][#sections[topic]+1]={syntax,description}
end
local function numeric(topic,name,units,description)
    add(topic,name..' <'..units..'> [bar]',description)
end
local function toggle(topic,name,description)
    add(topic,name..' [on/off] [bar]',description..'; bare toggles')
end
add('general','help [topic]','Topics: general, flash, ghost, underbar, shake, timing, layout, appearance, all')
add('general','distance [on/off] [bar]','Client distance at right tip; near <=22, mid <=30, far >30')
add('general','distance_style <default|distanceplus> [bar]','Bar text style or regular Verdana 11')
add('general','distance_x <pixels> [bar]','Horizontal offset from right-tip anchor; -500..500')
add('general','distance_y <pixels> [bar]','Vertical offset; positive moves down; -500..500')
add('general','near <yalms> [bar]','Near cutoff and enlargement; default22; alias distance_near')
add('general','far <yalms> [bar]','Mid/far cutoff; default30; alias distance_far')
add('general','distance_close_x <pixels> [bar]','Near-only right nudge after centered growth; default2')
add('general','distance_close_y <pixels> [bar]','Near-only down nudge; default1')
add('general','status','Version, layout, switches and animation settings')
add('general','restart','Clean up and reload EnemyBar2 once')
add('general','unload','Clean up and unload EnemyBar2 once')
add('general','defaults animations [bar]','Apply baked animation preset; retain positions, widths and fonts')
add('general','preview ghost [bar]','Replay a large hit with the configured ghost')
add('general','preview kill [bar]','Replay a small finishing-hit ghost')
add('ghost','death_spark_style <classic|vivid> [bar]','Original glint or fuller arms and brighter release')
numeric('ghost','death_spark_h_cap','1..16','Vivid horizontal arm thickness cap in pixels')
numeric('ghost','death_spark_v_cap','1..16','Vivid vertical arm thickness cap in pixels')
add('general','preview spark [bar]','Show the closing death sparkle without a ghost')
add('general','preview heal [bar]','Replay recovery; new glow/flares appear on main only')
add('general','preview hp <1..100> [bar]','Show chosen HP for8s, with no detached ghost')
add('general','preview off','Close the demonstration; detached ghosts finish')
add('general','set <setting> <bar> <value(s)>','Legacy setting syntax')
numeric('flash','foreground_period','seconds','Full foreground flash cycle at <=10% HP')
add('flash','foreground_flash_color <r> <g> <b> [bar]','Alternate foreground RGB; integer channels0..255')
numeric('flash','foreground_flash_alpha','0..255','Alternate foreground opacity;0 gives pink/off')
numeric('flash','underbar_period','seconds','Full red-only underbar cycle at <=50% HP')
numeric('flash','pulse_period','seconds','Set both foreground and underbar clocks')
toggle('flash','low_hp_pulse','Low-health feedback on both layers')
toggle('ghost','ghost_hit','Detached chunk on loss>=75 HP points or any observed killing hit')
add('ghost','ghost_fade_to <white|trail> [bar]','Keep chunk white, or return toward red while fading')
add('ghost','ghost_height_mode <off|snap|smooth> [bar]','Height flicker synchronized with ghost opacity')
numeric('ghost','ghost_height_min','0..1','Minimum height fraction during flicker')
numeric('ghost','ghost_height_strength','0..1','Height modulation strength;0 keeps height steady')
toggle('ghost','ghost_glow_flicker','Synchronize glow/flare opacity with the chunk')
for _,row in ipairs({{'ghost_lift_up','Initial upward distance'},{'ghost_lift_right','Initial rightward distance'},
    {'ghost_drift_up','Upward travel during fade'},{'ghost_drift_right','Rightward travel during fade'},
    {'ghost_glow_height','Maximum glow extension above and below chunk'},
    {'ghost_flare_height','Maximum upward flare extension'},{'ghost_flare_width','Each edge flare width'}}) do
    numeric('ghost',row[1],'pixels',row[2])
end
for _,row in ipairs({{'ghost_lift_duration','Initial lift duration'},{'ghost_hover_duration','Hover duration'},
    {'ghost_fade_duration','Final fade duration'},{'ghost_contact_duration','White contact hold'},
    {'ghost_glow_duration','Glow contraction time, capped by ghost lifetime'},
    {'ghost_period','Opacity cycle;0 disables flicker'}}) do numeric('ghost',row[1],'seconds',row[2]) end
for _,row in ipairs({{'ghost_alpha','Maximum chunk opacity'},{'ghost_glow_alpha','Glow opacity'},
    {'ghost_flare_alpha','Flare opacity'}}) do numeric('ghost',row[1],'0..255',row[2]) end
toggle('ghost','ghost_glow','Soft ghost glow and both flares')
add('ghost','ghost_glow_color <r> <g> <b> [bar]','Glow RGB; flares use a paler version')
toggle('underbar','underbar_glow','Glow/flares on exposed red interval')
add('underbar','underbar_size_mode <fixed|scaled> [bar]','Fixed maximum size, or follow exposed interval width')
numeric('underbar','underbar_size_reference','1..100','Percent of gauge exposed where maximum size is reached')
for _,row in ipairs({{'underbar_glow_height','Maximum middle glow extension'},
    {'underbar_flare_height','Maximum upward flare extension'},{'underbar_flare_width','Maximum flare width'},
    {'underbar_glow_min_height','Minimum middle extension'},{'underbar_flare_min_height','Minimum flare extension'},
    {'underbar_flare_min_width','Minimum flare width, limited by available space'}}) do
    numeric('underbar',row[1],'pixels',row[2])
end
numeric('underbar','underbar_height_curve','0.1..4','Below1 retains height longer as interval shrinks')
numeric('underbar','underbar_width_curve','0.1..4','1 is linear width scaling')
numeric('underbar','underbar_glow_alpha','0..255','Middle glow opacity, limited by trail opacity')
numeric('underbar','underbar_flare_alpha','0..255','Edge flare opacity, limited by trail opacity')
numeric('underbar','trail_alpha','0..255','Base red-trail opacity')
add('underbar','trail_color <r> <g> <b> [bar]','Base trail RGB, retaining saved opacity')
add('shake','shake_style <impact|classic> [bar]','Decreasing held rebounds, or prior fixed sequence')
add('shake','super_settle <off|small|both> [bar]','Super-hit settling phases')
for _,name in ipairs({'shake_small_px','shake_large_px','shake_super_px'}) do numeric('shake',name,'pixels','Impact-mode displacement') end
for _,name in ipairs({'shake_hold','shake_step'}) do numeric('shake',name,'seconds','Impact-mode hold timing') end
for _,name in ipairs({'shake_rebound','shake_decay','shake_horizontal'}) do numeric('shake',name,'ratio','Impact-mode rebound/decay/horizontal tuning') end
for _,name in ipairs({'animation_duration','trail_delay','trail_duration','heal_duration','text_duration'}) do
    numeric('timing',name,'seconds','Fill / trail hold / trail slide / healing / numeric count timing')
end
for _,name in ipairs({'damage_trail','healing_effect','text_effect','hit_shake'}) do toggle('timing',name,'Animation switch') end
add('layout','setup [bar] [on/off]','Individual drag; explicit all moves arrangement. edit/move are aliases')
add('layout','pos <x> <y> [bar]','Set and save position')
add('layout','resetpos [bar]','Recover chosen group on screen')
add('layout','lock [bar]','Lock normal dragging; default all')
add('layout','unlock [bar]','Unlock normal dragging; default all')
toggle('layout','bounds','Keep gauge geometry within the client')
add('layout','stack [up/down]','Aggro direction; bare toggles')
numeric('layout','spacing','pixels','Aggro row spacing')
add('layout','count <1..32> a','Maximum aggro rows')
numeric('appearance','width','pixels','Configured gauge width')
add('appearance','color <r> <g> <b> [bar]','Normal fill RGB, retaining its opacity')
numeric('appearance','background_alpha','0..255','Empty trough opacity')
add('appearance','font "name" [bar]','Text font')
numeric('appearance','fontsize','size','Text size')
for _,name in ipairs({'bold','italic','targetof','targeticon','action','distance','debuffs'}) do toggle('appearance',name,'Text/indicator switch') end
add('appearance','skin <ffxi|classic> [bar]','Native renderer or original skin')
add('appearance','show [bar]','Enable a bar group')
add('appearance','hide [bar]','Hide a bar group')
add('appearance','ft [name/id/clear]','Pin focus; bare pins current target')

local function color(text,id) return text:color(id) end
function help.show(topic)
    topic=topic and topic:lower() or 'all'
    if topic~='all' and not sections[topic] then
        windower.add_to_chat(0,color('Unknown help topic; showing all commands.',0));topic='all'
    end
    windower.add_to_chat(0,color('----- EnemyBar2 -----',140))
    windower.add_to_chat(0,color('[bar] t/st/ft/a/all; default t. Omit numeric/color/style values to report.',0))
    for _,name in ipairs(order) do
        if topic=='all' or topic==name then
            windower.add_to_chat(0,color(name:upper(),167))
            for _,row in ipairs(sections[name]) do
                windower.add_to_chat(0,color('//eb ',200)..color(row[1],207)..color(' -> ',200)..color(row[2],0))
            end
            if name=='layout' then
                windower.add_to_chat(0,color('Ctrl+drag: snap the dragged group to a 10px grid; mouse release saves. setup all preserves relative offsets.',0))
            end
        end
    end
end
return help
