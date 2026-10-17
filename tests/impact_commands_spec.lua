-- Awake: exercise the actual command handlers without starting a game client.
package.path='./?.lua;'..package.path
function S(t)
    function t:contains(value)
        for _,v in ipairs(self) do if v==value then return true end end
        return false
    end
    return t
end
function L(t) return t end
function string:split(delimiter)
    local result={}
    for v in self:gmatch('[^'..delimiter..']+') do result[#result+1]=v end
    return result
end
local logs={}
windower={add_to_chat=function(_,s) logs[#logs+1]=s end}
_addon={version='test'}
settings=require('defaultPreset')()
for _,frame in pairs(settings) do frame.pos={x=460,y=688} end
local saved,recreated=0,0
function settings:save() saved=saved+1 end
function initialize_bars() recreated=recreated+1 end
local source=assert(io.open('enemybar2.lua')):read('*a')
local first=assert(source:find('local function valid_rgb',1,true))
local last=assert(source:find("windower.register_event('prerender'",first,true))
local prelude=[[local frame_names={'target','subtarget','focustarget','aggro'}
local animation_settings=require('animationSettings')
local animation_preview={start=function(...) preview_args={...} end,clear=function() end}
local state={setup=false,in_cs=false}
]]
assert(loadstring(prelude..source:sub(first,last-1)))()
assert(settings.target_bar.shake_style=='impact')
assert(settings.target_bar.ghost_glow)
assert(settings.target_bar.ghost_lift_up==1 and settings.target_bar.ghost_fade_duration==2.5)
assert(settings.target_bar.text_duration==1.2 and settings.aggro_bar.width==100)
assert(settings.target_bar.ghost_glow_color~=settings.aggro_bar.ghost_glow_color)
handle_command('shake_super_px','12')
assert(settings.target_bar.shake_super_px==12 and settings.aggro_bar.shake_super_px==8)
handle_command('shake_step','0.04','all')
assert(settings.target_bar.shake_step==.04 and settings.aggro_bar.shake_step==.04)
handle_command('shake_hold','st','0.08') -- frame-first shorthand
assert(settings.subtarget_bar.shake_hold==.08)
handle_command('set','shake_horizontal','ft','0.5') -- legacy
assert(settings.focustarget_bar.shake_horizontal==.5)
handle_command('ghost_glow','off','all')
assert(not settings.target_bar.ghost_glow and not settings.aggro_bar.ghost_glow)
handle_command('ghost_glow')
assert(settings.target_bar.ghost_glow and not settings.aggro_bar.ghost_glow)
handle_command('ghost_glow_color','255','20','80','t')
assert(settings.target_bar.ghost_glow_color.red==255 and settings.target_bar.ghost_glow_color.blue==80)
handle_command('ghost_glow_alpha','200','a')
assert(settings.aggro_bar.ghost_glow_alpha==200)
handle_command('shake_style','classic','t')
assert(settings.target_bar.shake_style=='classic')
handle_command('super_settle','both','t')
assert(settings.target_bar.super_settle=='both')
local old=saved
for _,args in ipairs({{'shake_step','0'},{'shake_style','wobble'},
    {'ghost_glow_alpha','1.5'},{'ghost_contact_duration','-1'},
    {'ghost_glow_color','256','1','2'},{'ghost_glow_color','1','2'},
    {'ghost_flare_width','1','unknown'}}) do
    handle_command(unpack(args))
end
assert(saved==old)
handle_command('ghost_glow_color')
assert(logs[#logs]:find('255 20 80',1,true))
handle_command('ghost_glow_alpha','all')
assert(logs[#logs]:find('aggro ghost_glow_alpha 200',1,true))
handle_command('help');handle_command('status')
handle_command('underbar_glow','off','all')
assert(not settings.target_bar.underbar_glow and not settings.aggro_bar.underbar_glow)
handle_command('underbar_glow','on','t')
handle_command('underbar_flare_width','7','t')
handle_command('underbar_glow_alpha','0','all')
assert(settings.target_bar.underbar_glow and settings.target_bar.underbar_flare_width==7)
assert(settings.aggro_bar.underbar_glow_alpha==0)
old=saved
handle_command('underbar_glow_alpha','1.5')
handle_command('underbar_flare_height','101')
assert(saved==old)
bar_sets={{{x=100,y=200}},{{x=20,y=30}},{{x=30,y=40}},{{x=40,y=50}}}
handle_command('preview','hp','5','t')
assert(preview_args[2]==100 and preview_args[3]==200 and preview_args[4]==5)
preview_args=nil
handle_command('preview','hp','0');handle_command('preview','hp','5.5')
handle_command('preview','hp','101');handle_command('preview','hp','nan')
assert(preview_args==nil)
assert(saved==recreated and saved>0)
assert(settings.target_bar.pos.x==460 and settings.target_bar.pos.y==688)
assert(settings.target_bar.text_duration==1.2 and settings.target_bar.ghost_fade_duration==2.5)
print('impact_commands_spec: defaults, forms, validation, reports and preserved tuning passed')
