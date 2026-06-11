function FX_PlayerWalkonwater(alive)
    local waterObj = 0
    local displayHash = GetHashKey("prop_huge_display_01")
    while alive() do
        local playerPed = PlayerPedId()
        local playerCoord = GetEntityCoords(playerPed, true)
        RequestModel(displayHash)
        while not HasModelLoaded(displayHash) do Citizen.Wait(0) end
        if not DoesEntityExist(waterObj) then
            waterObj = CreateObject(displayHash, playerCoord.x, playerCoord.y, playerCoord.z - 0.5, true, true, true)
            SetEntityRotation(waterObj, 90.0, 0.0, 0.0, 2, true)
            FreezeEntityPosition(waterObj, true)
            SetEntityVisible(waterObj, false, false)
        else
            SetEntityCoords(waterObj, playerCoord.x, playerCoord.y, playerCoord.z - 0.5, true, false, false, true)
        end
        SetModelAsNoLongerNeeded(displayHash)
        Citizen.Wait(0)
    end
    if DoesEntityExist(waterObj) then DeleteObject(waterObj) end
end
