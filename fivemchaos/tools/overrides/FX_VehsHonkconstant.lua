function FX_VehsHonkconstant(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) then
                SetHornPermanentlyOn(veh, true)
            end
        end
        Citizen.Wait(0)
    end
end
