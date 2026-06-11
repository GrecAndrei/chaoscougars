-- MANUAL OVERRIDE from MiscLag.cpp
function FX_TimeLag(alive)
    local ms_State = 0
    local ms_ToTpPeds = {}
    local ms_ToTpVehs = {}
    local lastTick = 0
    while alive() do
        local curTick = GetGameTimer()
        if curTick > lastTick + 500 then
            lastTick = curTick
            ms_State = ms_State + 1
            if ms_State == 4 then ms_State = 0 end
            if ms_State == 2 then
                for _, ped in ipairs(GetGamePool('CPed')) do
                    if not IsPedInAnyVehicle(ped, true) and GetVehiclePedIsEntering(ped) == 0 then
                        local pedPos = GetEntityCoords(ped, false)
                        ms_ToTpPeds[ped] = pedPos
                    end
                end
                for _, veh in ipairs(GetGamePool('CVehicle')) do
                    local vehPos = GetEntityCoords(veh, false)
                    ms_ToTpVehs[veh] = vehPos
                end
            elseif ms_State == 3 then
                local camHeading = GetGameplayCamRelativeHeading()
                for veh, tpPos in pairs(ms_ToTpVehs) do
                    local vel = GetEntityVelocity(veh)
                    local heading = GetEntityHeading(veh)
                    local forwardSpeed = GetEntitySpeed(veh)
                    if GetEntitySpeedVector(veh, true).y < 0 then
                        forwardSpeed = forwardSpeed * -1
                    end
                    SetEntityCoordsNoOffset(veh, tpPos.x, tpPos.y, tpPos.z, false, false, false)
                    SetEntityHeading(veh, heading)
                    SetEntityVelocity(veh, vel.x, vel.y, vel.z)
                    SetVehicleForwardSpeed(veh, forwardSpeed)
                end
                ms_ToTpVehs = {}
                SetGameplayCamRelativeHeading(camHeading)
            end
        end
        Citizen.Wait(0)
    end
end
