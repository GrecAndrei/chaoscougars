function FX_PlayerNoragdoll(alive)
    while alive() do
        SetPedCanRagdoll(PlayerPedId(), false)
        Citizen.Wait(0)
    end
    SetPedCanRagdoll(PlayerPedId(), true)
end
