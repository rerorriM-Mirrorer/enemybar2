-- A: Cioara-inspired initial layout, measured against each client's UI.
-- This is applied only while seeding defaults; saved coordinates win afterward.
local layout={}
function layout.position(name,frame,ui)
    local screen_width=ui.ui_x_res
    local screen_height=ui.ui_y_res
    local x=math.floor((screen_width-frame.width)/2)
    local y=80
    if name=='subtarget' then
        x=x-10; y=100
    elseif name=='focustarget' then
        x=x-15; y=math.floor(screen_height*5/6+0.5)
    elseif name=='aggro' then
        x=math.min(screen_width-frame.width-12,math.floor(screen_width/2+200))
        y=100
    end
    return {x=math.max(0,x),y=math.max(0,math.min(y,screen_height-24))}
end
return layout
