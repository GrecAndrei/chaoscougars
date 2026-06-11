function FX_VehsSpawnWizardBroom(alive)
    local player = PlayerPedId()
    local oppressorHash = GetHashKey("oppressor2")
    local broomHash = GetHashKey("prop_tool_broom")

    RequestModel(oppressorHash)
    RequestModel(broomHash)
    while not HasModelLoaded(oppressorHash) or not HasModelLoaded(broomHash) do Citizen.Wait(0) end

    local playerPos = GetOffsetFromEntityInWorldCoords(player, 0, 1, 0)

    local veh = CreateVehicle(oppressorHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(player), true, true)
    SetModelAsNoLongerNeeded(oppressorHash)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleModKit(veh, 0)
    for i = 0, 49 do
        local max = GetNumVehicleMods(veh, i)
        SetVehicleMod(veh, i, max > 0 and max - 1 or 0, false)
    end
    SetEntityAlpha(veh, 0, false)
    SetEntityVisible(veh, false, false)

    local broom = CreateObject(broomHash, playerPos.x, playerPos.y + 2, playerPos.z, true, false, false)
    SetModelAsNoLongerNeeded(broomHash)
    AttachEntityToEntity(broom, veh, 0, 0, 0, 0.3, -80.0, 0, 0, true, false, false, false, 0, true)
end
