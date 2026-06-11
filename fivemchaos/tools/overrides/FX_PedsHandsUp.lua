function FX_PedsHandsUp(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        local pedType = GetPedType(ped)
        if pedType ~= 6 and pedType ~= 27 and not IsPedDeadOrDying(ped, true) then
            TaskHandsUp(ped, 5000, 0, -1, true)
            SetPedDropsWeapon(ped)
        end
    end
end
