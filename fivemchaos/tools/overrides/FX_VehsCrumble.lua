function FX_VehsCrumble(alive)
    while alive() do
        local vehs = GetGamePool('CVehicle')
        if #vehs > 0 then
            local veh = vehs[math.random(#vehs)]
            SetVehicleDamage(veh,
                (-1.0 + math.random() * 2.0),
                (-1.0 + math.random() * 2.0),
                (-1.0 + math.random() * 2.0),
                (1000.0 + math.random() * 9000.0),
                (100.0 + math.random() * 900.0),
                true)
        end
        Citizen.Wait(0)
    end
end
