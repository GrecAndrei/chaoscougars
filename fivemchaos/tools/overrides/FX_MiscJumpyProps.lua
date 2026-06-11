-- MANUAL OVERRIDE from MiscJumpyProps.cpp
function FX_MiscJumpyProps(alive)
    -- propDataMap: {[prop] = {originalZ=float, startOffset=int}}
    local propDataMap = {}
    while alive() do
        for _, prop in ipairs(GetGamePool('CObject')) do
            local coords = GetEntityCoords(prop, false)
            if propDataMap[prop] == nil then
                propDataMap[prop] = {originalZ = coords.z, startOffset = GetGameTimer() + prop}
            end
            local data = propDataMap[prop]
            local Z = data.originalZ + math.max(math.sin((GetGameTimer() - data.startOffset) / 150.0) * 2.5, 0.0)
            SetEntityCoords(prop, coords.x, coords.y, Z, false, false, false, false)
        end
        Citizen.Wait(0)
    end
    -- OnStop: restore original Z positions
    for prop, data in pairs(propDataMap) do
        if DoesEntityExist(prop) then
            local coords = GetEntityCoords(prop, false)
            SetEntityCoords(prop, coords.x, coords.y, data.originalZ, false, false, false, false)
        end
    end
    propDataMap = {}
end
