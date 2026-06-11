function FX_PlayerExplosivecombat(alive)
    while alive() do
        SetExplosiveMeleeThisFrame(PlayerId())
        SetExplosiveAmmoThisFrame(PlayerId())
        Citizen.Wait(0)
    end
end
