function FX_PedsBloody(alive)
    local packs = {
        "TD_SHOTGUN_FRONT_KILL",
        "BigRunOverByVehicle",
        "Dirt_Mud",
        "Explosion_Large",
        "RunOverByVehicle",
        "Splashback_Face_0",
        "Splashback_Face_1",
        "SCR_Shark",
        "SCR_Cougar",
        "Car_Crash_Heavy",
        "TD_SHOTGUN_REAR_KILL",
        "SCR_Torture",
        "TD_melee_face_l",
        "MTD_melee_face_r",
        "MTD_melee_face_jaw",
    }
    for _, ped in ipairs(GetGamePool('CPed')) do
        for _, pack in ipairs(packs) do
            ApplyPedDamagePack(ped, pack, 0.0, 10.0)
        end
    end
end
