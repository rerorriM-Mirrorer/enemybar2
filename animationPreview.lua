-- Awake: preview bars have separate identities/lifetimes from combat bars.
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
function preview.start(frame,x,y,hpp)
    preview.clear()
    local options=copy(frame)
    options.pos={x=x,y=y};options.ghost_hit=hpp==nil
    local label=hpp and 'HP Preview' or 'Ghost Preview'
    options.show_dist,options.show_target,options.show_target_icon=false,false,false
    options.show_action,options.show_debuff=false,false
    local b=bars.new(options)
    bars.update_target(b,label,100,0,nil,'preview')
    bars.show(b)
    bars.update_target(b,label,hpp or 20,0,nil,'preview')
    local duration=ghost_motion.duration(animation_settings.snapshot(options))
    active={bar=b,expires=os.clock()+(hpp and 8 or math.max(duration,(options.trail_delay or 1.5)+(options.trail_duration or .45))+.3)}
end
function preview.update()
    if not active then return end
    if os.clock()>=active.expires then preview.clear() else bars.show(active.bar) end
end
return preview
