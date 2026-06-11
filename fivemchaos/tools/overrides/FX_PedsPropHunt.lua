function FX_PedsPropHunt(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and math.random() < 0.01 then
                local props = GetGamePool('CObject')
                if #props > 0 then
                    local prop = props[math.random(#props)]
                    local model = GetEntityModel(prop)
                    local coords = GetEntityCoords(ped, false)
                    local heading = GetEntityHeading(ped)
                    DeletePed(ped)
                    Citizen.Wait(0)
                    RequestModel(model)
                    while not HasModelLoaded(model) do Citizen.Wait(0) end
                    local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
                    SetModelAsNoLongerNeeded(model)
                    SetEntityHeading(obj, heading)
                end
            end
        end
        Citizen.Wait(5000)
    end
end
