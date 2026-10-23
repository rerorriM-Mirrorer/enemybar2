-- A: exercise the actual command handlers without starting a game client.
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
local channels={}
windower={add_to_chat=function(channel,s) logs[#logs+1]=s;channels[#channels+1]=channel end}
package.preload.chat=function()
    function string:color(id) return '['..id..']'..self end
    return {}
end
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
local help_text=require('helpText')
local animation_preset=require('animationPreset')
local lifecycle=require('lifecycle').new(function() lifecycle_cleaned=(lifecycle_cleaned or 0)+1 end,
    function(command) lifecycle_commands=lifecycle_commands or {};lifecycle_commands[#lifecycle_commands+1]=command end,
    function(message) windower.add_to_chat(207,message) end)
local state={setup=false,in_cs=false}
]]
assert(loadstring(prelude..source:sub(first,last-1)))()
assert(settings.target_bar.shake_style=='classic')
assert(settings.target_bar.ghost_glow)
assert(settings.target_bar.ghost_lift_up==0 and settings.target_bar.ghost_fade_duration==1)
assert(settings.target_bar.underbar_flare_height==45 and settings.target_bar.underbar_glow_alpha==50)
assert(settings.target_bar.foreground_period==.1 and settings.target_bar.foreground_flash_alpha==0)
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
handle_command('preview','hp','5') -- bare frame was the reported regression
assert(preview_args[2]==100 and preview_args[4]==5)
handle_command('preview','hp','50')
assert(preview_args[2]==100 and preview_args[4]==50)
handle_command('preview','ghost')
assert(preview_args[2]==100 and preview_args[4]==nil)
handle_command('preview','kill')
assert(preview_args[5]=='kill' and preview_args[6]==true)
handle_command('preview','spark')
assert(preview_args[5]=='spark' and preview_args[6]==true)
handle_command('death_spark','off','a')
assert(not settings.aggro_bar.death_spark and settings.target_bar.death_spark)
handle_command('death_spark_size','24')
handle_command('death_spark_duration','.3')
assert(settings.target_bar.death_spark_size==24 and settings.target_bar.death_spark_duration==.3)
handle_command('preview','heal','ft')
assert(preview_args[5]=='heal' and preview_args[6]==false)
handle_command('healing_glow','off')
assert(settings.target_bar.healing_glow==false)
handle_command('healing_glow','on')
handle_command('healing_flare_height','32')
assert(settings.target_bar.healing_glow and settings.target_bar.healing_flare_height==32)
handle_command('preview','hp','10','st')
assert(preview_args[2]==20 and preview_args[4]==10)
preview_args=nil
handle_command('preview','hp','0');handle_command('preview','hp','5.5')
handle_command('preview','hp','101');handle_command('preview','hp','nan')
assert(preview_args==nil)
handle_command('foreground_flash_color','20','40','60','all')
assert(settings.target_bar.foreground_flash_color.green==40)
assert(settings.target_bar.foreground_flash_color~=settings.aggro_bar.foreground_flash_color)
handle_command('foreground_flash_alpha','80','t')
handle_command('ghost_fade_to','trail','all')
handle_command('ghost_height_mode','smooth')
handle_command('underbar_size_mode','fixed')
handle_command('ghost_glow_flicker','off')
assert(settings.target_bar.foreground_flash_alpha==80 and settings.target_bar.ghost_fade_to=='trail')
assert(settings.target_bar.ghost_height_mode=='smooth' and settings.target_bar.underbar_size_mode=='fixed')
assert(not settings.target_bar.ghost_glow_flicker)
old=saved
handle_command('foreground_flash_alpha','1.5');handle_command('foreground_flash_color','256','0','0')
handle_command('ghost_fade_to','red');handle_command('underbar_size_reference','0')
assert(saved==old)
handle_command(nil);assert(channels[#channels]==0)
handle_command('help','flash')
assert(logs[#logs]:find('[200]//eb ',1,true) and channels[#channels]==0)
handle_command('unknown-command');assert(channels[#channels]==0)
handle_command('setup','on');assert(logs[#logs]:find('Ctrl',1,true))
handle_command('setup','off')
settings.target_bar.width=777
handle_command('defaults','animations','t')
assert(settings.target_bar.width==777 and settings.target_bar.foreground_flash_alpha==0)
assert(settings.target_bar.ghost_fade_to=='white' and settings.target_bar.underbar_size_mode=='scaled')
assert(settings.target_bar.ghost_height_mode=='snap' and settings.target_bar.ghost_glow_flicker)
assert(saved==recreated and saved>0)
assert(settings.target_bar.pos.x==460 and settings.target_bar.pos.y==688)
assert(settings.target_bar.text_duration==1.2 and settings.target_bar.ghost_fade_duration==1)

handle_command('death_spark_style','classic','all')
assert(settings.target_bar.death_spark_style=='classic' and settings.aggro_bar.death_spark_style=='classic')
handle_command('death_spark_style','vivid')
handle_command('death_spark_h_cap','4')
handle_command('death_spark_v_cap','9','a')
assert(settings.target_bar.death_spark_h_cap==4 and settings.aggro_bar.death_spark_v_cap==9)
local before=saved
handle_command('death_spark_h_cap','0')
handle_command('death_spark_v_cap','17')
handle_command('death_spark_style','bad')
assert(saved==before)

local old=saved
handle_command('distance_style','wrong')
handle_command('distance_x','nan');handle_command('distance_y','501')
assert(saved==old)
handle_command('distance_style','DEFAULT','all')
assert(settings.target_bar.distance_style=='default' and settings.aggro_bar.distance_style=='default')
handle_command('distance_style','distanceplus')
handle_command('distance_x','-4')
handle_command('distance_y','2','st')
assert(settings.target_bar.distance_x==-4 and settings.subtarget_bar.distance_y==2)
handle_command('defaults','animations','all')
assert(settings.target_bar.distance_style=='distanceplus' and settings.target_bar.distance_x==-4)

handle_command('restart');handle_command('restart');handle_command('unload')
assert(lifecycle_cleaned==1 and #lifecycle_commands==1 and lifecycle_commands[1]=='lua reload enemybar2')
print('impact_commands_spec: defaults, forms, validation, reports and preserved tuning passed')
