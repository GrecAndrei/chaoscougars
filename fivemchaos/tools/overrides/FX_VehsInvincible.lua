function FX_VehsInvincible(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) then
                SetEntityInvincible(veh, true)
            end
        end
        Citizen.Wait(0)
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        SetEntityInvincible(veh, false)
    end
end
