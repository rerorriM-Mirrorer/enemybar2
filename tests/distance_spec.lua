-- A: real display wiring with mocked text/image primitives; no game required.
package.path='./?.lua;'..package.path
local display=require('distanceDisplay')
assert(display.value({distance=625,x=999,y=999})==25)
assert(display.value({distance=0})==0)
for _,target in ipairs({{}, {distance=-1}, {distance='25'}, {distance=math.huge}, {distance=0/0}}) do
    assert(display.value(target)==nil)
end
assert(display.value(nil)==nil)
local objects={}
local function primitive(template,settings)
    local p={shown=false,font_size=10,text_value='',template=template,settings=settings}
    if settings then p.font_size=settings.text.size end
    function p:pos(x,y) self.x,self.y=x,y end
    function p:extents() return #(self.dist or '')*self.font_size*.6,self.font_size end
    function p:size(n) self.font_size=n end
    function p:color(r,g,b) self.rgb={r,g,b} end
    function p:show() self.shown=true end
    function p:hide() self.shown=false end
    function p:destroy() self.destroyed=true end
    function p:hover() return false end
    function p:width() end
    objects[#objects+1]=p
    return p
end
images={new=primitive};texts={new=primitive}
package.loaded.images=images;package.loaded.texts=texts
windower={addon_path='./',get_windower_settings=function() return {ui_x_res=1280,ui_y_res=720} end}
require('bars')
local f=require('defaultPreset')().target_bar
f.skin='classic';f.pos={x=400,y=500};f.width=400;f.font_size=14;f.show_dist=true
local b=bars.new(f,true)
bars.update_target(b,'Target',80,22,1,123)
assert(b.distance_text.dist=='22.0' and b.distance_text.font_size==12)
assert(b.distance_text.rgb[1]==254 and b.distance_text.rgb[2]==251)
assert(b.distance_text.x==-488 and b.distance_text.y==499.5)
assert(b.distance_text.settings.text.font=='Verdana')
assert(not b.distance_text.settings.flags.bold and not b.distance_text.settings.flags.italic)
assert(b.distance_text.settings.text.stroke.width==1)
assert(not b.distance_text.template:find("'",1,true))
local w=b.distance_text:extents()
assert(b.action_text.x==-484 and b.action_text.y==488)
bars.update_distance(b,22.0001)
assert(b.distance_text.font_size==11 and b.distance_text.rgb[1]==161)
bars.update_distance(b,30)
assert(b.distance_text.rgb[1]==161)
bars.update_distance(b,30.0001)
assert(b.distance_text.rgb[1]==88)
bars.update_distance(b,0)
assert(b.distance_text.font_size==12 and b.distance_text.dist=='0.0')
bars.update_distance(b,nil)
assert(b.distance_text.dist=='--' and b.distance_text.font_size==11)
bars.move(b,200,300)
assert(b.distance_text.x==200+400-8-1280 and b.distance_text.y==300)
bars.x_res=960;bars.move(b,200,300)
assert(b.distance_text.x==200+400-8-960)
b.distance_x=5;b.distance_y=-3;bars.move(b,200,300)
assert(b.distance_text.x==200+400-8+5-960 and b.distance_text.y==297)
bars.show(b);assert(b.distance_text.shown)
bars.hide(b);assert(not b.distance_text.shown)
b.show_dist=false;bars.move(b,200,300)
assert(b.action_text.x==200+400-4-960)
bars.show(b);assert(not b.distance_text.shown)
bars.destroy(b)
f.distance_style='default';f.bold=true;f.italic=true;f.font='Arial'
local regular=bars.new(f,true)
assert(regular.distance_text.settings.text.font=='Arial')
assert(regular.distance_text.settings.flags.bold and regular.distance_text.settings.flags.italic)
assert(regular.distance_text.settings.text.stroke.width==2)
bars.destroy(regular)
for _,o in ipairs(objects) do assert(o.destroyed) end
print('distance_spec: client distance, band boundaries, emphasis, right anchoring, spacing, visibility and cleanup passed')
