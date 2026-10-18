-- A: preview bars have separate identities/lifetimes from combat bars.
local preview={}
local animation_settings=require('animationSettings')
local ghost_motion=require('ghostMotion')
local active
local function copy(t)
    local out={}
    for k,v in pairs(t) do out[k]=type(v)=='table' and copy(v) or v end
    return out
end
function preview.clear()
    if active then bars.destroy(active.bar);active=nil end
end
function preview.start(frame,x,y,hpp,mode,main_bar)
    preview.clear()
    local options=copy(frame)
    mode=mode or (hpp and 'hp' or 'ghost')
    options.pos={x=x,y=y};options.ghost_hit=mode=='ghost' or mode=='kill'
    if mode=='spark' then options.death_spark=true end
    local label=({hp='HP Preview',ghost='Ghost Preview',heal='Healing Preview',kill='Killing Hit Preview',spark='Death Sparkle Preview'})[mode]
    options.show_dist,options.show_target,options.show_target_icon=false,false,false
    options.show_action,options.show_debuff=false,false
    local b=bars.new(options,main_bar~=false)
    local death=mode=='kill' or mode=='spark'
    local initial=mode=='heal' and 35 or (death and 20 or 100)
    local final=mode=='heal' and 85 or (death and 0 or (hpp or 20))
    bars.update_target(b,label,initial,0,nil,'preview')
    bars.show(b)
    bars.update_target(b,label,final,0,nil,'preview')
    local duration=ghost_motion.duration(animation_settings.snapshot(options))
    local lifetime=mode=='hp' and 8 or math.max(duration,(options.trail_delay or 1.5)+(options.trail_duration or .45),options.heal_duration or .35,
        .15+(options.death_spark_duration or .2))+.3
    active={bar=b,expires=os.clock()+lifetime}
end
function preview.update()
    if not active then return end
    if os.clock()>=active.expires then preview.clear() else bars.show(active.bar) end
end
return preview
