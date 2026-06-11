function FX_PedsGiveProps(alive)
    local props = {
        GetHashKey("prop_beach_ball_01"), GetHashKey("prop_donut_01"), GetHashKey("prop_snow_flower_01"),
        GetHashKey("prop_roadcone02a"), GetHashKey("prop_bin_01a"), GetHashKey("prop_cs_sol_phone"),
    }
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            local prop = props[math.random(#props)]
            RequestModel(prop)
            while not HasModelLoaded(prop) do Citizen.Wait(0) end
            local obj = CreateObject(prop, 0, 0, 0, true, true, false)
            SetModelAsNoLongerNeeded(prop)
            AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 2, true)
        end
    end
end
