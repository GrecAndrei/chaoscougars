function FX_PedsRagdoll(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        ClearPedTasksImmediately(ped)
        SetPedToRagdoll(ped, 10000, 10000, 0, true, true, false)
    end
end
