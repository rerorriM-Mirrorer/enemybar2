-- A: Optional Windower 4 native target-bar suppression.
-- Reuse the separately installed HideParty C helper, without modifying it.
-- PTHud demonstrated that the native text and 3D targeting cursor share
-- visibility +0x6A. Hide the background (+0x69) and relocate ONLY the text
-- Y byte (+0x4E), leaving +0x6A entirely under the game's control.
local M = {}

local loaded, mem = pcall(require, 'hideparty_mem')
if not loaded or type(mem) ~= 'table' then mem = nil end

local SIGNATURE = '66C78182000000????C7818C000000????????C781900000'
local target_ref
local scanned = false
local failure
local hidden_ptr
local hidden_render
local saved_text_y

local function scan()
    if scanned then return target_ref ~= nil end
    scanned = true
    if not mem then
        failure = 'hideparty_mem.dll is missing or could not load'
        return false
    end
    local base = mem.find_module('FFXiMain.dll')
    if not base then
        failure = 'FFXiMain.dll not found'
        return false
    end
    local offset = mem.scan(SIGNATURE)
    if offset == nil then
        failure = 'native target signature not found'
        return false
    end
    target_ref = mem.read_uint32(base + offset + 0x23)
    if not target_ref or target_ref == 0 then
        target_ref = nil
        failure = 'native target pointer not found'
        return false
    end
    failure = nil
    return true
end

local function target()
    if not scan() then return nil end
    local ptr = mem.read_uint32(target_ref)
    if not ptr or ptr == 0 then return nil end
    local render = mem.read_uint32(ptr + 0x08)
    if not render or render == 0 then return nil end
    return ptr, render
end

function M.restore()
    if hidden_ptr and mem and target_ref then
        -- A previous zone's object may no longer be valid. Never restore
        -- a cached address unless the current target still points to it.
        local ptr = mem.read_uint32(target_ref)
        if ptr == hidden_ptr and mem.read_uint32(ptr + 0x08) == hidden_render then
            if saved_text_y ~= nil then mem.write_uint8(ptr + 0x4E, saved_text_y) end
            mem.write_uint8(hidden_render + 0x69, 1)
        end
    end
    hidden_ptr, hidden_render, saved_text_y = nil, nil, nil
end

function M.update(enabled)
    if not enabled then M.restore(); return true end
    local ptr, render = target()
    if not ptr then
        -- No valid target render object to operate on yet; leave UI alone.
        if hidden_ptr then M.restore() end
        return false
    end
    if hidden_ptr and (hidden_ptr ~= ptr or hidden_render ~= render) then
        M.restore()
    end
    if not hidden_ptr then
        -- read_uint32 reads four bytes; only the low byte is the native
        -- text Y coordinate. Save once so toggling off can restore it.
        saved_text_y = mem.read_uint32(ptr + 0x4E) % 256
        hidden_ptr, hidden_render = ptr, render
    end
    mem.write_uint8(render + 0x69, 0)
    mem.write_uint8(ptr + 0x4E, 0xFF)
    return true
end

function M.reset()
    M.restore()
    target_ref = nil
    scanned = false
    failure = nil
end

function M.status()
    if hidden_ptr then return 'hidden (3D cursor preserved)' end
    if not mem then return 'unavailable: hideparty_mem.dll missing' end
    if failure then return 'unavailable: ' .. failure end
    return 'ready'
end

return M
