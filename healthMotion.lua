-- Awake: time-based feedback independent of rendering and combat tracking.
-- Every interruption starts at the currently displayed number, not an old goal.
local motion = {}
local methods = {}
methods.__index = methods
local function clamp(v) return math.max(0,math.min(1,v)) end
function motion.mix(a,b,amount)
    return {red=math.floor(a.red+(b.red-a.red)*amount+.5),
        green=math.floor(a.green+(b.green-a.green)*amount+.5),
        blue=math.floor(a.blue+(b.blue-a.blue)*amount+.5)}
end
function motion.new(options,clock)
    return setmetatable({options=options,clock=clock or os.clock,value=1,text_from=1,
        text_duration=options.text_duration or .22,heal_duration=options.heal_duration or .35,
        pulse_period=options.pulse_period or 1.4,
        direction=options.direction or function() return math.random(0,1)==0 and -1 or 1 end},methods)
end
function methods:update(value,immediate)
    local now=self.clock()
    if immediate then
        self.value,self.text_from=value,value
        self.changed_at,self.heal_at,self.shake_at=nil,nil,nil
        return
    end
    if value==self.value then return end
    local current=self:sample().text_value
    local loss=self.value-value
    self.kind=loss>0 and 'damage' or 'heal'
    self.value,self.text_from,self.changed_at=value,current,now
    self.heal_at=self.kind=='heal' and self.options.healing_effect and now or nil
    self.shake_at=nil
    if self.kind=='damage' and self.options.hit_shake and loss>.25+1e-9 then
        self.shake_at,self.shake_direction=now,self.direction()
        self.shake_large=loss>.5+1e-9
    end
end
function methods:sample()
    local now=self.clock()
    local out={text_value=self.value,flash=0,white=0,alpha=1,pulse=0,offset=0,healing=false,low=false}
    if self.changed_at and self.options.text_effect then
        local p=self.text_duration<=0 and 1 or clamp((now-self.changed_at)/self.text_duration)
        out.text_value=self.text_from+(self.value-self.text_from)*p
        out.flash=1-clamp((now-self.changed_at)/.25)
        out.flash_kind=self.kind
    end
    if self.heal_at then
        local p=self.heal_duration<=0 and 1 or clamp((now-self.heal_at)/self.heal_duration)
        out.healing=p<1
        out.white=1-p
    end
    if self.options.low_hp_pulse and self.value>0 and self.value<.25 and not out.healing then
        local wave=(1-math.cos(2*math.pi*now/self.pulse_period))/2
        out.low,out.pulse=true,wave
        if self.value<.10 then out.white,out.alpha=wave,1-wave
        else out.alpha=1-.5*wave end
    end
    if self.shake_at then
        local age=now-self.shake_at
        if self.shake_large and age<.18 then
            if age<.06 then out.offset=3*age/.06
            elseif age<.12 then out.offset=3-7*(age-.06)/.06
            else out.offset=-4+4*(age-.12)/.06 end
        elseif not self.shake_large and age<.12 then
            out.offset=age<.06 and age/.06 or 1-(age-.06)/.06
        end
        out.offset=math.floor(out.offset*self.shake_direction+.5)
    end
    return out
end
return motion
