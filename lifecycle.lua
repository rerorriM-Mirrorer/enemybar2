-- Awake: dispatch once; an ensuing unload event shares idempotent cleanup.
local lifecycle={}
function lifecycle.new(cleanup,dispatch,report)
    local self={pending=false,cleaned=false}
    function self:dispose()
        self.pending=true
        if self.cleaned then return end
        self.cleaned=true;cleanup()
    end
    function self:request(action)
        if self.pending then return false end
        self.pending=true
        report(action=='restart' and 'EnemyBar: restarting' or 'EnemyBar: unloading')
        self:dispose()
        dispatch(action=='restart' and 'lua reload enemybar2' or 'lua unload enemybar2')
        return true
    end
    return self
end
return lifecycle
