function FX_PlayerNophone(alive)
    while alive() do
        DestroyMobilePhone()
        Citizen.Wait(0)
    end
    CreateMobilePhone(0)
end
