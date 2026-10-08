local ffxi_gauge = require('ffxiGauge')
local health_motion = require('healthMotion')

-- Meta class
bars = {x_res = windower.get_windower_settings().ui_x_res,y_res = windower.get_windower_settings().ui_y_res}

-- Base class method new

function bars.new(bar_settings)
   local o = {}
   o.skin = bar_settings.skin or 'classic'
   o.background_alpha = bar_settings.background_alpha or 128
   o.animation_duration = bar_settings.animation_duration or 0.18
   o.damage_trail = bar_settings.damage_trail ~= false
   o.trail_delay = bar_settings.trail_delay or 1.5
   o.trail_duration = bar_settings.trail_duration or .45
   o.trail_color = bar_settings.trail_color
   o.bold = bar_settings.bold ~= false
   o.italic = bar_settings.italic ~= false
   o.effects = (bar_settings.healing_effect or bar_settings.text_effect or bar_settings.hit_shake or bar_settings.low_hp_pulse) and bar_settings or nil
   o.width = bar_settings.width
   o.color = bar_settings.color
   o.font = bar_settings.font
   o.font_size = bar_settings.font_size
   o.show_dist = bar_settings.show_dist
   o.show_target = bar_settings.show_target
   o.show_target_icon = bar_settings.show_target_icon
   o.show_action = bar_settings.show_action
   o.show_debuff = bar_settings.show_debuff
   bars.initialize(o)
   bars.move(o, bar_settings.pos.x, bar_settings.pos.y)
   bars.hide(o)
   return o
end

function bars.destroy(o)
	if not o then return end
	o.target_indicator_image:destroy()
	if o.gauge then
		o.gauge:destroy()
	else
		o.left_cap_image:destroy()
		o.background_body_image:destroy()
		o.foreground_body_image:destroy()
		o.right_cap_image:destroy()
	end
	o.name_text:destroy()
	o.action_text:destroy()
	o.attention_arrow_image:destroy()
	o.target_name_text:destroy()
	o.distance_text:destroy()
	o.target_status_image:destroy()
end

function bars.initialize(o)
	o.target_indicator_image = images.new({
			pos = {x=0,y=0},
			visible = true,
			color = {alpha=o.color.alpha,red=255,green=50,blue=50},
			size = {width=12,height=12},
			texture = {path=windower.addon_path.. 'target.png',fit=true},
			repeatable = {x=1,y=1},
			draggable = false
		})
	if o.skin == 'ffxi' then
		o.gauge = ffxi_gauge.new(o.width, o.color, {
            background_alpha=o.background_alpha, animation_duration=o.animation_duration,
            damage_trail=o.damage_trail,trail_delay=o.trail_delay,
            trail_duration=o.trail_duration,trail_color=o.trail_color,effects=o.effects})
	else
		o.left_cap_image = images.new({
				pos = {x=0,y=0},
				visible = true,
				color = {alpha=o.color.alpha,red=o.color.red,green=o.color.green,blue=o.color.blue},
				size = {width=1,height=12},
				texture = {path=windower.addon_path.. 'bg_cap.png',fit=true},
				repeatable = {x=1,y=1},
				draggable = false
			})
		o.background_body_image = images.new({
				pos = {x=0,y=0},
				visible = true,
				color = {alpha=o.color.alpha,red=o.color.red,green=o.color.green,blue=o.color.blue},
				size = {width=o.width,height=12},
				texture = {path=windower.addon_path.. 'bg_body.png',fit=true},
				repeatable = {x=1,y=1},
				draggable = false
			})
		o.foreground_body_image = images.new({
				pos = {x=0,y=0},
				visible = true,
				color = {alpha=o.color.alpha,red=o.color.red,green=o.color.green,blue=o.color.blue},
				size = {width=o.width,height=12},
				texture = {path=windower.addon_path.. 'fg_body.png',fit=true},
				repeatable = {x=1,y=1},
				draggable = false
			})
		o.right_cap_image = images.new({
				pos = {x=0,y=0},
				visible = true,
				color = {alpha=o.color.alpha,red=o.color.red/2,green=o.color.green/2,blue=o.color.blue/2},
				size = {width=1,height=12},
				texture = {path=windower.addon_path.. 'bg_cap.png',fit=true},
				repeatable = {x=1,y=1},
				draggable = false
			})
	end
	local stroke = o.gauge and 12 or 50
	o.name_text = texts.new('${name|(Name)}: ${hpp|(100)}%', {
			pos = {x=0,y=0},
			text = { size=o.font_size,font=o.font,stroke={width=2,alpha=180,red=stroke,green=stroke,blue=stroke}},
			flags = {bold=o.bold,draggable=false,italic=o.italic},
			bg = {visible=false}
		})
	o.action_text = texts.new('${action|(Action)}', {
			pos = {x=0,y=0},
			text = { size=o.font_size*0.8,font=o.font,stroke={width=2,alpha=180,red=stroke,green=stroke,blue=stroke}},
			flags = {bold=o.bold,draggable=false,right=true},
			bg = {visible=false}
		})
	o.attention_arrow_image = images.new({
			pos = {x=0,y=0},
			visible = true,
			color = {alpha=o.color.alpha,red=o.color.red,green=o.color.green,blue=o.color.blue},
			size = {width=12,height=12},
			texture = {path=windower.addon_path.. 'attention.png',fit=true},
			repeatable = {x=1,y=1},
			draggable = false
		})
	o.target_name_text = texts.new('${pc|(Target)}', {
			pos = {x=0,y=0},
			text = { size=o.font_size,font=o.font,stroke={width=2,alpha=180,red=stroke,green=stroke,blue=stroke}},
			flags = {bold=o.bold,draggable=false},
			bg = {visible=false}
		})
	o.distance_text = texts.new('${dist|(0.0)}\'', {
			pos = {x=0,y=0},
			text = { size=o.font_size*0.8,font=o.font,stroke={width=2,alpha=180,red=stroke,green=stroke,blue=stroke}},
			flags = {bold=o.bold,draggable=false,right=true},
			bg = {visible=false}
		})
	o.target_status_image = images.new({
			pos = {x=0,y=0},
			visible = true,
			size = {width=18,height=12},
			texture = {path=windower.addon_path.. 'icons/sleep.png',fit=true},
			repeatable = {x=1,y=1},
			draggable = false
		})
end

function bars.move(o,x,y)
	if not o then return end
	o.x = x
	o.y = y
	o.target_indicator_image:pos(x-16,y)
	if o.gauge then
		o.gauge:move(x,y)
	else
		o.left_cap_image:pos(x,y)
		o.background_body_image:pos(x+1,y)
		o.foreground_body_image:pos(x+1,y)
		o.right_cap_image:pos(x+1+o.width,y)
	end
	o.name_text:pos(x+math.floor(o.width/100), y+3+(14-o.font_size)/4)
	o.action_text:pos(-(bars.x_res-(x+o.width-math.floor(o.width/100))),y-o.font_size+2)
	o.attention_arrow_image:pos(x+o.width+8, y)
	o.target_name_text:pos(x+o.width+24,y-math.floor(o.font_size/2)+2)
	o.distance_text:pos(-(bars.x_res-(x-20)),y-math.floor(o.font_size/2)+4)
	o.target_status_image:pos(x+o.width + 4, y)
end

function bars.show(o)
	if not o then return end
	if o.show_dist then	o.distance_text:show() end
	if o.gauge then
		o.gauge:show()
	else
		o.left_cap_image:show()
		o.background_body_image:show()
		o.foreground_body_image:show()
		o.right_cap_image:show()
	end
	o.name_text:show()
    bars.refresh_text(o)
end

function bars.hide(o)
	if not o then return end
    o.target_id = nil
	o.distance_text:hide()
	o.target_indicator_image:hide()
	if o.gauge then
		o.gauge:hide()
	else
		o.left_cap_image:hide()
		o.background_body_image:hide()
		o.foreground_body_image:hide()
		o.right_cap_image:hide()
	end
	o.name_text:hide()
	o.action_text:hide()
	o.attention_arrow_image:hide()
	o.target_name_text:hide()
	o.target_status_image:hide()
end

function bars.set_value(o, v, immediate)
	if not o then return end
	if o.gauge then
		o.gauge:set_value(v, immediate)
	else
		o.foreground_body_image:width(v*o.width)
		o.background_body_image:width(o.width)
	end
end

function bars.set_name_color(o, color)
	if not o then return end
    o.name_color=color
    bars.refresh_text(o)
	o.action_text:color(color.red, color.green, color.blue)
end

function bars.refresh_text(o)
    local color=o.name_color or {red=255,green=255,blue=255}
    if o.gauge and o.gauge.motion then
        local feedback=o.gauge.motion:sample()
        o.name_text.hpp=math.floor(feedback.text_value*100+.5)
        local flash=feedback.flash_kind=='heal' and {red=209,green=224,blue=151} or
            (o.trail_color or {red=167,green=57,blue=96})
        color=health_motion.mix(color,flash,feedback.flash)
    end
    o.name_text:color(color.red,color.green,color.blue)
end

function bars.update_target(o, name, hpp, dist, target_type, target_id)
	if not o then return end
	o.name_text.name = name
	o.name_text.hpp = hpp
    local identity = target_id or name
	bars.set_value(o, hpp/100, o.target_id ~= identity)
    o.target_id = identity
    bars.refresh_text(o)

	o.distance_text.dist = string.format('%.1f', dist)

	if target_type == 1 and o.show_target_icon then
		o.target_indicator_image:color(255,100,100,255)
		o.target_indicator_image:show()
	elseif target_type == 2 and o.show_target_icon then
		o.target_indicator_image:color(100,100,255,255)
		o.target_indicator_image:show()
	else
		o.target_indicator_image:hide()
	end
end

function bars.update_action(o, a, debug)
	if not o then return end
	if a and o.show_action then
		o.action_text.action = a
		o.action_text:show()
	else
		-- hide action text
		o.action_text:hide()
	end
end

function bars.update_enmity(o, name, color)
	if not o then return end
	if name and o.show_target then
		if color then
			o.attention_arrow_image:color(color.red, color.green, color.blue)
			o.target_name_text:color(color.red, color.green, color.blue)
		end
		o.target_name_text.pc = name
		o.target_name_text:show()
		o.attention_arrow_image:show()
	else
		o.target_name_text:hide()
		o.attention_arrow_image:hide()
	end
end

function bars.update_status(o, status)
	if not o then return end
	if status and o.show_debuff then
		for id,effect in pairs(status) do
			if S{2,19}:contains(id) then
				--sleep
				o.target_status_image:path(windower.addon_path.. 'icons/sleep.png')
				o.target_status_image:show()
				o.attention_arrow_image:hide()
				o.target_name_text:hide()
				return
			elseif id == 7 then
				-- petrification
				o.target_status_image:path(windower.addon_path.. 'icons/petrified.png')
				o.target_status_image:show()
				o.attention_arrow_image:hide()
				o.target_name_text:hide()
				return
			elseif id == 11 then
				--bind
				o.target_status_image:path(windower.addon_path.. 'icons/bound.png')
				o.target_status_image:show()
				o.attention_arrow_image:hide()
				o.target_name_text:hide()
				return
			elseif id == 28 then
				-- terror
				o.target_status_image:path(windower.addon_path.. 'icons/terror.png')
				o.target_status_image:show()
				o.attention_arrow_image:hide()
				o.target_name_text:hide()
				return
			end
		end
	end
	o.target_status_image:hide()
end

local function gauge_hover(o, x, y)
	if o.gauge then return o.gauge:hover(x,y) end
	return o.foreground_body_image:hover(x,y) or
	       o.background_body_image:hover(x,y) or
	       o.left_cap_image:hover(x,y) or o.right_cap_image:hover(x,y)
end

function bars.hover(o, x, y)
	if not o then return false end
	return gauge_hover(o,x,y) or
		   o.distance_text:hover(x,y) or
		   o.target_indicator_image:hover(x,y) or
		   o.name_text:hover(x,y) or
		   o.action_text:hover(x,y) or
		   o.attention_arrow_image:hover(x,y) or
		   o.target_name_text:hover(x,y) or
		   o.target_status_image:hover(x,y)
end
