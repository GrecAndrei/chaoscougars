function FX_VehsDetachWheel(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    local wheelBones = {
        "wheel_lf", "wheel_rf", "wheel_lm", "wheel_rm",
        "wheel_lr", "wheel_rr", "wheel_lm1", "wheel_rm1",
    }
    local wheels = {}
    for _, boneName in ipairs(wheelBones) do
        local idx = GetEntityBoneIndexByName(veh, boneName)
        if idx ~= -1 then
            table.insert(wheels, idx)
        end
    end
    if #wheels > 0 then
        local pick = wheels[math.random(#wheels)]
        for i = 0, 7 do
            SetVehicleTyreBurst(veh, i, true, 1000.0)
        end
    end
end
