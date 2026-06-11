local allPossibleJumps = {
    { x = 46.101, y = 6530.031, z = 30.713, rotation = 137.332, speed = 40.0 },
    { x = -186.248, y = 6554.466, z = 10.446, rotation = 314.389, speed = 30.0 },
    { x = 490.106, y = 4309.650, z = 54.884, rotation = 54.039, speed = 45.0 },
    { x = -953.295, y = 4166.992, z = 136.374, rotation = 51.525, speed = 30.0 },
    { x = 3335.163, y = 5148.697, z = 17.637, rotation = 276.721, speed = 45.0 },
    { x = 1684.881, y = 3141.746, z = 42.871, rotation = 24.974, speed = 45.0 },
    { x = 1680.338, y = 2316.249, z = 74.705, rotation = 357.364, speed = 43.0 },
    { x = 1780.440, y = 2056.524, z = 65.945, rotation = 195.309, speed = 60.0 },
    { x = 2001.575, y = 1920.334, z = 91.608, rotation = 57.712, speed = 45.0 },
    { x = -2.917, y = 1699.827, z = 226.620, rotation = 325.440, speed = 45.0 },
    { x = -1447.177, y = 412.317, z = 109.067, rotation = 191.007, speed = 55.0 },
    { x = -1081.151, y = 11.979, z = 50.056, rotation = 257.962, speed = 22.0 },
    { x = -713.306, y = -49.739, z = 37.063, rotation = 110.136, speed = 42.0 },
    { x = -588.852, y = -92.791, z = 41.684, rotation = 153.347, speed = 30.0 },
    { x = -1589.183, y = -748.284, z = 20.791, rotation = 79.817, speed = 48.0 },
    { x = 46.478, y = -780.456, z = 43.524, rotation = 249.806, speed = 30.0 },
    { x = 303.248, y = -618.176, z = 42.797, rotation = 249.437, speed = 40.0 },
    { x = 563.992, y = -583.787, z = 43.544, rotation = 187.271, speed = 45.0 },
    { x = -285.071, y = -763.947, z = 52.595, rotation = 241.151, speed = 45.0 },
    { x = -873.079, y = -848.673, z = 18.503, rotation = 106.121, speed = 40.0 },
    { x = -617.539, y = -1074.971, z = 21.727, rotation = 74.128, speed = 40.0 },
    { x = 2.338, y = -1038.557, z = 37.502, rotation = 70.644, speed = 35.0 },
    { x = -440.262, y = -1178.323, z = 52.588, rotation = 175.859, speed = 50.0 },
    { x = -533.043, y = -1480.427, z = 11.122, rotation = 248.903, speed = 45.0 },
    { x = -453.039, y = -1380.261, z = 29.779, rotation = 180.118, speed = 45.0 },
    { x = -570.175, y = -1533.781, z = 0.603, rotation = 72.475, speed = 50.0 },
    { x = -423.742, y = -1564.256, z = 24.752, rotation = 350.530, speed = 45.0 },
    { x = -980.685, y = -2491.565, z = 13.898, rotation = 151.314, speed = 60.0 },
    { x = -860.708, y = -2566.927, z = 13.785, rotation = 331.449, speed = 60.0 },
    { x = -958.207, y = -2766.583, z = 13.693, rotation = 151.829, speed = 45.0 }
}

function FX_PlayerTpStunt(alive)
    local playerPed = PlayerPedId()
    local loc = allPossibleJumps[math.random(1, #allPossibleJumps)]

    DoScreenFadeOut(50)
    Citizen.Wait(50)
    SetEntityCoordsNoOffset(playerPed, loc.x, loc.y, loc.z, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)

    local veh
    if not IsPedInAnyVehicle(playerPed, false) then
        local batiHash = GetHashKey("bati")
        RequestModel(batiHash)
        while not HasModelLoaded(batiHash) do
            Citizen.Wait(0)
        end
        local pos = GetEntityCoords(playerPed, false)
        local heading = GetEntityHeading(playerPed)
        veh = CreateVehicle(batiHash, pos.x, pos.y, pos.z, heading, true, false)
        SetModelAsNoLongerNeeded(batiHash)
        SetPedIntoVehicle(playerPed, veh, -1)
    else
        veh = GetVehiclePedIsIn(playerPed, false)
    end

    SetEntityVelocity(veh, 0.0, 0.0, 0.0)
    SetEntityRotation(veh, 0.0, 0.0, loc.rotation, 2, true)
    SetVehicleForwardSpeed(veh, loc.speed)
end
