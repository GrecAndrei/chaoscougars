function FX_MiscSolidProps(alive)
    while alive() do
        for _, obj in ipairs(GetGamePool('CObject')) do
            if DoesEntityExist(obj) and not IsEntityAMissionEntity(obj) then
                FreezeEntityPosition(obj, true)
                SetEntityDynamic(obj, false)
            end
        end
        Citizen.Wait(1000)
    end
end
