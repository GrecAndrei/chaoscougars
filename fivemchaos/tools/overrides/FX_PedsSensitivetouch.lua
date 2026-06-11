function FX_PedsSensitivetouch(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and HasEntityBeenDamagedByAnyPed(ped) then
                SetEntityHealth(ped, 0)
                ClearEntityLastDamageEntity(ped)
            end
        end
        Citizen.Wait(100)
    end
end
