-- A: deterministic native-target helper test with simulated FFXiMain pointers.
-- This does not prove in-game rendering or safety of the compiled C helper.
package.path='./?.lua;'..package.path

local values = {}
local writes = {}
local scans = 0
local BASE, OFFSET = 0x1000, 0x100
local ref = BASE + OFFSET + 0x23
values[ref] = 0x3000
values[0x3000] = 0x4000
values[0x4008] = 0x5000
values[0x404E] = 0x42
values[0x5069] = 1
values[0x506A] = 1

package.loaded.hideparty_mem = {
    find_module = function(name)
        assert(name == 'FFXiMain.dll')
        return BASE, 0x6000
    end,
    scan = function(signature)
        scans = scans + 1
        assert(signature:find('66C78182', 1, true) == 1)
        return OFFSET
    end,
    read_uint32 = function(address) return values[address] or 0 end,
    write_uint8 = function(address, value)
        assert(value >= 0 and value <= 255)
        values[address] = value
        writes[#writes + 1] = {address, value}
    end,
}
local native = require('nativeTarget')
assert(native.status() == 'ready')
assert(native.update(true))
assert(values[0x5069] == 0 and values[0x404E] == 255)
assert(values[0x506A] == 1, 'targeting arrow visibility must remain untouched')
assert(scans == 1)

assert(native.update(true) and scans == 1)
assert(native.status():find('hidden', 1, true))
native.restore()
assert(values[0x404E] == 0x42 and values[0x5069] == 1)
assert(values[0x506A] == 1)
local count = #writes
native.restore()
assert(#writes == count, 'duplicate restore must be inert')
assert(native.update(false) and #writes == count)

-- Live target pointers can change. Do not write the old pointer after it
-- stops being the client target, but capture and restore the new one.
assert(native.update(true))
values[0x3000] = 0x4100
values[0x4108] = 0x5100
values[0x414E] = 0x66
values[0x5169] = 1
values[0x516A] = 1
assert(native.update(true))
assert(values[0x414E] == 255 and values[0x5169] == 0)
assert(values[0x516A] == 1)
native.reset()
assert(values[0x414E] == 0x66 and values[0x5169] == 1)
assert(native.update(true) and scans == 2)
native.restore()

-- Signature failure should not write to anything or throw.
package.loaded.nativeTarget = nil
package.loaded.hideparty_mem.scan = function() return nil end
local no_signature = require('nativeTarget')
count = #writes
assert(not no_signature.update(true))
assert(no_signature.status():find('signature', 1, true))
assert(#writes == count)

-- Missing DLL must degrade gracefully and retain the native HUD.
package.loaded.nativeTarget = nil
package.loaded.hideparty_mem = nil
package.preload.hideparty_mem = function() error('mock DLL missing') end
local missing = require('nativeTarget')
assert(not missing.update(true))
assert(missing.status():find('unavailable', 1, true))
missing.restore()
print('native_target_spec: hide, cursor preservation, restore, pointer change, zone rescan, missing signature/DLL passed (mocked)')
