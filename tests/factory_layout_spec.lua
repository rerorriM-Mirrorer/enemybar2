-- A: fresh-install geometry and detached ghost motion for the Cioara preset.
-- Mock-free pure Lua 5.1 tests; real Windower frames still need live acceptance.
package.path='./?.lua;'..package.path
local preset=require('defaultPreset')()
local layout=require('factoryLayout')
local ghost=require('ghostMotion')
local animation=require('animationPreset')
local t,st,ft,a=preset.target_bar,preset.subtarget_bar,preset.focustarget_bar,preset.aggro_bar

assert(t.width==800 and st.width==400 and ft.width==250 and a.width==200)
assert(t.show_target and a.show_target and a.stack_dir=='up' and a.stack_padding==20)
assert(t.show_dist and t.distance_style=='default' and t.distance_x==-24 and t.distance_y==9)
assert(t.ghost_lift_up==0 and t.ghost_drift_up==-1)
assert(t.ghost_lift_right==0 and t.ghost_drift_right==1)
assert(t.ghost_height_mode=='snap' and t.ghost_glow_flicker and t.ghost_fade_to=='white')
assert(st.pulse_period==.3 and ft.pulse_period==.3 and a.pulse_period==.3)
assert(t.font_size==14 and t.bold and t.italic and t.skin=='ffxi')
local large={ui_x_res=3840,ui_y_res=2160}
local compact={ui_x_res=1280,ui_y_res=720}
local function check(ui,frame,name,x,y)
    local p=layout.position(name,frame,ui)
    assert(p.x==x and p.y==y,name..' at '..ui.ui_x_res..': '..p.x..'/'..p.y)
end
check(large,t,'target',1490,80)
check(large,st,'subtarget',1710,100)
check(large,ft,'focustarget',1780,1800)
check(large,a,'aggro',2120,100)
check(compact,t,'target',210,80)
check(compact,st,'subtarget',430,100)
check(compact,ft,'focustarget',500,600)
check(compact,a,'aggro',840,100)
-- On tiny client windows the initial-width cap in enemybar2.lua runs
-- before this position calculation; avoid negative positions here too.
local tiny={ui_x_res=640,ui_y_res=360}
local capped={width=600}
check(tiny,capped,'target',0,80)
local p=ghost.sample(t,.9) -- stationary lift phase finished
assert(math.abs(p.y)<1e-8)
p=ghost.sample(t,1.4) -- halfway through the one-pixel downward drift
assert(math.abs(p.y-.5)<1e-8)
p=ghost.sample(t,1.899) -- approaching the final grounded position
assert(p.y>.9 and p.y<1.01)
-- Preset resets may change animation settings; layout, visibility and
-- distance presentation remain personal choices.
t.width=777;t.show_target=false;t.distance_x=12
animation.apply(preset,'target')
assert(t.width==777 and not t.show_target and t.distance_x==12)
assert(t.ghost_lift_up==0 and t.ghost_drift_up==-1)
print('factory_layout_spec: 2026-11-10 Cioara appearance, positioning, and subtle ghost motion passed')
