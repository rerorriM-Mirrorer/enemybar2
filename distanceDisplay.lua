-- A: DistancePlus Default semantics, with no action-specific range assumptions.
local distance={}
function distance.value(target)
    local squared=target and target.distance
    if type(squared)~='number' or squared~=squared or squared<0 or squared==math.huge then return nil end
    return math.sqrt(squared)
end
function distance.style(value,base_size)
    local close=value and value<=22
    local color={254,251,255}
    if value and value>30 then color={88,85,132}
    elseif value and value>22 then color={161,159,206} end
    return color,base_size+(close and 1 or 0)
end
function distance.text_style(bar)
    if bar.distance_style=='default' then
        return {size=math.max(1,math.floor(bar.font_size*.8+.5)),font=bar.font,
            bold=bar.bold,italic=bar.italic,
            stroke={width=2,alpha=180,red=bar.gauge and 12 or 50,green=bar.gauge and 12 or 50,blue=bar.gauge and 12 or 50}}
    end
    return {size=11,font='Verdana',bold=false,italic=false,
        stroke={width=1,alpha=255,red=20,green=10,blue=12}}
end
return distance
