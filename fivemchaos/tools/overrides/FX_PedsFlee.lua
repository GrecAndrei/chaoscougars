function FX_PedsFlee(alive)
    local playerPed = PlayerPedId()
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) then
            TaskReactAndFleePed(ped, playerPed)
            SetPedFleeAttributes(ped, 2, true)
        end
    end
end
