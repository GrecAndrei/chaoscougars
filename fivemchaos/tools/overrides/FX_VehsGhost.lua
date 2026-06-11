function FX_VehsGhost(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) then
                SetEntityAlpha(veh, 80, false)
            end
        end
        Citizen.Wait(0)
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        ResetEntityAlpha(veh)
    end
end
