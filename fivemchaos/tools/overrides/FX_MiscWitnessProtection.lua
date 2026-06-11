-- MANUAL OVERRIDE from MiscWitnessProtection.cpp
function FX_MiscWitnessProtection(alive)
    -- orbitingPeds: array of {ped=Ped, angle=float}
    local orbitingPeds = {}
    local pedCount = 20
    while alive() do
        local player = PlayerPedId()
        local count = 5
        if #orbitingPeds == 0 then
            local pedHash = GetHashKey("MP_M_FIBSec_01")
            LoadModel(pedHash)
            for i = 0, pedCount - 1 do
                local ped = CreatePed(-1, pedHash, 0, 0, 0, 0, true, false)
                SetEntityHasGravity(ped, false)
                SetPedCanRagdoll(ped, false)
                SetEntityCollision(ped, false, true)
                SetPedCanBeTargettedByPlayer(ped, player, false)
                local offset = (360.0 / pedCount) * i
                table.insert(orbitingPeds, {ped = ped, angle = offset})
                count = count - 1
                if count == 0 then
                    Citizen.Wait(0)
                    count = 5
                end
            end
        end
        local entityToCircle = player
        if IsPedInAnyVehicle(player, false) then
            entityToCircle = GetVehiclePedIsIn(player, false)
        end
        local min, max = GetModelDimensions(GetEntityModel(entityToCircle))
        local height = max.z - min.z
        local zCorrection = (-height / 2) + 0.3
        local heading = GetEntityHeading(entityToCircle)
        for i = #orbitingPeds, 1, -1 do
            local pedInfo = orbitingPeds[i]
            if IsPedDeadOrDying(pedInfo.ped, false) then
                SetEntityHealth(pedInfo.ped, 0, 0)
                SetEntityAlpha(pedInfo.ped, 0, true)
                SetPedAsNoLongerNeeded(pedInfo.ped)
                DeletePed(pedInfo.ped)
                table.remove(orbitingPeds, i)
                count = count - 1
                if count == 0 then
                    Citizen.Wait(0)
                    count = 5
                end
            else
                local coord = GetCoordAround(entityToCircle, heading - pedInfo.angle, 3, zCorrection, true)
                SetEntityCoords(pedInfo.ped, coord.x, coord.y, coord.z, false, false, false, false)
                SetEntityHeading(pedInfo.ped, pedInfo.angle + 90)
                TaskStandStill(pedInfo.ped, 5000)
                pedInfo.angle = pedInfo.angle + 1
            end
        end
        Citizen.Wait(0)
    end
    -- OnStop cleanup
    local count = 5
    for i = #orbitingPeds, 1, -1 do
        local pedInfo = orbitingPeds[i]
        SetEntityHealth(pedInfo.ped, 0, 0)
        SetEntityAlpha(pedInfo.ped, 0, true)
        SetPedAsNoLongerNeeded(pedInfo.ped)
        DeletePed(pedInfo.ped)
        count = count - 1
        if count == 0 then
            Citizen.Wait(0)
            count = 5
        end
    end
end
