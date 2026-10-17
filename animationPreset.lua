-- Awake: explicit opt-in adoption of baked animation defaults, preserving layout.
local preset={}
local animation_settings=require('animationSettings')
local function copy(v)
    if type(v)~='table' then return v end
    local result={};for k,x in pairs(v) do result[k]=copy(x) end;return result
end
function preset.apply(settings,frame)
    local source=require('defaultPreset')()
    local keys={'animation_duration','damage_trail','trail_delay','trail_duration','trail_color',
        'healing_effect','text_effect','hit_shake','low_hp_pulse','ghost_hit',
        'heal_duration','text_duration','pulse_period'}
    for k in pairs(animation_settings.defaults) do keys[#keys+1]=k end
    for _,name in ipairs({'target','subtarget','focustarget','aggro'}) do
        if name==frame or frame=='all' then
            for _,key in ipairs(keys) do settings[name..'_bar'][key]=copy(source[name..'_bar'][key]) end
        end
    end
end
return preset
