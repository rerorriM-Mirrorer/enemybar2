-- Awake: clamp a whole arrangement by one delta, preserving relative spacing.
-- Oversized arrangements stay anchored at an edge; widths are never rewritten.
local layout = {}
function layout.bounds(group)
    local left,top,right,bottom = math.huge,math.huge,-math.huge,-math.huge
    for _, b in ipairs(group) do
        left=math.min(left,b.x-(b.show_target_icon and 16 or 0))
        top=math.min(top,b.y-(b.show_action and b.font_size or 0))
        right=math.max(right,b.x+(b.gauge and b.gauge.width or b.width+2))
        bottom=math.max(bottom,b.y+math.max(12,b.font_size*2))
    end
    return left,top,right,bottom
end
function layout.clamp(group,dx,dy,width,height)
    if #group==0 then return dx,dy end
    local l,t,r,b=layout.bounds(group)
    local function axis(delta,first,last,limit)
        if last-first>limit then return -first end
        return math.max(-first,math.min(limit-last,delta))
    end
    return axis(dx,l,r,width),axis(dy,t,b,height)
end
function layout.center(group,width,height)
    local l,t,r,b=layout.bounds(group)
    return math.floor((width-(r-l))/2)-l,math.floor((height-(b-t))/2)-t
end
return layout
