-- Awake: detached, one-shot closing glints using BarFiller2's original arm sprites.
-- Queue at observed death so compact bars may hide before the trail closes.
local images=require('images')
local spark={}
local active={}
local function arm(name)
    return images.new({pos={x=0,y=0},visible=false,size={width=1,height=1},
        color={alpha=0,red=255,green=255,blue=255},
        texture={path=windower.addon_path..'assets/ffxi/'..name..'.png',fit=true},
        repeatable={x=1,y=1},draggable=false})
end
local function destroy(s)
    for _,p in ipairs(s.parts) do p:destroy() end
end
function spark.spawn(x,y,options,bar_alpha,clock,delay)
    if not options.death_spark or options.death_spark_alpha<=0 or bar_alpha<=0 then return end
    clock=clock or os.clock
    active[#active+1]={x=x,y=y,clock=clock,born=clock()+(delay or 0),
        duration=options.death_spark_duration,size=options.death_spark_size,
        alpha=bar_alpha*options.death_spark_alpha/255,
        parts={arm('sparkle_gain_arm_h'),arm('sparkle_gain_arm_v')}}
end
function spark.update()
    for i=#active,1,-1 do
        local s=active[i]
        local age=s.clock()-s.born
        if age>=s.duration then
            destroy(s);table.remove(active,i)
        elseif age>=0 then
            local p=age/s.duration
            -- Fast bloom, longer release; a single envelope has no pulse clock.
            local bloom=p<.2 and p/.2 or (1-p)/.8
            local alpha=math.floor(s.alpha*bloom+.5)
            local length=s.size*(.35+.65*math.sqrt(bloom))
            local thickness=math.max(1,math.min(3,s.size*3/16))
            local widths={length,thickness}
            local heights={thickness,length*.75}
            for j,part in ipairs(s.parts) do
                part:pos(s.x-widths[j]/2,s.y-heights[j]/2)
                part:size(widths[j],heights[j])
                part:alpha(alpha)
                -- Geometry and opacity are ready before a primitive is revealed.
                part:visible(alpha>0)
            end
        end
    end
end
function spark.clear()
    for _,s in ipairs(active) do destroy(s) end
    active={}
end
return spark
