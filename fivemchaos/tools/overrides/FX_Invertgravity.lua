function FX_Invertgravity(alive)
    while alive() do
        SetGravityLevel(3)
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) then
                ApplyForceToEntityCenterOfMass(ped, 1, 0.0, 0.0, 50.0, true, false, true, true)
            end
        end
        Citizen.Wait(100)
    end
    SetGravityLevel(0)
end
