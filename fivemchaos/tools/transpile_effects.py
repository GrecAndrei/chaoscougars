#!/usr/bin/env python3
"""
ChaosModV C++ -> FiveM Lua transpiler.
Reads .cpp files from ref-chaosmodv/ChaosMod/Effects/db/**/*.cpp
Outputs:
  resource/client/effects_generated.lua  -- FX_ functions
  resource/shared/effects_generated.lua  -- Effects.Pool entries
"""

import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).parent.parent
EFFECTS_DIR = ROOT / "ref-chaosmodv" / "ChaosMod" / "Effects" / "db"
OUT_CLIENT = ROOT / "resource" / "client" / "effects_generated.lua"
OUT_SHARED = ROOT / "resource" / "shared" / "effects_generated.lua"
LUAC_CANDIDATES = [
    Path(r"C:\Program Files (x86)\Lua\bin\luac.exe"),
    Path(r"C:\Program Files\Lua\bin\luac.exe"),
]

# ─── Native name mapping ────────────────────────────────────────────────────
# C++ SCREAMING_SNAKE / NAMESPACE::SCREAMING_SNAKE -> Lua PascalCase
NATIVE_MAP = {
    # Player / Ped
    "PLAYER_PED_ID": "PlayerPedId",
    "PLAYER_ID": "PlayerId",
    "IS_PED_IN_ANY_VEHICLE": "IsPedInAnyVehicle",
    "IS_PED_IN_VEHICLE": "IsPedInVehicle",
    "IS_PED_RAGDOLL": "IsPedRagdoll",
    "IS_PED_DEAD": "IsPedDead",
    "IS_PED_ON_FOOT": "IsPedOnFoot",
    "IS_PED_SWIMMING": "IsPedSwimming",
    "GET_VEHICLE_PED_IS_IN": "GetVehiclePedIsIn",
    "GET_VEHICLE_PED_IS_USING": "GetVehiclePedIsUsing",
    "SET_PED_TO_RAGDOLL": "SetPedToRagdoll",
    "SET_PED_CAN_RAGDOLL": "SetPedCanRagdoll",
    "CLEAR_PED_TASKS_IMMEDIATELY": "ClearPedTasksImmediately",
    "CLEAR_PED_TASKS": "ClearPedTasks",
    "SET_PED_INTO_VEHICLE": "SetPedIntoVehicle",
    "TASK_WARP_PED_INTO_VEHICLE": "TaskWarpPedIntoVehicle",
    "TASK_VEHICLE_DRIVE_TO_COORD": "TaskVehicleDriveToCoord",
    "TASK_VEHICLE_DRIVE_WANDER": "TaskVehicleDriveWander",
    "TASK_GO_TO_COORD_ANY_MEANS": "TaskGoToCoordAnyMeans",
    "TASK_FLEE_COORD": "TaskFleeCoord",
    "TASK_COMBAT_PED": "TaskCombatPed",
    "TASK_PUT_PED_DIRECTLY_INTO_MELEE": "TaskPutPedDirectlyIntoMelee",
    "GIVE_WEAPON_TO_PED": "GiveWeaponToPed",
    "REMOVE_WEAPON_FROM_PED": "RemoveWeaponFromPed",
    "REMOVE_ALL_PED_WEAPONS": "RemoveAllPedWeapons",
    "GET_CURRENT_PED_WEAPON": "GetCurrentPedWeapon",
    "SET_CURRENT_PED_WEAPON": "SetCurrentPedWeapon",
    "SET_PED_ACCURACY": "SetPedAccuracy",
    "SET_PED_FIRING_PATTERN": "SetPedFiringPattern",
    "SET_PED_SHOOT_RATE": "SetPedShootRate",
    "SET_PED_FLEE_ATTRIBUTES": "SetPedFleeAttributes",
    "SET_PED_COMBAT_ATTRIBUTES": "SetPedCombatAttributes",
    "SET_PED_RELATIONSHIP_GROUP_HASH": "SetPedRelationshipGroupHash",
    "SET_RELATIONSHIP_BETWEEN_GROUPS": "SetRelationshipBetweenGroups",
    "CREATE_PED": "CreatePed",
    "DELETE_PED": "DeletePed",
    "IS_PED_A_PLAYER": "IsPedAPlayer",
    "GET_PED_ARMOUR": "GetPedArmour",
    "SET_PED_ARMOUR": "SetPedArmour",
    "SET_PED_MAX_HEALTH": "SetPedMaxHealth",
    "GET_ENTITY_HEALTH": "GetEntityHealth",
    "SET_ENTITY_HEALTH": "SetEntityHealth",
    "GET_PED_MAX_HEALTH": "GetPedMaxHealth",
    "SET_PED_COMPONENT_VARIATION": "SetPedComponentVariation",
    "SET_PED_HEAD_BLEND_DATA": "SetPedHeadBlendData",
    "GET_PED_BONE_COORDS": "GetPedBoneCoords",
    "GET_PED_BONE_INDEX": "GetPedBoneIndex",
    "APPLY_DAMAGE_TO_PED": "ApplyDamageToPed",
    "SET_PED_MONEY": "SetPedMoney",
    "GET_PED_MONEY": "GetPedMoney",
    "GET_RANDOM_PED_AT_COORD": "GetRandomPedAtCoord",
    "SET_PED_MOVE_RATE_OVERRIDE": "SetPedMoveRateOverride",
    "SET_PED_MOVEMENT_CLIPSET": "SetPedMovementClipset",
    "RESET_PED_MOVEMENT_CLIPSET": "ResetPedMovementClipset",
    "IS_PED_IN_PARACHUTE_FREE_FALL": "IsPedInParachuteFreefall",
    "SET_PED_GRAVITY": "SetPedGravity",
    "SET_PED_CAN_SWITCH_WEAPON": "SetPedCanSwitchWeapon",
    "SET_PED_CONFIG_FLAG": "SetPedConfigFlag",
    "GET_PED_CONFIG_FLAG": "GetPedConfigFlag",
    "APPLY_PED_BLOOD_DAMAGE_BY_ZONE": "ApplyPedBloodDamageByZone",
    "IS_PLAYER_FREE_AIMING": "IsPlayerFreeAiming",
    "IS_PLAYER_FREE_AIMING_AT_ENTITY": "IsPlayerFreeAimingAtEntity",
    "SET_PLAYER_CAN_DO_DRIVE_BY": "SetPlayerCanDoDriveBy",
    "SET_PLAYER_INVINCIBLE": "SetPlayerInvincible",
    "GET_PLAYER_INVINCIBLE": "GetPlayerInvincible",
    "SET_PLAYER_WANTED_LEVEL": "SetPlayerWantedLevel",
    "SET_PLAYER_WANTED_LEVEL_NOW": "SetPlayerWantedLevelNow",
    "GET_PLAYER_WANTED_LEVEL": "GetPlayerWantedLevel",
    "CLEAR_PLAYER_WANTED_LEVEL": "ClearPlayerWantedLevel",
    "SET_MAX_WANTED_LEVEL": "SetMaxWantedLevel",
    "SET_PLAYER_WEAPON_DEFENSE_MODIFIER": "SetPlayerWeaponDefenseModifier",
    "SET_PLAYER_MELEE_WEAPON_DAMAGE_MODIFIER": "SetPlayerMeleeWeaponDamageModifier",
    "SET_PLAYER_MELEE_WEAPON_DEFENSE_MODIFIER": "SetPlayerMeleeWeaponDefenseModifier",
    "IS_PLAYER_PLAYING": "IsPlayerPlaying",
    "IS_PLAYER_DEAD": "IsPlayerDead",

    # Entity
    "GET_ENTITY_COORDS": "GetEntityCoords",
    "SET_ENTITY_COORDS": "SetEntityCoords",
    "SET_ENTITY_COORDS_NO_OFFSET": "SetEntityCoordsNoOffset",
    "GET_ENTITY_VELOCITY": "GetEntityVelocity",
    "SET_ENTITY_VELOCITY": "SetEntityVelocity",
    "GET_ENTITY_ROTATION": "GetEntityRotation",
    "SET_ENTITY_ROTATION": "SetEntityRotation",
    "GET_ENTITY_HEADING": "GetEntityHeading",
    "SET_ENTITY_HEADING": "SetEntityHeading",
    "SET_ENTITY_INVINCIBLE": "SetEntityInvincible",
    "SET_ENTITY_VISIBLE": "SetEntityVisible",
    "IS_ENTITY_VISIBLE": "IsEntityVisible",
    "IS_ENTITY_DEAD": "IsEntityDead",
    "IS_ENTITY_ON_SCREEN": "IsEntityOnScreen",
    "IS_ENTITY_A_PED": "IsEntityAPed",
    "IS_ENTITY_A_VEHICLE": "IsEntityAVehicle",
    "IS_ENTITY_AN_OBJECT": "IsEntityAnObject",
    "DOES_ENTITY_EXIST": "DoesEntityExist",
    "DELETE_ENTITY": "DeleteEntity",
    "SET_ENTITY_AS_MISSION_ENTITY": "SetEntityAsMissionEntity",
    "SET_ENTITY_AS_NO_LONGER_NEEDED": "SetEntityAsNoLongerNeeded",
    "GET_ENTITY_MODEL": "GetEntityModel",
    "SET_ENTITY_ALPHA": "SetEntityAlpha",
    "RESET_ENTITY_ALPHA": "ResetEntityAlpha",
    "GET_ENTITY_ALPHA": "GetEntityAlpha",
    "GET_ENTITY_SPEED": "GetEntitySpeed",
    "GET_ENTITY_FORWARD_VECTOR": "GetEntityForwardVector",
    "GET_ENTITY_UP_VECTOR": "GetEntityUpVector",
    "GET_ENTITY_RIGHT_VECTOR": "GetEntityRightVector",
    "GET_ENTITY_MATRIX": "GetEntityMatrix",
    "APPLY_FORCE_TO_ENTITY": "ApplyForceToEntity",
    "FREEZE_ENTITY_POSITION": "FreezeEntityPosition",
    "SET_ENTITY_DYNAMIC": "SetEntityDynamic",
    "SET_ENTITY_COLLISION": "SetEntityCollision",
    "GET_ENTITY_COLLISION_DISABLED": "GetEntityCollisionDisabled",
    "GET_CLOSEST_OBJECT_OF_TYPE": "GetClosestObjectOfType",
    "HAS_ENTITY_BEEN_DAMAGED_BY_ENTITY": "HasEntityBeenDamagedByEntity",
    "CLEAR_ENTITY_LAST_DAMAGE_ENTITY": "ClearEntityLastDamageEntity",
    "ATTACH_ENTITY_TO_ENTITY": "AttachEntityToEntity",
    "DETACH_ENTITY": "DetachEntity",
    "IS_ENTITY_ATTACHED": "IsEntityAttached",
    "IS_ENTITY_ATTACHED_TO_ENTITY": "IsEntityAttachedToEntity",
    "GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS": "GetOffsetFromEntityInWorldCoords",

    # Vehicle
    "CREATE_VEHICLE": "CreateVehicle",
    "DELETE_VEHICLE": "DeleteVehicle",
    "DOES_VEHICLE_EXIST": "DoesVehicleExist",
    "GET_VEHICLE_MODEL_TYPE": "GetVehicleModelType",
    "IS_VEHICLE_MODEL": "IsVehicleModel",
    "SET_VEHICLE_ENGINE_ON": "SetVehicleEngineOn",
    "GET_IS_VEHICLE_ENGINE_RUNNING": "GetIsVehicleEngineRunning",
    "SET_VEHICLE_HANDBRAKE": "SetVehicleHandbrake",
    "SET_VEHICLE_FORWARD_SPEED": "SetVehicleForwardSpeed",
    "GET_VEHICLE_SPEED": "GetVehicleSpeed",
    "SET_VEHICLE_ON_GROUND_PROPERLY": "SetVehicleOnGroundProperly",
    "SET_VEHICLE_FIXED": "SetVehicleFixed",
    "SET_VEHICLE_DEFORMATION_FIXED": "SetVehicleDeformationFixed",
    "SET_VEHICLE_DIRT_LEVEL": "SetVehicleDirtLevel",
    "GET_VEHICLE_DIRT_LEVEL": "GetVehicleDirtLevel",
    "SET_VEHICLE_CUSTOM_PRIMARY_COLOUR": "SetVehicleCustomPrimaryColour",
    "SET_VEHICLE_CUSTOM_SECONDARY_COLOUR": "SetVehicleCustomSecondaryColour",
    "SET_VEHICLE_LIVERY": "SetVehicleLivery",
    "SET_VEHICLE_MOD": "SetVehicleMod",
    "SET_VEHICLE_MOD_KIT": "SetVehicleModKit",
    "REMOVE_VEHICLE_MOD": "RemoveVehicleMod",
    "GET_NUM_VEHICLE_MODS": "GetNumVehicleMods",
    "GET_VEHICLE_MOD": "GetVehicleMod",
    "GET_NUM_VEHICLE_MOD_KITS": "GetNumVehicleModKits",
    "GET_VEHICLE_MOD_TYPE_AND_INDEX": "GetVehicleModTypeAndIndex",
    "SET_VEHICLE_WHEELS_CAN_BREAK": "SetVehicleWheelsCanBreak",
    "SET_VEHICLE_TYRE_BURST": "SetVehicleTyreBurst",
    "FIX_VEHICLE_TYRE": "FixVehicleTyre",
    "IS_VEHICLE_TYRE_BURST": "IsVehicleTyreBurst",
    "SET_VEHICLE_DOOR_OPEN": "SetVehicleDoorOpen",
    "SET_VEHICLE_DOORS_SHUT": "SetVehicleDoorsShut",
    "SET_VEHICLE_DOOR_BROKEN": "SetVehicleDoorBroken",
    "_SET_VEHICLE_DOOR_CAN_BREAK": "SetVehicleDoorCanBreak",
    "GET_VEHICLE_DOOR_LOCK_STATUS": "GetVehicleDoorLockStatus",
    "SET_VEHICLE_DOORS_LOCKED": "SetVehicleDoorsLocked",
    "SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS": "SetVehicleDoorsLockedForAllPlayers",
    "SET_VEHICLE_NUMBER_PLATE_TEXT": "SetVehicleNumberPlateText",
    "GET_VEHICLE_NUMBER_PLATE_TEXT": "GetVehicleNumberPlateText",
    "SET_VEHICLE_ALARM": "SetVehicleAlarm",
    "START_VEHICLE_ALARM": "StartVehicleAlarm",
    "IS_VEHICLE_ALARM_ACTIVATED": "IsVehicleAlarmActivated",
    "GET_VEHICLE_CLASS": "GetVehicleClass",
    "IS_VEHICLE_SEAT_FREE": "IsVehicleSeatFree",
    "GET_PED_IN_VEHICLE_SEAT": "GetPedInVehicleSeat",
    "GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS": "GetVehicleMaxNumberOfPassengers",
    "SET_VEHICLE_INVINCIBLE": "SetVehicleInvincible",
    "IS_VEHICLE_DRIVEABLE": "IsVehicleDriveable",
    "SET_VEHICLE_GRAVITY": "SetVehicleGravity",
    "OVERRIDE_VEH_INDICATOR_LIGHTS": "OverrideVehIndicatorLights",
    "SET_VEHICLE_LIGHTS_MODE": "SetVehicleLightsMode",
    "SET_VEHICLE_INDICATOR_LIGHTS": "SetVehicleIndicatorLights",
    "GET_VEHICLE_BODY_HEALTH": "GetVehicleBodyHealth",
    "SET_VEHICLE_BODY_HEALTH": "SetVehicleBodyHealth",
    "GET_VEHICLE_ENGINE_HEALTH": "GetVehicleEngineHealth",
    "SET_VEHICLE_ENGINE_HEALTH": "SetVehicleEngineHealth",
    "SET_VEHICLE_PETROL_TANK_HEALTH": "SetVehiclePetrolTankHealth",
    "GET_VEHICLE_PETROL_TANK_HEALTH": "GetVehiclePetrolTankHealth",
    "SET_VEHICLE_BOOST_ACTIVE": "SetVehicleBoostActive",
    "GET_VEHICLE_ACCELERATION": "GetVehicleAcceleration",
    "MODIFY_VEHICLE_TOP_SPEED": "ModifyVehicleTopSpeed",
    "SET_VEHICLE_REDUCES_GRIP": "SetVehicleReducesGrip",
    "GET_ALL_VEHICLE_MODEL_VARIATIONS": "GetAllVehicleModelVariations",
    "SET_VEHICLE_HORN": "SetVehicleHorn",
    "SET_VEH_EXCLUSIVE_DRIVER": "SetVehExclusiveDriver",
    "GET_VEHICLE_STEERING_ANGLE": "GetVehicleSteeringAngle",
    "SET_VEHICLE_STEERING_ANGLE": "SetVehicleSteeringAngle",
    "SET_VEHICLE_STEERING_BIAS": "SetVehicleSteeringBias",
    "GET_VEHICLE_SUSPENSION_HEIGHT": "GetVehicleSuspensionHeight",
    "TASK_VEHICLE_TEMP_ACTION": "TaskVehicleTempAction",
    "SET_VEHICLE_NEON_ENABLED": "SetVehicleNeonEnabled",
    "SET_VEHICLE_NEON_COLOUR": "SetVehicleNeonColour",
    "GET_VEHICLE_NEON_ENABLED": "GetVehicleNeonEnabled",
    "GET_IS_VEHICLE_SIREN_ON": "GetIsVehicleSirenOn",
    "SET_VEH_INDICATOR_LIGHTS_OVERRIDE": "SetVehIndicatorLightsOverride",

    # World / Object
    "ADD_EXPLOSION": "AddExplosion",
    "CREATE_OBJECT": "CreateObject",
    "CREATE_OBJECT_NO_OFFSET": "CreateObjectNoOffset",
    "DELETE_OBJECT": "DeleteObject",
    "GET_GROUND_Z_FOR_3D_COORD": "GetGroundZFor3dCoord",
    "GET_CLOSEST_VEHICLE": "GetClosestVehicle",
    "GET_CLOSEST_PED": "GetClosestPed",
    "GET_NEARBY_PEDS": "GetNearbyPeds",
    "GET_NEARBY_VEHICLES": "GetNearbyVehicles",
    "GET_NEARBY_OBJECTS": "GetNearbyObjects",
    "GET_DISTANCE_BETWEEN_COORDS": "GetDistanceBetweenCoords",
    "GET_ANGLE_BETWEEN_2D_VECTORS": "GetAngleBetween2dVectors",
    "GET_MAP_DIRECTIONS_TO_COORD": "GetMapDirectionsToCoord",
    "CLEAR_AREA": "ClearArea",
    "CLEAR_AREA_OF_PEDS": "ClearAreaOfPeds",
    "CLEAR_AREA_OF_VEHICLES": "ClearAreaOfVehicles",
    "CLEAR_AREA_OF_OBJECTS": "ClearAreaOfObjects",
    "SET_GRAVITY_LEVEL": "SetGravityLevel",
    "ADD_STUNT_JUMP": "AddStuntJump",
    "REMOVE_STUNT_JUMP": "RemoveStuntJump",
    "CREATE_PED_INSIDE_VEHICLE": "CreatePedInsideVehicle",
    "GET_ALL_OBJECTS": "GetGamePool",  # special case handled below
    "GET_ALL_PICKUPS": "GetGamePool",  # special case handled below
    "SET_WEATHER_TYPE_NOW": "SetWeatherTypeNow",
    "SET_WEATHER_TYPE_NOW_PERSIST": "SetWeatherTypeNowPersist",
    "SET_RAIN_LEVEL": "SetRainLevel",
    "SET_WIND_SPEED": "SetWindSpeed",
    "SET_WIND_DIRECTION": "SetWindDirection",
    "GET_RAIN_LEVEL": "GetRainLevel",
    "FORCE_WEATHER_NOW": "ForceWeatherNow",
    "SET_CLOCK_TIME": "SetClockTime",
    "GET_CLOCK_HOURS": "GetClockHours",
    "GET_CLOCK_MINUTES": "GetClockMinutes",
    "SET_TIME_SCALE": "SetTimeScale",
    "PAUSE_CLOCK": "PauseClock",

    # Camera
    "CREATE_CAM": "CreateCam",
    "DESTROY_CAM": "DestroyCam",
    "RENDER_SCRIPT_CAMS": "RenderScriptCams",
    "SET_CAM_ACTIVE": "SetCamActive",
    "GET_CAM_COORD": "GetCamCoord",
    "SET_CAM_COORD": "SetCamCoord",
    "SET_CAM_ROT": "SetCamRot",
    "GET_CAM_ROT": "GetCamRot",
    "SET_CAM_FOV": "SetCamFov",
    "GET_CAM_FOV": "GetCamFov",
    "GET_GAMEPLAY_CAM_COORD": "GetGameplayCamCoord",
    "GET_GAMEPLAY_CAM_ROT": "GetGameplayCamRot",
    "GET_GAMEPLAY_CAM_FOV": "GetGameplayCamFov",
    "SET_GAMEPLAY_CAM_SHAKE_AMPLITUDE": "SetGameplayCamShakeAmplitude",
    "SHAKE_GAMEPLAY_CAM": "ShakeGameplayCam",
    "STOP_GAMEPLAY_CAM_SHAKING": "StopGameplayCamShaking",
    "SET_CAM_SHAKE_AMPLITUDE": "SetCamShakeAmplitude",
    "LOCK_MINIMAP_POSITION": "LockMinimapPosition",
    "UNLOCK_MINIMAP_POSITION": "UnlockMinimapPosition",
    "SET_MINIMAP_HIDE_FOW": "SetMinimapHideFow",

    # HUD / UI
    "BEGIN_TEXT_COMMAND_DISPLAY_HELP": "BeginTextCommandDisplayHelp",
    "END_TEXT_COMMAND_DISPLAY_HELP": "EndTextCommandDisplayHelp",
    "BEGIN_TEXT_COMMAND_DISPLAY_TEXT": "BeginTextCommandDisplayText",
    "END_TEXT_COMMAND_DISPLAY_TEXT": "EndTextCommandDisplayText",
    "ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME": "AddTextComponentSubstringPlayerName",
    "ADD_TEXT_COMPONENT_INTEGER": "AddTextComponentInteger",
    "ADD_TEXT_COMPONENT_FLOAT": "AddTextComponentFloat",
    "DRAW_TEXT": "DrawText",
    "SET_TEXT_SCALE": "SetTextScale",
    "SET_TEXT_COLOUR": "SetTextColour",
    "SET_TEXT_FONT": "SetTextFont",
    "SET_TEXT_DROP_SHADOW": "SetTextDropShadow",
    "DRAW_RECT": "DrawRect",
    "DRAW_SPRITE": "DrawSprite",
    "HAS_STREAMED_TEXTURE_DICT_LOADED": "HasStreamedTextureDictLoaded",
    "REQUEST_STREAMED_TEXTURE_DICT": "RequestStreamedTextureDict",
    "SET_MINIMAP_COMPONENT_POSITION": "SetMinimapComponentPosition",
    "DISPLAY_HUD": "DisplayHud",
    "DISPLAY_RADAR": "DisplayRadar",
    "FLASH_MINIMAP_DISPLAY": "FlashMinimapDisplay",
    "SET_HUD_COMPONENT_POSITION": "SetHudComponentPosition",
    "SET_HUD_COMPONENT_VISIBLE": "SetHudComponentVisible",

    # Audio
    "PLAY_SOUND": "PlaySound",
    "PLAY_SOUND_FRONTEND": "PlaySoundFrontend",
    "PLAY_SOUND_FROM_ENTITY": "PlaySoundFromEntity",
    "PLAY_SOUND_FROM_COORD": "PlaySoundFromCoord",
    "STOP_SOUND": "StopSound",
    "PLAY_AMBIENT_SPEECH1": "PlayAmbientSpeech1",
    "PLAY_PED_AMBIENT_SPEECH_NATIVE": "PlayPedAmbientSpeechNative",
    "SET_AUDIO_FLAG": "SetAudioFlag",

    # Particle FX
    "REQUEST_NAMED_PTFX_ASSET": "RequestNamedPtfxAsset",
    "HAS_NAMED_PTFX_ASSET_LOADED": "HasNamedPtfxAssetLoaded",
    "REMOVE_NAMED_PTFX_ASSET": "RemoveNamedPtfxAsset",
    "USE_PARTICLE_FX_ASSET": "UseParticleFxAsset",
    "START_PARTICLE_FX_NON_LOOPED_AT_COORD": "StartParticleFxNonLoopedAtCoord",
    "START_PARTICLE_FX_NON_LOOPED_ON_ENTITY": "StartParticleFxNonLoopedOnEntity",
    "START_PARTICLE_FX_LOOPED_ON_ENTITY": "StartParticleFxLoopedOnEntity",
    "START_PARTICLE_FX_LOOPED_AT_COORD": "StartParticleFxLoopedAtCoord",
    "STOP_PARTICLE_FX_LOOPED": "StopParticleFxLooped",
    "REMOVE_PARTICLE_FX_FROM_ENTITY": "RemoveParticleFxFromEntity",
    "GET_ALL_PARTICLE_FX_NAMES": "GetAllParticleFxNames",

    # Model
    "REQUEST_MODEL": "RequestModel",
    "HAS_MODEL_LOADED": "HasModelLoaded",
    "SET_MODEL_AS_NO_LONGER_NEEDED": "SetModelAsNoLongerNeeded",
    "IS_MODEL_VALID": "IsModelValid",
    "IS_MODEL_A_VEHICLE": "IsModelAVehicle",
    "IS_MODEL_A_PED": "IsModelAPed",
    "GET_HASH_KEY": "GetHashKey",

    # Network / misc
    "GET_GAME_TIMER": "GetGameTimer",
    "GET_FRAME_TIME": "GetFrameTime",
    "GET_RANDOM_INT_IN_RANGE": "GetRandomIntInRange",
    "GET_RANDOM_FLOAT_IN_RANGE": "GetRandomFloatInRange",
    "GET_WAYPOINT_COORD": "GetWaypointCoord",
    "SET_NEW_WAYPOINT": "SetNewWaypoint",
    "NETWORK_IS_SESSION_STARTED": "NetworkIsSessionStarted",
    "GET_PLAYER_COUNT": "GetPlayerCount",

    # Scripted camera / screen
    "SET_NIGHTVISION": "SetNightvision",
    "SET_SEETHROUGH": "SetSeethrough",
    "SET_TIMECYCLE_MODIFIER": "SetTimecycleModifier",
    "SET_TIMECYCLE_MODIFIER_STRENGTH": "SetTimecycleModifierStrength",
    "CLEAR_TIMECYCLE_MODIFIER": "ClearTimecycleModifier",
    "ANIMATE_GAME_CAM": "AnimateGameCam",
    "SET_CINEMATIC_MODE_ACTIVE": "SetCinematicModeActive",
    "DISABLE_CONTROL_ACTION": "DisableControlAction",
    "ENABLE_CONTROL_ACTION": "EnableControlAction",
    "IS_CONTROL_PRESSED": "IsControlPressed",
    "IS_CONTROL_JUST_PRESSED": "IsControlJustPressed",
    "IS_DISABLED_CONTROL_PRESSED": "IsDisabledControlPressed",
    "SCREEN_FADE_OUT": "DoScreenFadeOut",
    "SCREEN_FADE_IN": "DoScreenFadeIn",
    "IS_SCREEN_FADED_OUT": "IsScreenFadedOut",
    "DRAW_SCALEFORM_MOVIE_FULLSCREEN": "DrawScaleformMovieFullscreen",
    "ANIMATE_PAUSE": "AnimatePause",

    # Memory namespace -> FiveM equivalents
    "Memory::ApplyForceToEntity": "ApplyForceToEntity",
    "ENTITY::GET_ENTITY_COORDS": "GetEntityCoords",
    "ENTITY::SET_ENTITY_COORDS": "SetEntityCoords",
    "ENTITY::SET_ENTITY_VELOCITY": "SetEntityVelocity",
    "ENTITY::GET_ENTITY_VELOCITY": "GetEntityVelocity",
    "PLAYER::PLAYER_PED_ID": "PlayerPedId",
    "PLAYER::PLAYER_ID": "PlayerId",

    # Missing natives from scan
    "ADD_RELATIONSHIP_GROUP": "AddRelationshipGroup",
    "SET_BLOCKING_OF_NON_TEMPORARY_EVENTS": "SetBlockingOfNonTemporaryEvents",
    "SET_PED_HEARING_RANGE": "SetPedHearingRange",
    "IS_PED_DEAD_OR_DYING": "IsPedDeadOrDying",
    "GET_VEHICLE_MODEL_NUMBER_OF_SEATS": "GetVehicleModelNumberOfSeats",
    "APPLY_PED_DAMAGE_PACK": "ApplyPedDamagePack",
    "SET_PED_SUFFERS_CRITICAL_HITS": "SetPedSuffersCriticalHits",
    "SET_PED_AS_NO_LONGER_NEEDED": "SetPedAsNoLongerNeeded",
    "IS_ENTITY_A_MISSION_ENTITY": "IsEntityAMissionEntity",
    "GET_SELECTED_PED_WEAPON": "GetSelectedPedWeapon",
    "BEGIN_SCALEFORM_MOVIE_METHOD": "BeginScaleformMovieMethod",
    "GET_MODEL_DIMENSIONS": "GetModelDimensions",
    "SCALEFORM_MOVIE_METHOD_ADD_PARAM_PLAYER_NAME_STRING": "ScaleformMovieMethodAddParamPlayerNameString",
    "END_SCALEFORM_MOVIE_METHOD": "EndScaleformMovieMethod",
    "GET_PLAYER_GROUP": "GetPlayerGroup",
    "SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT": "SetPedCanRagdollFromPlayerImpact",
    "SET_RAGDOLL_BLOCKING_FLAGS": "SetRagdollBlockingFlags",
    "SHOOT_SINGLE_BULLET_BETWEEN_COORDS": "ShootSingleBulletBetweenCoords",
    "SET_ENTITY_PROOFS": "SetEntityProofs",
    "SET_PED_AS_GROUP_MEMBER": "SetPedAsGroupMember",
    "EXPLODE_VEHICLE": "ExplodeVehicle",
    "IS_PED_SHOOTING": "IsPedShooting",
    "GET_WEAPON_DAMAGE_TYPE": "GetWeaponDamageType",
    "TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE": "TaskVehicleDriveToCoordLongrange",
    "SET_VEHICLE_COLOURS": "SetVehicleColours",
    "SET_PED_KEEP_TASK": "SetPedKeepTask",
    "SET_PED_INFINITE_AMMO_CLIP": "SetPedInfiniteAmmoClip",
    "GET_ENTITY_SPEED_VECTOR": "GetEntitySpeedVector",
    "TOGGLE_VEHICLE_MOD": "ToggleVehicleMod",
    "HAS_SCALEFORM_MOVIE_LOADED": "HasScaleformMovieLoaded",
    "IS_PED_HUMAN": "IsPedHuman",
    "SET_VEHICLE_TYRES_CAN_BURST": "SetVehicleTyresCanBurst",
    "GET_PED_TYPE": "GetPedType",
    "TASK_LEAVE_VEHICLE": "TaskLeaveVehicle",
    "CLEAR_ENTITY_LAST_WEAPON_DAMAGE": "ClearEntityLastWeaponDamage",
    "REQUEST_ANIM_DICT": "RequestAnimDict",
    "TASK_PLAY_ANIM": "TaskPlayAnim",
    "SET_PLAYER_CONTROL": "SetPlayerControl",
    "SET_VEHICLE_REDUCE_GRIP": "SetVehicleReduceGrip",
    "GET_CURRENT_PED_WEAPON_ENTITY_INDEX": "GetCurrentPedWeaponEntityIndex",
    "GET_VEHICLE_PED_IS_ENTERING": "GetVehiclePedIsEntering",
    "SET_GAMEPLAY_CAM_RELATIVE_HEADING": "SetGameplayCamRelativeHeading",
    "REQUEST_SCALEFORM_MOVIE": "RequestScaleformMovie",
    "SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT": "ScaleformMovieMethodAddParamInt",
    "IS_PED_INJURED": "IsPedInjured",
    "REMOVE_ANIM_DICT": "RemoveAnimDict",
    "SET_VEHICLE_AS_NO_LONGER_NEEDED": "SetVehicleAsNoLongerNeeded",
    "GET_BLIP_COORDS": "GetBlipCoords",
    "GET_FIRST_BLIP_INFO_ID": "GetFirstBlipInfoId",
    "GET_VEHICLE_MODEL_ESTIMATED_MAX_SPEED": "GetVehicleModelEstimatedMaxSpeed",
    "GET_ENTITY_BONE_INDEX_BY_NAME": "GetEntityBoneIndexByName",
    "HAS_WEAPON_ASSET_LOADED": "HasWeaponAssetLoaded",
    "GET_ENTITY_HEIGHT_ABOVE_GROUND": "GetEntityHeightAboveGround",
    "IS_THIS_MODEL_A_HELI": "IsThisModelAHeli",
    "IS_THIS_MODEL_A_PLANE": "IsThisModelAPlane",
    "IS_PED_WEAPON_READY_TO_SHOOT": "IsPedWeaponReadyToShoot",
    "GET_GAMEPLAY_CAM_RELATIVE_HEADING": "GetGameplayCamRelativeHeading",
    "HAS_ENTITY_COLLIDED_WITH_ANYTHING": "HasEntityCollidedWithAnything",
    "SET_OBJECT_AS_NO_LONGER_NEEDED": "SetObjectAsNoLongerNeeded",
    "SET_VEHICLE_TYRE_SMOKE_COLOR": "SetVehicleTyreSmokeColor",
    "HAS_ANIM_DICT_LOADED": "HasAnimDictLoaded",
    "TASK_HANDS_UP": "TaskHandsUp",
    "SET_ENTITY_LOAD_COLLISION_FLAG": "SetEntityLoadCollisionFlag",
    "HAS_COLLISION_LOADED_AROUND_ENTITY": "HasCollisionLoadedAroundEntity",
    "GET_PED_WEAPON_AT_BONE_INDEX": "GetPedWeaponAtBoneIndex",
    "IS_PED_GOING_TO_BE_RAGDOLLED": "IsPedGoingToBeRagdolled",
    "IS_ENTITY_TOUCHING_ENTITY": "IsEntityTouchingEntity",
    "GET_ACTIVATION_ZONE_FOR_ENTITY": "GetActivationZoneForEntity",
    "ADD_BLIP_FOR_ENTITY": "AddBlipForEntity",
    "REMOVE_BLIP": "RemoveBlip",
    "SET_BLIP_SPRITE": "SetBlipSprite",
    "SET_BLIP_COLOUR": "SetBlipColour",
    "SET_BLIP_SCALE": "SetBlipScale",
    "SET_BLIP_AS_SHORT_RANGE": "SetBlipAsShortRange",
    "GET_NEXT_BLIP_INFO_ID": "GetNextBlipInfoId",
    "DOES_BLIP_EXIST": "DoesBlipExist",
    "ADD_BLIP_FOR_COORD": "AddBlipForCoord",
    "SET_RADAR_BIG_MAP_ENABLED": "SetRadarBigMapEnabled",
    "SET_MAP_FULL_ZOOM": "SetMapFullZoom",
    "NETWORK_REQUEST_CONTROL_OF_ENTITY": "NetworkRequestControlOfEntity",
    "NETWORK_HAS_CONTROL_OF_ENTITY": "NetworkHasControlOfEntity",
    "NETWORK_GET_ENTITY_IS_NETWORKED": "NetworkGetEntityIsNetworked",
    "NETWORK_REGISTER_ENTITY_AS_NETWORKED": "NetworkRegisterEntityAsNetworked",
    "OBJ_TO_NET": "ObjToNet",
    "NET_TO_OBJ": "NetToObj",
    "VEH_TO_NET": "VehToNet",
    "NET_TO_VEH": "NetToVeh",
    "PED_TO_NET": "PedToNet",
    "NET_TO_PED": "NetToPed",
    "IS_PED_IN_GROUP": "IsPedInGroup",
    "GET_PED_GROUP_LEADER": "GetPedGroupLeader",
    "GET_PED_GROUP_INDEX": "GetPedGroupIndex",
    "SET_PED_FOLLOW_NAVMESH_RECORDING": "SetPedFollowNavmeshRecording",
    "TASK_GO_STRAIGHT_TO_COORD": "TaskGoStraightToCoord",
    "TASK_TURN_PED_TO_FACE_ENTITY": "TaskTurnPedToFaceEntity",
    "TASK_LOOK_AT_ENTITY": "TaskLookAtEntity",
    "TASK_SMART_FLEE_PED": "TaskSmartFleePed",
    "TASK_REACT_AND_FLEE_PED": "TaskReactAndFleePed",
    "TASK_GUARD_CURRENT_POSITION": "TaskGuardCurrentPosition",
    "TASK_USE_MOBILE_PHONE": "TaskUseMobilePhone",
    "IS_PED_USING_ACTION_MODE": "IsPedUsingActionMode",
    "SET_PED_USING_ACTION_MODE": "SetPedUsingActionMode",
    "GET_RANDOM_VEHICLE_MODEL_IN_MEMORY": "GetRandomVehicleModelInMemory",
    "SPAWN_VEHICLE_ON_NEXT_PLACEMENT": "SpawnVehicleOnNextPlacement",
    "GET_VEHICLE_COLOURS": "GetVehicleColours",
    "GET_VEHICLE_EXTRA_COLOURS": "GetVehicleExtraColours",
    "SET_VEHICLE_EXTRA_COLOURS": "SetVehicleExtraColours",
    "IS_VEHICLE_EXTRA_TURNED_ON": "IsVehicleExtraTurnedOn",
    "SET_VEHICLE_EXTRA": "SetVehicleExtra",
    "GET_VEHICLE_MOD_VARIATION": "GetVehicleModVariation",
    "IS_VEHICLE_SIREN_ON": "IsVehicleSirenOn",
    "IS_VEHICLE_IN_BURNOUT": "IsVehicleInBurnout",
    "IS_VEHICLE_STOPPED": "IsVehicleStopped",
    "IS_VEHICLE_ON_ALL_WHEELS": "IsVehicleOnAllWheels",
    "SET_VEHICLE_FORWARD_SPEED": "SetVehicleForwardSpeed",
    "GET_VEHICLE_FORWARD_SPEED": "GetVehicleForwardSpeed",
    "SET_VEHICLE_CURRENT_RPM": "SetVehicleCurrentRpm",
    "GET_VEHICLE_CURRENT_RPM": "GetVehicleCurrentRpm",
    "GET_VEHICLE_CLUTCH": "GetVehicleClutch",
    "SET_VEHICLE_CLUTCH": "SetVehicleClutch",
    "GET_VEHICLE_TURBO_PRESSURE": "GetVehicleTurboPressure",
    "SET_VEHICLE_TURBO_PRESSURE": "SetVehicleTurboPressure",
    "GET_VEHICLE_WHEELIE_STATE": "GetVehicleWheelieState",
    "SET_VEHICLE_WHEELIE_STATE": "SetVehicleWheelieState",
    "IS_VEHICLE_MODEL": "IsVehicleModel",
    "IS_THIS_MODEL_A_CAR": "IsThisModelACar",
    "IS_THIS_MODEL_A_BIKE": "IsThisModelABike",
    "IS_THIS_MODEL_A_BOAT": "IsThisModelABoat",
    "IS_THIS_MODEL_AN_EMERGENCY_SERVICE_VEHICLE": "IsThisModelAnEmergencyServiceVehicle",
    "SET_VEHICLE_POPULATION_BUDGET": "SetVehiclePopulationBudget",
    "SET_PED_POPULATION_BUDGET": "SetPedPopulationBudget",
    "SET_GARBAGE_TRUCKS": "SetGarbageTrucks",
    "SET_RANDOM_TRAINS": "SetRandomTrains",
    "SET_RANDOM_BOATS": "SetRandomBoats",
    "SET_PARKED_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME": "SetParkedVehicleDensityMultiplierThisFrame",
    "SET_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME": "SetVehicleDensityMultiplierThisFrame",
    "SET_PED_DENSITY_MULTIPLIER_THIS_FRAME": "SetPedDensityMultiplierThisFrame",
    "SET_SCENARIO_PED_DENSITY_MULTIPLIER_THIS_FRAME": "SetScenarioPedDensityMultiplierThisFrame",
    "IS_MODEL_IN_CDIMAGE": "IsModelInCdimage",
    "GET_RANDOM_INT": "GetRandomIntInRange",
    "REQUEST_WEAPON_ASSET": "RequestWeaponAsset",
    "REMOVE_WEAPON_ASSET": "RemoveWeaponAsset",
    "CREATE_WEAPON_OBJECT": "CreateWeaponObject",
    "DELETE_WEAPON_OBJECT": "DeleteWeaponObject",
    "GET_BEST_PED_WEAPON": "GetBestPedWeapon",
    "HAS_PED_BEEN_DAMAGED_BY_WEAPON": "HasPedBeenDamagedByWeapon",
    "SET_PED_DROPS_INVENTORY_WEAPON": "SetPedDropsInventoryWeapon",
    "GET_ALL_WEAPON_HASHES_OF_TYPE": "GetAllWeaponHashesOfType",
    "IS_WAYPOINT_ACTIVE": "IsWaypointActive",
    "GET_ENTITY_POPULATION_TYPE": "GetEntityPopulationType",
    "SET_ENTITY_POPULATION_TYPE": "SetEntityPopulationType",
    "GET_ZONE_AT_COORDS": "GetZoneAtCoords",
    "GET_ZONE_SCUM_FREQ": "GetZoneScumFreq",
    "GET_GROUND_Z_AND_NORMAL_FOR_3D_COORD": "GetGroundZAndNormalFor3dCoord",
    "TEST_PROBE_AGAINST_WATER": "TestProbeAgainstWater",
    "TEST_VERTICAL_PROBE_AGAINST_ALL_WATER": "TestVerticalProbeAgainstAllWater",
    "GET_WATER_HEIGHT": "GetWaterHeight",
    "GET_WATER_HEIGHT_NO_WAVES": "GetWaterHeightNoWaves",
    "MODIFY_WATER": "ModifyWater",
    "HAS_ADDITIONAL_TEXT_LOADED": "HasAdditionalTextLoaded",
    "REQUEST_ADDITIONAL_TEXT": "RequestAdditionalText",
    "RELEASE_ADDITIONAL_TEXT": "ReleaseAdditionalText",
    "HAS_SCRIPT_LOADED": "HasScriptLoaded",
    "REQUEST_SCRIPT": "RequestScript",
    "START_NEW_SCRIPT": "StartNewScript",
    "DOES_SCRIPT_EXIST": "DoesScriptExist",
    "REQUEST_SCRIPT_AUDIO_BANK": "RequestScriptAudioBank",
    "RELEASE_SCRIPT_AUDIO_BANK": "ReleaseScriptAudioBank",
    "DRAW_MARKER": "DrawMarker",
    "GET_TICK_COUNT": "GetGameTimer",
    "GET_TICK_COUNT64": "GetGameTimer",
    "GET_TIMERA": "GetTimerA",
    "GET_TIMERB": "GetTimerB",
    "CLEARTIMERA": "ClearTimerA",
    "CLEARTIMERB": "ClearTimerB",
    "SET_ENTITY_MAX_SPEED": "SetEntityMaxSpeed",
    "GET_TIME_SINCE_LAST_DEATH": "GetTimeSinceLastDeath",
    "IS_STUNT_JUMP_HAPPENING": "IsStuntJumpHappening",
    "IS_STUNT_JUMP_MESSAGE_SHOWING": "IsStuntJumpMessageShowing",
    "NETWORK_IS_PLAYER_ACTIVE": "NetworkIsPlayerActive",
    "GET_PLAYER_PED": "GetPlayerPed",
    "GET_PLAYER_NAME": "GetPlayerName",
    "GET_PLAYER_PED_SCRIPT_INDEX": "GetPlayerPedScriptIndex",
    "GET_PLAYER_FROM_PED": "GetPlayerFromPed",
    "GET_ACTIVEPLAYERS": "GetActivePlayers",
    "GET_NUMBER_OF_PLAYERS_IN_GROUP": "GetNumberOfPlayersInGroup",
    "IS_PED_PLAYER": "IsPedPlayer",
    "GET_RANDOM_PED": "GetRandomPed",
    "GET_CLOSEST_VEHICLE_IN_LINE_OF_SIGHT": "GetClosestVehicleInLineOfSight",
    "GET_STREET_NAME_AT_COORD": "GetStreetNameAtCoord",
    "GET_STREET_NAME_FROM_HASH_KEY": "GetStreetNameFromHashKey",
    "ADD_TEXT_ENTRY": "AddTextEntry",
    "BEGIN_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED": "BeginTextCommandIsThisHelpMessageBeingDisplayed",
    "END_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED": "EndTextCommandIsThisHelpMessageBeingDisplayed",
    "SET_NOTIFICATIONTEXT_ENTRY": "SetNotificationtextEntry",
    "DRAW_NOTIFICATION": "DrawNotification",
    "GET_VEHICLE_MAX_SPEED": "GetVehicleMaxSpeed",
    "GET_VEHICLE_ESTIMATED_MAX_SPEED": "GetVehicleEstimatedMaxSpeed",
    "IS_PED_IN_ANY_POLICE_VEHICLE": "IsPedInAnyPoliceVehicle",
    "IS_PED_IN_ANY_TAXI": "IsPedInAnyTaxi",
    "IS_PED_IN_ANY_BOAT": "IsPedInAnyBoat",
    "IS_PED_IN_ANY_HELI": "IsPedInAnyHeli",
    "IS_PED_IN_ANY_PLANE": "IsPedInAnyPlane",
    "SET_RELATIONSHIP_GROUP_DEFAULT_HASH": "SetRelationshipGroupDefaultHash",
    "GET_RELATIONSHIP_BETWEEN_PEDS": "GetRelationshipBetweenPeds",
    "GET_RELATIONSHIP_BETWEEN_GROUPS": "GetRelationshipBetweenGroups",
    "CLEAR_RELATIONSHIP_BETWEEN_GROUPS": "ClearRelationshipBetweenGroups",
    "CLEAR_GROUP": "ClearGroup",
    "CREATE_GROUP": "CreateGroup",
    "SET_GROUP_FORMATION": "SetGroupFormation",
    "SET_GROUP_LEADER": "SetGroupLeader",
    "REMOVE_PED_FROM_GROUP": "RemovePedFromGroup",
    "SCALEFORM_MOVIE_METHOD_ADD_PARAM_FLOAT": "ScaleformMovieMethodAddParamFloat",
    "SCALEFORM_MOVIE_METHOD_ADD_PARAM_BOOL": "ScaleformMovieMethodAddParamBool",
    "SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING": "ScaleformMovieMethodAddParamTextureNameString",
    "END_SCALEFORM_MOVIE_METHOD_RETURN_VALUE_INT": "EndScaleformMovieMethodReturnValueInt",
    "GET_SCALEFORM_MOVIE_METHOD_RETURN_VALUE_INT": "GetScaleformMovieMethodReturnValueInt",
    "CALL_SCALEFORM_MOVIE_METHOD": "CallScaleformMovieMethod",
    "GET_SCALEFORM_MOVIE_HANDLE": "GetScaleformMovieHandle",
    "DRAW_SCALEFORM_MOVIE": "DrawScaleformMovie",
    "SET_SCALEFORM_FIT_RENDERTARGET": "SetScaleformFitRendertarget",
    "SCALEFORM_MOVIE_METHOD_ADD_PARAM_LATEST_BRIEF_STRING": "ScaleformMovieMethodAddParamLatestBriefString",
    "REQUEST_CUTSCENE": "RequestCutscene",
    "HAS_CUTSCENE_LOADED": "HasCutsceneLoaded",
    "START_CUTSCENE": "StartCutscene",
    "STOP_CUTSCENE_IMMEDIATELY": "StopCutsceneImmediately",
    "HAS_CUTSCENE_FINISHED": "HasCutsceneFinished",
    "REMOVE_CUTSCENE": "RemoveCutscene",
    "LOAD_ALL_OBJECTS_NOW": "LoadAllObjectsNow",
    "IS_OBJECT_NEAR_POINT": "IsObjectNearPoint",
    "GET_OBJECT_OFFSET_FROM_COORDS": "GetObjectOffsetFromCoords",
    "GET_COORDS_OF_VEHICLE_ATTACHED_TO_TOW_TRUCK": "GetCoordsOfVehicleAttachedToTowTruck",
    "ATTACH_VEHICLE_TO_TOW_TRUCK": "AttachVehicleToTowTruck",
    "DETACH_VEHICLE_FROM_TOW_TRUCK": "DetachVehicleFromTowTruck",
    "IS_VEHICLE_ATTACHED_TO_TOW_TRUCK": "IsVehicleAttachedToTowTruck",
    "GET_ENTITY_ATTACHED_TO_TOW_TRUCK": "GetEntityAttachedToTowTruck",
    "SET_VEHICLE_EXTRA_COLL_STRENGTH": "SetVehicleExtraCollStrength",
    "SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED": "SetVehicleCanBeVisiblyDamaged",
    "SET_VEHICLE_WHEEL_BREAK_FORCE": "SetVehicleWheelBreakForce",
    "GET_ENTITY_SURFACE_NORMAL": "GetEntitySurfaceNormal",
    "SET_GAMEPLAY_CAM_RELATIVE_PITCH": "SetGameplayCamRelativePitch",
    "GET_GAMEPLAY_CAM_RELATIVE_PITCH": "GetGameplayCamRelativePitch",
    "SET_FOLLOW_VEHICLE_CAM_VIEW_MODE": "SetFollowVehicleCamViewMode",
    "GET_FOLLOW_VEHICLE_CAM_VIEW_MODE": "GetFollowVehicleCamViewMode",
    "SET_FOLLOW_PED_CAM_VIEW_MODE": "SetFollowPedCamViewMode",
    "GET_FOLLOW_PED_CAM_VIEW_MODE": "GetFollowPedCamViewMode",
    "IS_GAMEPLAY_CAM_LOOKING_BEHIND": "IsGameplayCamLookingBehind",
    "IS_GAMEPLAY_CAM_RENDERING": "IsGameplayCamRendering",
    "GET_CAMERA_MODE": "GetCameraMode",
    "SET_CAMERA_MODE": "SetCameraMode",
    "GET_NEAREST_PLAYER_TO_ENTITY": "GetNearestPlayerToEntity",
    "OVERRIDE_WIND_SPEED": "OverrideWindSpeed",
    "OVERRIDE_WIND_DIRECTION": "OverrideWindDirection",
    "CLEAR_OVERRIDE_WIND_SPEED": "ClearOverrideWindSpeed",
    "CLEAR_OVERRIDE_WIND_DIRECTION": "ClearOverrideWindDirection",
    "GET_WEATHER_TYPE_TRANSITION": "GetWeatherTypeTransition",
    "SET_WEATHER_TYPE_TRANSITION": "SetWeatherTypeTransition",
    "CLEAR_WEATHER_TYPE_PERSIST": "ClearWeatherTypePersist",
    "GET_PREV_WEATHER_TYPE_HASH_NAME": "GetPrevWeatherTypeHashName",
    "GET_NEXT_WEATHER_TYPE_HASH_NAME": "GetNextWeatherTypeHashName",
    "IS_NEXT_WEATHER_TYPE": "IsNextWeatherType",
    "NETWORK_IS_PARTICIPANT_ACTIVE": "NetworkIsParticipantActive",
    "NETWORK_GET_PLAYER_INDEX": "NetworkGetPlayerIndex",
    "GET_PLAYER_INDEX": "GetPlayerIndex",
    "IS_PLAYER_ONLINE": "IsPlayerOnline",
    "TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS": "TaskSetBlockingOfNonTemporaryEvents",
    "TASK_DRIVE_BY": "TaskDriveBy",
    "TASK_ENTER_VEHICLE": "TaskEnterVehicle",
    "TASK_DRIVE_WANDER": "TaskDriveWander",
    "TASK_FOLLOW_TO_OFFSET_OF_ENTITY": "TaskFollowToOffsetOfEntity",
    "TASK_GOTO_ENTITY_OFFSET_XY": "TaskGotoEntityOffsetXy",
    "TASK_TURN_PED_TO_FACE_COORD": "TaskTurnPedToFaceCoord",
    "TASK_JUMP": "TaskJump",
    "TASK_CLIMB": "TaskClimb",
    "TASK_SWIM_TO_COORD": "TaskSwimToCoord",
    "TASK_FOLLOW_NAV_MESH_TO_COORD": "TaskFollowNavMeshToCoord",
    "TASK_PARACHUTE": "TaskParachute",
    "TASK_PARACHUTE_TO_TARGET": "TaskParachuteToTarget",
    "TASK_OPEN_PARACHUTE": "TaskOpenParachute",
    "TASK_SHOOT_GUN_AT_COORD": "TaskShootGunAtCoord",
    "TASK_SHOOT_GUN_AT_ENTITY": "TaskShootGunAtEntity",
    "TASK_MELEE_ATTACK_PED": "TaskMeleeAttackPed",
    "TASK_VEHICLE_SHOOT_AT_PED": "TaskVehicleShootAtPed",
    "TASK_VEHICLE_AIM_AT_PED": "TaskVehicleAimAtPed",
    "TASK_VEHICLE_AIM_AT_COORD": "TaskVehicleAimAtCoord",
    "TASK_VEHICLE_CHASE": "TaskVehicleChase",
    "TASK_VEHICLE_RAM": "TaskVehicleRam",
    "TASK_VEHICLE_GOTO_NAVMESH": "TaskVehicleGotoNavmesh",
    "TASK_VEHICLE_STOP": "TaskVehicleStop",
    "TASK_VEHICLE_FOLLOW": "TaskVehicleFollow",
    "TASK_VEHICLE_TRANSFORM": "TaskVehicleTransform",
    "TASK_HELICOPTER_MISSION": "TaskHelicopterMission",
    "TASK_PLANE_MISSION": "TaskPlaneMission",
    "TASK_BOAT_MISSION": "TaskBoatMission",
    "TASK_SET_PED_DECISION_MAKER": "TaskSetPedDecisionMaker",
    "TASK_COMBAT_HATED_TARGETS_AROUND_PED": "TaskCombatHatedTargetsAroundPed",
    "TASK_COMBAT_HATED_TARGETS_IN_AREA": "TaskCombatHatedTargetsInArea",
    "IS_PED_IN_COMBAT": "IsPedInCombat",
    "IS_PED_FLEEING": "IsPedFleeing",
    "IS_PED_WALKING": "IsPedWalking",
    "IS_PED_RUNNING": "IsPedRunning",
    "IS_PED_SPRINTING": "IsPedSprinting",
    "IS_PED_CLIMBING": "IsPedClimbing",
    "IS_PED_JUMPING": "IsPedJumping",
    "IS_PED_FALLING": "IsPedFalling",
    "IS_PED_GETTING_INTO_A_VEHICLE": "IsPedGettingIntoAVehicle",
    "IS_PED_TRYING_TO_ENTER_A_LOCKED_VEHICLE": "IsPedTryingToEnterALockedVehicle",
    "IS_PED_ON_VEHICLE": "IsPedOnVehicle",
    "IS_PED_ON_SPECIFIC_VEHICLE": "IsPedOnSpecificVehicle",
    "IS_PED_BEING_STEALTH_KILLED": "IsPedBeingStealthKilled",
    "IS_PED_RELOADING": "IsPedReloading",
    "GET_PED_STEALTH_MOVEMENT": "GetPedStealthMovement",
    "SET_PED_STEALTH_MOVEMENT": "SetPedStealthMovement",
    "FORCE_PED_AI_AND_ANIMATION_UPDATE": "ForcePedAiAndAnimationUpdate",
    "SET_PED_PATH_CAN_USE_CLIMBOVERS": "SetPedPathCanUseClimbovers",
    "SET_PED_PATH_CAN_USE_LADDERS": "SetPedPathCanUseLadders",
    "SET_PED_PATH_AVOID_FIRE": "SetPedPathAvoidFire",
    "SET_PED_PATH_PREFER_PAVEMENT": "SetPedPathPreferPavement",
    "GET_ENTITY_PITCH": "GetEntityPitch",
    "GET_ENTITY_ROLL": "GetEntityRoll",
    "SET_VEHICLE_JET_ENGINE_STATE": "SetVehicleJetEngineState",
    "IS_VEHICLE_WINDOW_INTACT": "IsVehicleWindowIntact",
    "FIX_VEHICLE_WINDOW": "FixVehicleWindow",
    "SMASH_VEHICLE_WINDOW": "SmashVehicleWindow",
    "ROLL_DOWN_WINDOWS": "RollDownWindows",
    "ROLL_UP_WINDOW": "RollUpWindow",
    "ROLL_DOWN_WINDOW": "RollDownWindow",
    "IS_CAM_ACTIVE": "IsCamActive",
    "IS_CAM_RENDERING": "IsCamRendering",
    "POINT_CAM_AT_ENTITY": "PointCamAtEntity",
    "SET_CAM_INHERIT_ROLL_VEHICLE": "SetCamInheritRollVehicle",
    "ATTACH_CAM_TO_PED_BONE": "AttachCamToPedBone",
    "GET_SPAWN_COORDS_FOR_VEHICLE_NODE": "GetSpawnCoordsForVehicleNode",
    "GET_VEHICLE_NODE_POSITION": "GetVehicleNodePosition",
    "GET_CLOSEST_ROAD": "GetClosestRoad",
    "GET_NTH_CLOSEST_VEHICLE_NODE": "GetNthClosestVehicleNode",
    "GET_NTH_CLOSEST_VEHICLE_NODE_FAVOUR_DIRECTION": "GetNthClosestVehicleNodeFavourDirection",
    "SET_CREATE_RANDOM_COPS_NOT_ON_SCENARIOS": "SetCreateRandomCopsNotOnScenarios",
    "SET_CREATE_RANDOM_COPS": "SetCreateRandomCops",
    "CLEAR_AMBIENT_ZONE_STATE": "ClearAmbientZoneState",
    "SET_AMBIENT_ZONE_STATE": "SetAmbientZoneState",
    "IS_AMBIENT_ZONE_ENABLED": "IsAmbientZoneEnabled",
    "STOP_FIRE_IN_RANGE": "StopFireInRange",
    "IS_ENTITY_ON_FIRE": "IsEntityOnFire",
    "START_ENTITY_FIRE": "StartEntityFire",
    "STOP_ENTITY_FIRE": "StopEntityFire",
    "ADD_FIRE": "AddFire",
    "STOP_FIRE": "StopFire",
    "REMOVE_ALL_FIRES": "RemoveAllFires",
    "GET_NUMBER_OF_FIRES_IN_RANGE": "GetNumberOfFiresInRange",
    "SET_FIRE_SPRAY_SIZE": "SetFireSpraySize",
    "GET_USER_INPUT": "GetUserInput",
    "DISPLAY_ONSCREEN_KEYBOARD": "DisplayOnscreenKeyboard",
    "UPDATE_ONSCREEN_KEYBOARD": "UpdateOnscreenKeyboard",
    "GET_ONSCREEN_KEYBOARD_RESULT": "GetOnscreenKeyboardResult",
    "CANCEL_ONSCREEN_KEYBOARD": "CancelOnscreenKeyboard",
    "IS_INTERACTION_MENU_OPEN": "IsInteractionMenuOpen",
    "SET_INTERACTION_MENU_VISIBLE": "SetInteractionMenuVisible",
    "SET_MINIMAP_IN_SPECTATOR_MODE": "SetMinimapInSpectatorMode",
    "SET_HUD_COLOUR": "SetHudColour",
    "GET_HUD_COLOUR": "GetHudColour",
    "LOCK_MINIMAP_ANGLE": "LockMinimapAngle",
    "UNLOCK_MINIMAP_ANGLE": "UnlockMinimapAngle",
    "RESET_MINIMAP_ANGLE": "ResetMinimapAngle",
    "GET_CLOCK_SECONDS": "GetClockSeconds",
    "ADVANCE_CLOCK_TIME_TO": "AdvanceClockTimeTo",
    "SET_CLOCK_DATE": "SetClockDate",
    "GET_POSIX_TIME": "GetPosixTime",
    "NETWORK_OVERRIDE_CLOCK_TIME": "NetworkOverrideClockTime",
    "CLEAR_TIMECYCLE_MODIFIERS": "ClearTimecycleModifiers",
    "PUSH_TIMECYCLE_MODIFIER": "PushTimecycleModifier",
    "POP_TIMECYCLE_MODIFIER": "PopTimecycleModifier",
    "SET_ULTRALIGHT_FOG_OVERRIDE": "SetUltralightFogOverride",
    "GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH": "GetNumberOfThreadsRunningTheScriptWithThisHash",

    # Second-pass missing natives
    "SET_VEHICLE_ENVEFF_SCALE": "SetVehicleEnveffScale",
    "CREATE_AMBIENT_PICKUP": "CreateAmbientPickup",
    "PLACE_OBJECT_ON_GROUND_PROPERLY": "PlaceObjectOnGroundProperly",
    "SET_CUSTOM_RADIO_TRACK_LIST": "SetCustomRadioTrackList",
    "GET_ENTITY_TYPE": "GetEntityType",
    "SET_VEHICLE_WINDOW_TINT": "SetVehicleWindowTint",
    "GET_PED_LAST_WEAPON_IMPACT_COORD": "GetPedLastWeaponImpactCoord",
    "SET_ENTITY_COMPLETELY_DISABLE_COLLISION": "SetEntityCompletelyDisableCollision",
    "SET_PED_SHOOTS_AT_COORD": "SetPedShootsAtCoord",
    "GET_WEAPONTYPE_GROUP": "GetWeapontypeGroup",
    "HIDE_HUD_AND_RADAR_THIS_FRAME": "HideHudAndRadarThisFrame",
    "STAT_GET_INT": "StatGetInt",
    "STAT_SET_INT": "StatSetInt",
    "STAT_GET_FLOAT": "StatGetFloat",
    "STAT_SET_FLOAT": "StatSetFloat",
    "STAT_GET_BOOL": "StatGetBool",
    "STAT_SET_BOOL": "StatSetBool",
    "GET_HUD_COMPONENT_POSITION": "GetHudComponentPosition",
    "GET_MOBILE_PHONE_POSITION": "GetMobilePhonePosition",
    "SET_ARTIFICIAL_LIGHTS_STATE": "SetArtificialLightsState",
    "TRIGGER_MUSIC_EVENT": "TriggerMusicEvent",
    "OVERRIDE_LODSCALE_THIS_FRAME": "OverrideLodscaleThisFrame",
    "SET_OBJECT_PHYSICS_PARAMS": "SetObjectPhysicsParams",
    "CLEAR_VEHICLE_CUSTOM_PRIMARY_COLOUR": "ClearVehicleCustomPrimaryColour",
    "CLEAR_VEHICLE_CUSTOM_SECONDARY_COLOUR": "ClearVehicleCustomSecondaryColour",
    "IS_CUTSCENE_PLAYING": "IsCutsceenePlaying",
    "IS_PED_ARMED": "IsPedArmed",
    "SET_PED_WEAPON_TINT_INDEX": "SetPedWeaponTintIndex",
    "CREATE_CAM_WITH_PARAMS": "CreateCamWithParams",
    "PLAY_END_CREDITS_MUSIC": "PlayEndCreditsMusic",
    "SET_CREDITS_ACTIVE": "SetCreditsActive",
    "SET_MOBILE_PHONE_RADIO_STATE": "SetMobilePhoneRadioState",
    "SET_USER_RADIO_CONTROL_ENABLED": "SetUserRadioControlEnabled",
    "SET_DISABLE_BREAKING": "SetDisableBreaking",
    "SET_ENTITY_NO_COLLISION_ENTITY": "SetEntityNoCollisionEntity",
    "IS_PED_MODEL": "IsPedModel",
    "GET_RANDOM_VEHICLE_IN_SPHERE": "GetRandomVehicleInSphere",
    "GET_RANDOM_PED_AT_COORD": "GetRandomPedAtCoord",
    "SET_PED_COMBAT_MOVEMENT": "SetPedCombatMovement",
    "SET_PED_COMBAT_RANGE": "SetPedCombatRange",
    "SET_PED_COMBAT_ABILITY": "SetPedCombatAbility",
    "SET_PED_TARGET_LOSS_RESPONSE": "SetPedTargetLossResponse",
    "SET_PED_SEES_SPOOKS": "SetPedSeesSpooks",
    "GET_PED_DRAWABLE_VARIATION": "GetPedDrawableVariation",
    "GET_PED_TEXTURE_VARIATION": "GetPedTextureVariation",
    "GET_PED_PALETTE_VARIATION": "GetPedPaletteVariation",
    "GET_NUMBER_OF_PED_DRAWABLE_VARIATIONS": "GetNumberOfPedDrawableVariations",
    "GET_NUMBER_OF_PED_TEXTURE_VARIATIONS": "GetNumberOfPedTextureVariations",
    "SET_PED_PROP_INDEX": "SetPedPropIndex",
    "GET_PED_PROP_INDEX": "GetPedPropIndex",
    "CLEAR_PED_PROP": "ClearPedProp",
    "CLEAR_ALL_PED_PROPS": "ClearAllPedProps",
    "HAS_PED_GOT_WEAPON": "HasPedGotWeapon",
    "IS_PED_CURRENT_WEAPON_SILENCED": "IsPedCurrentWeaponSilenced",
    "SET_PED_AMMO": "SetPedAmmo",
    "GET_AMMO_IN_CLIP": "GetAmmoInClip",
    "SET_AMMO_IN_CLIP": "SetAmmoInClip",
    "GET_MAX_AMMO": "GetMaxAmmo",
    "SET_PED_INFINITE_AMMO": "SetPedInfiniteAmmo",
    "FORCE_PED_TO_OPEN_PARACHUTE": "ForcePedToOpenParachute",
    "IS_PED_IN_PARACHUTE_FREE_FALL": "IsPedInParachuteFreefall",
    "SET_HELI_BLADES_FULL_SPEED": "SetHeliBladeFullSpeed",
    "SET_HELI_BLADES_SPEED": "SetHeliBladeSpeed",
    "SET_VEHICLE_KEEPS_ENGINED_ON_WHEN_ABANDONED": "SetVehicleKeepsEngineOnWhenAbandoned",
    "SET_VEHICLE_USES_LARGE_REAR_RAMP": "SetVehicleUsesLargeRearRamp",
    "SET_VEHICLE_TRACK_CENTER": "SetVehicleTrackCenter",
    "JITTER_ROAD_CAM_ON": "JitterRoadCamOn",
    "JITTER_ROAD_CAM_OFF": "JitterRoadCamOff",
    "SET_FOCUS_AREA": "SetFocusArea",
    "CLEAR_FOCUS": "ClearFocus",
    "SET_GAMEPLAY_CAM_AFFECT_VEHICLE_ROTATION": "SetGameplayCamAffectVehicleRotation",
    "LOCK_CAM_AHEAD_FOR_PED": "LockCamAheadForPed",
    "SET_CACHED_GRAVITY_LEVEL": "SetCachedGravityLevel",
    "RESET_GRAVITY_TO_STANDARD": "ResetGravityToStandard",
    "GRAVITY_CONTROLLER_ENABLE": "GravityControllerEnable",
    "GET_PHYS_GRAVITY_LEVEL": "GetPhysGravityLevel",
    "GET_VEHICLE_CLASS_FROM_NAME": "GetVehicleClassFromName",
    "EXPLODE_VEHICLE_IN_CUTSCENE": "ExplodeVehicleInCutscene",
    "CREATE_NM_MESSAGE": "CreateNmMessage",
    "GIVE_PED_NM_MESSAGE": "GivePedNmMessage",
    "GET_LAST_PED_IN_VEHICLE_SEAT": "GetLastPedInVehicleSeat",
    "IS_VEHICLE_A_CONVERTIBLE": "IsVehicleAConvertible",
    "RAISE_CONVERTIBLE_ROOF": "RaiseConvertibleRoof",
    "LOWER_CONVERTIBLE_ROOF": "LowerConvertibleRoof",
    "TRANSFORM_TO_SUBMARINE": "TransformToSubmarine",
    "TRANSFORM_TO_CAR": "TransformToCar",
    "SET_VEHICLE_UNDRIVEABLE": "SetVehicleUndriveable",
    "SET_VEHICLE_PROVIDES_COVER": "SetVehicleProvidesCover",
    "GET_RANDOM_VEHICLE": "GetRandomVehicle",
    "GET_RANDOM_PED_IN_SPHERE": "GetRandomPedInSphere",
    "GET_PED_NEARBY_PEDS": "GetPedNearbyPeds",
    "GET_PED_NEARBY_VEHICLES": "GetPedNearbyVehicles",
    "SET_WORLD_POSITION": "SetWorldPosition",
    "GET_WORLD_POSITION": "GetWorldPosition",
    "GET_ENTITY_LEVEL_DESIGN_COORDS": "GetEntityLevelDesignCoords",
    "SET_SLOW_MO_EFFECTS": "SetSlowMoEffects",
    "SET_SLOW_MOTION_EFFECTS": "SetSlowMotionEffects",
    "DRAW_LIGHT_WITH_RANGE": "DrawLightWithRange",
    "DRAW_LIGHT_WITH_RANGE_AND_SHADOW": "DrawLightWithRangeAndShadow",
    "DRAW_SPOT_LIGHT": "DrawSpotLight",
    "DRAW_SPOT_LIGHT_WITH_SHADOW": "DrawSpotLightWithShadow",
    "HAS_ENTITY_BEEN_DAMAGED_BY_ANY_PED": "HasEntityBeenDamagedByAnyPed",
    "HAS_ENTITY_BEEN_DAMAGED_BY_ANY_VEHICLE": "HasEntityBeenDamagedByAnyVehicle",
    "HAS_ENTITY_BEEN_DAMAGED_BY_ANY_OBJECT": "HasEntityBeenDamagedByAnyObject",
    "HAS_ENTITY_BEEN_DAMAGED_BY_ENTITY": "HasEntityBeenDamagedByEntity",
    "CLEAN_PED_BLOOD_DAMAGE": "CleanPedBloodDamage",
    "CLEAN_PED_BLOOD_DAMAGE_BY_ZONE": "CleanPedBloodDamageByZone",
    "SET_CREATE_RANDOM_COPS_ON_SCENARIOS": "SetCreateRandomCopsOnScenarios",
    "GET_ENTITY_SUBMERGED_LEVEL": "GetEntitySubmergedLevel",
    "IS_ENTITY_UPRIGHT": "IsEntityUpright",
    "IS_ENTITY_UPSIDEDOWN": "IsEntityUpsidedown",
    "IS_ENTITY_IN_AIR": "IsEntityInAir",
    "IS_ENTITY_IN_WATER": "IsEntityInWater",
    "IS_ENTITY_TOUCHING_MODEL": "IsEntityTouchingModel",
    "GET_ENTITY_QUATERNION": "GetEntityQuaternion",
    "SET_ENTITY_QUATERNION": "SetEntityQuaternion",
    "GET_ENTITY_PHYSICS_HEADING": "GetEntityPhysicsHeading",
    "PLACE_OBJECT_ON_GROUND_PROPERLY": "PlaceObjectOnGroundProperly",
    "SLIDE_OBJECT": "SlideObject",
    "SET_OBJECT_TARGETTABLE": "SetObjectTargettable",
    "SET_OBJECT_AS_STEALTHY_OBJECT": "SetObjectAsStealthyObject",
    "GET_CLOSEST_OBJECT_OF_TYPE": "GetClosestObjectOfType",
    "IS_OBJECT_WITHIN_BRAIN_ACTIVATION_RANGE": "IsObjectWithinBrainActivationRange",
    "HIDE_HUD_COMPONENT_THIS_FRAME": "HideHudComponentThisFrame",
    "SHOW_HUD_COMPONENT_THIS_FRAME": "ShowHudComponentThisFrame",
    "IS_HUD_COMPONENT_ACTIVE": "IsHudComponentActive",
    "FLASH_HUD_COMPONENT": "FlashHudComponent",
    "SET_RADIO_TO_STATION_INDEX": "SetRadioToStationIndex",
    "GET_PLAYER_RADIO_STATION_INDEX": "GetPlayerRadioStationIndex",
    "GET_RADIO_STATION_NAME": "GetRadioStationName",
    "GET_NUM_RADIO_STATIONS": "GetNumRadioStations",
    "UNLOCK_RADIO_STATION_TRACK_LIST": "UnlockRadioStationTrackList",
    "LOCK_RADIO_STATION_TRACK_LIST": "LockRadioStationTrackList",
    "SKIP_RADIO_FORWARD": "SkipRadioForward",
    "SET_RADIO_TRACK": "SetRadioTrack",
    "ENABLE_RADIO_STATION": "EnableRadioStation",
    "DISABLE_RADIO_STATION": "DisableRadioStation",
    "SET_FRONTEND_RADIO_ACTIVE": "SetFrontendRadioActive",
    "SHOULD_USE_METRIC_MEASUREMENTS": "ShouldUseMetricMeasurements",
    "IS_PAUSE_MENU_ACTIVE": "IsPauseMenuActive",
    "IS_FRONTEND_FADING": "IsFrontendFading",
    "SET_PAUSE_MENU_ACTIVE": "SetPauseMenuActive",
    "ACTIVATE_FRONTEND_MENU": "ActivateFrontendMenu",
    "RESTART_FRONTEND_MENU": "RestartFrontendMenu",
    "GET_CURRENT_FRONTEND_MENU_VERSION": "GetCurrentFrontendMenuVersion",
    "PAUSE_MENU_MOVE_CURSOR_UP_DOWN": "PauseMenuMoveCursorUpDown",
    "PAUSE_MENU_ACCEPT": "PauseMenuAccept",
    "PAUSE_MENU_BACK": "PauseMenuBack",

    # Third-pass missing natives
    "SET_VEHICLE_STEER_BIAS": "SetVehicleSteerBias",
    "SET_PED_RESET_FLAG": "SetPedResetFlag",
    "SET_EVERYONE_IGNORE_PLAYER": "SetEveryoneIgnorePlayer",
    "SET_PED_SEEING_RANGE": "SetPedSeeingRange",
    "PLAY_PAIN": "PlayPain",
    "GET_ENTITY_MAX_HEALTH": "GetEntityMaxHealth",
    "SET_ENTITY_MAX_HEALTH": "SetEntityMaxHealth",
    "IS_ENTITY_PLAYING_ANIM": "IsEntityPlayingAnim",
    "ARE_ANY_VEHICLE_SEATS_FREE": "AreAnyVehicleSeatsFree",
    "SET_PLAYER_WEAPON_DAMAGE_MODIFIER": "SetPlayerWeaponDamageModifier",
    "SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER": "SetPlayerHealthRechargeMultiplier",
    "SET_PED_RAGDOLL_ON_COLLISION": "SetPedRagdollOnCollision",
    "CLONE_PED_TO_TARGET": "ClonePedToTarget",
    "RELEASE_NAMED_SCRIPT_AUDIO_BANK": "ReleaseNamedScriptAudioBank",
    "IS_TRACKED_PED_VISIBLE": "IsTrackedPedVisible",
    "TASK_SMART_FLEE_COORD": "TaskSmartFleeCoord",
    "GET_BLIP_INFO_ID_ENTITY_INDEX": "GetBlipInfoIdEntityIndex",
    "SET_PED_IS_DRUNK": "SetPedIsDrunk",
    "GET_PED_PARACHUTE_STATE": "GetPedParachuteState",
    "ANIMPOSTFX_PLAY": "AnimpostfxPlay",
    "ANIMPOSTFX_STOP": "AnimpostfxStop",
    "IS_SCREEN_FADED_IN": "IsScreenFadedIn",
    "GET_TIME_SINCE_PLAYER_HIT_PED": "GetTimeSincePlayerHitPed",
    "IS_CONTROL_JUST_RELEASED": "IsControlJustReleased",
    "SET_RUN_SPRINT_MULTIPLIER_FOR_PLAYER": "SetRunSprintMultiplierForPlayer",
    "SET_FOLLOW_VEHICLE_CAM_ZOOM_LEVEL": "SetFollowVehicleCamZoomLevel",
    "SET_MOBILE_PHONE_POSITION": "SetMobilePhonePosition",
    "SET_TV_CHANNEL": "SetTvChannel",
    "ENABLE_MOVIE_SUBTITLES": "EnableMovieSubtitles",
    "SET_VEHICLE_CHEAT_POWER_INCREASE": "SetVehicleCheatPowerIncrease",
    "SET_VEHICLE_TYRE_FIXED": "SetVehicleTyreFixed",
    "APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS": "ApplyForceToEntityCenterOfMass",
    "SET_VEHICLE_TOW_TRUCK_ARM_POSITION": "SetVehicleTowTruckArmPosition",
    "SET_VEHICLE_SIREN": "SetVehicleSiren",
    "FORCE_PED_MOTION_STATE": "ForcePedMotionState",
    "GET_ENTITY_ATTACHED_TO": "GetEntityAttachedTo",
    "ATTACH_CAM_TO_ENTITY": "AttachCamToEntity",
    "TASK_HELI_CHASE": "TaskHeliChase",
    "TERMINATE_ALL_SCRIPTS_WITH_THIS_NAME": "TerminateAllScriptsWithThisName",
    "SET_SCRIPT_AS_NO_LONGER_NEEDED": "SetScriptAsNoLongerNeeded",
    "IS_PED_SWIMMING_UNDER_WATER": "IsPedSwimmingUnderWater",
    "ADD_PETROL_DECAL": "AddPetrolDecal",
    "ADD_AMMO_TO_PED": "AddAmmoToPed",
    "START_NEW_SCRIPT_WITH_ARGS": "StartNewScriptWithArgs",
    "IS_PICKUP_WEAPON_OBJECT_VALID": "IsPickupWeaponObjectValid",
    "SET_WEAPON_OBJECT_TINT_INDEX": "SetWeaponObjectTintIndex",
    "REFRESH_WAYPOINT": "RefreshWaypoint",
    "SET_RADIO_TO_STATION_NAME": "SetRadioToStationName",
    "SET_WEATHER_TYPE_OVERTIME_PERSIST": "SetWeatherTypeOvertimePersist",
    "SET_VEHICLE_WHEEL_TYPE": "SetVehicleWheelType",
    "SET_ENTITY_HAS_GRAVITY": "SetEntityHasGravity",
    "SET_PED_CAN_BE_TARGETTED_BY_PLAYER": "SetPedCanBeTargettedByPlayer",
    "TASK_STAND_STILL": "TaskStandStill",
    "SET_PED_AS_COP": "SetPedAsCop",
    "SET_DRIVE_TASK_DRIVING_STYLE": "SetDriveTaskDrivingStyle",
    "SET_EXPLOSIVE_MELEE_THIS_FRAME": "SetExplosiveMeleeThisFrame",
    "SET_EXPLOSIVE_AMMO_THIS_FRAME": "SetExplosiveAmmoThisFrame",
    "SET_PED_DROPS_WEAPON": "SetPedDropsWeapon",
    "GIVE_WEAPON_COMPONENT_TO_PED": "GiveWeaponComponentToPed",
    "SET_AI_MELEE_WEAPON_DAMAGE_MODIFIER": "SetAiMeleeWeaponDamageModifier",
    "SET_AI_WEAPON_DAMAGE_MODIFIER": "SetAiWeaponDamageModifier",
    "RESET_AI_MELEE_WEAPON_DAMAGE_MODIFIER": "ResetAiMeleeWeaponDamageModifier",
    "RESET_AI_WEAPON_DAMAGE_MODIFIER": "ResetAiWeaponDamageModifier",
    "START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD": "StartNetworkedParticleFxNonLoopedAtCoord",
    "IS_PED_RINGTONE_PLAYING": "IsPedRingtonePlaying",
    "PLAY_PED_RINGTONE": "PlayPedRingtone",
    "STOP_PED_RINGTONE": "StopPedRingtone",
    "SET_PARTICLE_FX_LOOPED_COLOUR": "SetParticleFxLoopedColour",
    "SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE": "SetPedCanBeKnockedOffVehicle",
    "BRING_VEHICLE_TO_HALT": "BringVehicleToHalt",
    "HAS_ENTITY_BEEN_DAMAGED_BY_WEAPON": "HasEntityBeenDamagedByWeapon",
    "DISABLE_PED_PAIN_AUDIO": "DisablePedPainAudio",
    "GET_MAX_RANGE_OF_CURRENT_PED_WEAPON": "GetMaxRangeOfCurrentPedWeapon",
    "REQUEST_PED_VISIBILITY_TRACKING": "RequestPedVisibilityTracking",
    "IS_PLAYER_CONTROL_ON": "IsPlayerControlOn",
    "DRAW_LINE": "DrawLine",
    "IS_BLIP_ON_MINIMAP": "IsBlipOnMinimap",
    "GET_BLIP_ALPHA": "GetBlipAlpha",
    "IS_VEHICLE_STUCK_TIMER_UP": "IsVehicleStuckTimerUp",
    "TASK_LEAVE_ANY_VEHICLE": "TaskLeaveAnyVehicle",
    "HAS_ENTITY_CLEAR_LOS_TO_ENTITY": "HasEntityClearLosToEntity",
    "TASK_SHOOT_AT_ENTITY": "TaskShootAtEntity",
    "PLAY_STREAM_FROM_PED": "PlayStreamFromPed",
    "START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE": "StartExpensiveSynchronousShapeTestLosProbe",
    "GET_SHAPE_TEST_RESULT": "GetShapeTestResult",
    "DRAW_BOX": "DrawBox",
    "IS_GAMEPLAY_CAM_SHAKING": "IsGameplayCamShaking",
    "REQUEST_CLIP_SET": "RequestClipSet",
    "SET_AUDIO_SPECIAL_EFFECT_MODE": "SetAudioSpecialEffectMode",
    "REMOVE_CLIP_SET": "RemoveClipSet",
    "GET_MISSION_FLAG": "GetMissionFlag",
    "GET_SOUND_ID": "GetSoundId",
    "START_AUDIO_SCENE": "StartAudioScene",
    "STOP_ANIM_TASK": "StopAnimTask",
    "STOP_AUDIO_SCENE": "StopAudioScene",
    "RELEASE_SOUND_ID": "ReleaseSoundId",
    "SET_CAM_AFFECTS_AIMING": "SetCamAffectsAiming",
    "END_SCALEFORM_MOVIE_METHOD_RETURN_VALUE": "EndScaleformMovieMethodReturnValue",
    "IS_SCALEFORM_MOVIE_METHOD_RETURN_VALUE_READY": "IsScaleformMovieMethodReturnValueReady",
    "ADD_ARMOUR_TO_PED": "AddArmourToPed",
    "SIMULATE_PLAYER_INPUT_GAIT": "SimulatePlayerInputGait",
    "SET_CAM_PARAMS": "SetCamParams",
    "SPECIAL_ABILITY_DEPLETE_METER": "SpecialAbilityDepleteMeter",
    "GET_ENTITY_PLAYER_IS_FREE_AIMING_AT": "GetEntityPlayerIsFreeAimingAt",
    "GET_NUMBER_OF_PED_PROP_DRAWABLE_VARIATIONS": "GetNumberOfPedPropDrawableVariations",
    "GET_NUMBER_OF_PED_PROP_TEXTURE_VARIATIONS": "GetNumberOfPedPropTextureVariations",
    "SET_SUPER_JUMP_THIS_FRAME": "SetSuperJumpThisFrame",
    "GET_FOLLOW_VEHICLE_CAM_ZOOM_LEVEL": "GetFollowVehicleCamZoomLevel",
    "GET_VEHICLE_COLOUR_COMBINATION": "GetVehicleColourCombination",
    "SET_VEHICLE_COLOUR_COMBINATION": "SetVehicleColourCombination",
    "GET_TIMECYCLE_TRANSITION_MODIFIER_INDEX": "GetTimecycleTransitionModifierIndex",
    "GET_TIMECYCLE_MODIFIER_INDEX": "GetTimecycleModifierIndex",
    "SET_TRANSITION_TIMECYCLE_MODIFIER": "SetTransitionTimecycleModifier",
    "GET_PROFILE_SETTING": "GetProfileSetting",
    "SET_TV_CHANNEL_PLAYLIST_AT_HOUR": "SetTvChannelPlaylistAtHour",
    "SET_TV_AUDIO_FRONTEND": "SetTvAudioFrontend",
    "SET_TV_VOLUME": "SetTvVolume",
    "ATTACH_TV_AUDIO_TO_ENTITY": "AttachTvAudioToEntity",
    "SET_SCRIPT_GFX_DRAW_ORDER": "SetScriptGfxDrawOrder",
    "SET_SCRIPT_GFX_DRAW_BEHIND_PAUSEMENU": "SetScriptGfxDrawBehindPausemenu",
    "DRAW_TV_CHANNEL": "DrawTvChannel",
    "SET_TV_CHANNEL_PLAYLIST": "SetTvChannelPlaylist",
    "CAN_SET_EXIT_STATE_FOR_CAMERA": "CanSetExitStateForCamera",
    "STOP_CUTSCENE_CAM_SHAKING": "StopCutsceneCamShaking",
    "IS_PED_DIVING": "IsPedDiving",
    "IS_PED_JUMPING_OUT_OF_VEHICLE": "IsPedJumpingOutOfVehicle",
    "IS_PED_GETTING_UP": "IsPedGettingUp",
    "SET_HORN_PERMANENTLY_ON": "SetHornPermanentlyOn",
    "SET_VEHICLE_DAMAGE": "SetVehicleDamage",
    "TASK_VEHICLE_MISSION_PED_TARGET": "TaskVehicleMissionPedTarget",
    "IS_HORN_ACTIVE": "IsHornActive",
    "SET_AMBIENT_VEHICLE_RANGE_MULTIPLIER_THIS_FRAME": "SetAmbientVehicleRangeMultiplierThisFrame",
    "SET_RANDOM_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME": "SetRandomVehicleDensityMultiplierThisFrame",
    "GET_VEHICLE_WINDOW_TINT": "GetVehicleWindowTint",
    "IS_THIS_MODEL_A_BICYCLE": "IsThisModelABicycle",
    "HAS_ANIM_DICT_LOADED": "HasAnimDictLoaded",
}

# Pool functions
POOL_MAP = {
    "GetAllPeds": "GetGamePool('CPed')",
    "GetAllVehs": "GetGamePool('CVehicle')",
    "GetAllVehicles": "GetGamePool('CVehicle')",
    "GetAllProps": "GetGamePool('CObject')",
    "GetAllObjects": "GetGamePool('CObject')",
    "GetAllPickups": "GetGamePool('CPickup')",
}

# Types to strip
CPP_TYPES = r'\b(static\s+)?(const\s+)?(DWORD64|DWORD|UINT|INT|int|float|bool|double|Ped|Vehicle|Entity|Object|Hash|Vector3|std::vector<\w+>|auto|void|char\*|const\s+char\*|std::string)\b\s*'

# ─── Parser ─────────────────────────────────────────────────────────────────

def extract_block(src, start_idx):
    """Extract balanced { } block starting at start_idx (which must be '{')."""
    depth = 0
    i = start_idx
    start = -1
    while i < len(src):
        if src[i] == '{':
            if depth == 0:
                start = i
            depth += 1
        elif src[i] == '}':
            depth -= 1
            if depth == 0:
                return src[start:i+1], i+1
        i += 1
    return None, len(src)


def find_function(src, name):
    """Find 'static void NAME()' and return its body string."""
    pattern = re.compile(r'static\s+void\s+' + re.escape(name) + r'\s*\(\s*\)\s*\{', re.DOTALL)
    m = pattern.search(src)
    if not m:
        return None
    # Back up to the opening brace
    body_start = src.index('{', m.start())
    body, _ = extract_block(src, body_start)
    if body:
        return body[1:-1]  # strip outer braces
    return None


def parse_register_effects(src):
    """Extract every REGISTER_EFFECT macro in a source file."""
    effects = []
    for m in re.finditer(
        r'REGISTER_EFFECT\s*\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*,\s*\{',
        src, re.DOTALL
    ):
        on_start_name = m.group(1)
        on_stop_name = m.group(2)
        on_tick_name = m.group(3)
        brace_start = m.end() - 1
        metadata_block, _ = extract_block(src, brace_start)
        if not metadata_block:
            continue
        metadata_raw = metadata_block[1:-1]

        def get_field(field):
            fm = re.search(r'\.' + field + r'\s*=\s*"([^"]+)"', metadata_raw)
            return fm.group(1) if fm else None

        def get_bool_field(field):
            fm = re.search(r'\.' + field + r'\s*=\s*(true|false)', metadata_raw)
            return fm.group(1) == 'true' if fm else False

        effects.append({
            'on_start': None if on_start_name == 'nullptr' else on_start_name,
            'on_stop': None if on_stop_name == 'nullptr' else on_stop_name,
            'on_tick': None if on_tick_name == 'nullptr' else on_tick_name,
            'name': get_field('Name'),
            'id': get_field('Id'),
            'is_timed': get_bool_field('IsTimed'),
            'is_short': get_bool_field('IsShortDuration'),
        })
    return effects


def parse_chaos_vars(src):
    """Extract CHAOS_VAR declarations: type name = value (including array braced inits)."""
    vars_ = []
    # Array form: CHAOS_VAR type name[N] { ... }  or  { ... };
    for m in re.finditer(
        r'CHAOS_VAR\s+(?:static\s+)?(?:const\s+)?(\w[\w:<>*\s]+?)\s+(\w+)\s*\[\d+\]\s*\{([^}]+)\}',
        src, re.DOTALL
    ):
        vname  = m.group(2).strip()
        items_raw = m.group(3)
        # Turn C-string array into Lua table of strings
        items = re.findall(r'"([^"]*)"', items_raw)
        val_lua = '{' + ', '.join(f'"{s}"' for s in items) + '}'
        vars_.append(('array', vname, val_lua))
    # Scalar form: CHAOS_VAR type name = value;  or  CHAOS_VAR type name;
    for m in re.finditer(r'CHAOS_VAR\s+(?:static\s+)?(?:const\s+)?(\w[\w:<>*\s]+?)\s+(\w+)\s*(?:=\s*([^;{]+))?;', src):
        vname  = m.group(2).strip()
        # Skip if already handled as array
        if any(v[1] == vname for v in vars_):
            continue
        type_  = m.group(1).strip()
        val    = m.group(3).strip() if m.group(3) else None
        vars_.append((type_, vname, val))
    return vars_


# ─── Code translator ────────────────────────────────────────────────────────

def translate_hash_literals(code):
    """Convert "hash_string"_hash to GetHashKey("hash_string")"""
    return re.sub(r'"([^"]+)"_hash', r'GetHashKey("\1")', code)


def translate_natives(code):
    """Replace C++ native names with Lua equivalents."""
    # Namespace-qualified native calls first so CAM::CREATE_CAM does not become CAM::CreateCam.
    for cpp, lua in NATIVE_MAP.items():
        code = re.sub(r'\b\w+::' + re.escape(cpp) + r'\s*\(', lua + '(', code)

    # Pool functions
    for cpp, lua in POOL_MAP.items():
        code = re.sub(r'\b' + re.escape(cpp) + r'\s*\(\s*\)', lua, code)

    # Screaming snake natives (whole-word replacement)
    for cpp, lua in NATIVE_MAP.items():
        code = re.sub(r'\b' + re.escape(cpp) + r'\s*\(', lua + '(', code)

    # Common value constructors used across effects.
    code = re.sub(r'\bVector3::Init\s*\(', 'vector3(', code)

    return code


def find_unresolved_cpp_construct(client_func):
    """Return a short reason when generated Lua still contains unsupported C++ syntax."""
    checks = [
        (r'\b\w+::\w+', 'unresolved namespace call'),
        (r'\b(?:ComponentExists|GetComponent)\s*<', 'component API not available'),
        (r'\bstd::', 'std API not translated'),
        (r'\b(?:switch|case)\b', 'switch statement not translated'),
        (r'->', 'pointer access not translated'),
        (r'\{\s*\.', 'designated initializer not translated'),
        (r'\b(?:if|elseif|while)\s*\([^\n)]*=\s*[^=][^\n)]*\)\s*(?:then|do)', 'assignment inside condition not translated'),
    ]
    for pattern, reason in checks:
        if re.search(pattern, client_func):
            return reason
    return None


def find_luac():
    for candidate in LUAC_CANDIDATES:
        if candidate.exists():
            return candidate
    return None


def lua_parses(code):
    luac = find_luac()
    if not luac:
        return True, None
    tmp_path = None
    try:
        with tempfile.NamedTemporaryFile('w', suffix='.lua', delete=False, encoding='utf-8') as handle:
            handle.write(code + '\n')
            tmp_path = handle.name
        proc = subprocess.run([str(luac), '-p', tmp_path], capture_output=True, text=True)
        if proc.returncode == 0:
            return True, None
        return False, (proc.stderr or proc.stdout).strip()
    finally:
        if tmp_path and os.path.exists(tmp_path):
            os.unlink(tmp_path)


def build_fallback_function(effect_id, effect_name, lua_id, cpp_path, reason):
    """Generate a parse-safe approximation when direct translation fails."""
    reason = reason.replace('"', '\\"')
    effect_name = effect_name.replace('\\', '\\\\').replace('"', '\\"')
    header = [
        f'-- FALLBACK-GENERATED from {cpp_path.name}: {reason}',
        f'function FX_{lua_id}(alive)',
        f'    ChaosTranspilerFallback("{effect_id}", "{effect_name}", alive)',
        'end',
    ]
    return '\n'.join(header)


FALLBACK_HELPERS = r'''local _chaosTranspilerFallbackNotice = {}

local function ChaosFallbackScreen(effectId)
    local modifiers = {
        screen_arc = 'underwater',
        screen_colorfulworld = 'BeastLaunch02',
        screen_dimwarp = 'Barry1_Stoned',
        screen_fckautorotate = 'spectator5',
        screen_foldedscreen = 'NG_filmic14',
        screen_fourthdimension = 'Spectator6',
        screen_hueshift = 'ArenaEMP',
        screen_invertedcolors = 'phone_cam8',
        screen_localcoop = 'ArenaWheelPurple01',
        screen_mirrored = 'CAMERA_secuirity',
        screen_rgbland = 'underwater_deep',
        screen_screenfreakout = 'drug_drive_blend01',
        screen_screenpotato = 'MP_Powerplay_blend',
        screen_shatteredscreen = 'damage',
        screen_swappedcolors = 'NG_filmic20',
        screen_textureless = 'yell_tunnel_nodirect',
        screen_tnpanel = 'Tunnel',
        screen_warpedcam = 'Drunk',
        misc_dvdscreensaver = 'scanline_cam_cheap',
        misc_flip_ui = 'CAMERA_BW',
    }
    local modifier = modifiers[effectId] or 'spectator5'
    SetTimecycleModifier(modifier)
    SetTimecycleModifierStrength(1.0)
end

local function ChaosFallbackMeta(effectId, active)
    local payload = nil
    if effectId == 'meta_spawn_multiple_effects' then
        payload = { key = 'additionalEffects', value = active and 2 or 0 }
    elseif effectId == 'meta_effect_duration_0_5x' then
        payload = { key = 'durationModifier', value = active and 0.5 or 1.0 }
    elseif effectId == 'meta_effect_duration_2x' then
        payload = { key = 'durationModifier', value = active and 2.0 or 1.0 }
    elseif effectId == 'meta_timerspeed_0_5x' then
        payload = { key = 'timerModifier', value = active and 0.5 or 1.0 }
    elseif effectId == 'meta_timerspeed_2x' then
        payload = { key = 'timerModifier', value = active and 2.0 or 1.0 }
    elseif effectId == 'meta_timerspeed_5x' then
        payload = { key = 'timerModifier', value = active and 5.0 or 1.0 }
    elseif effectId == 'meta_nochaos' then
        payload = { key = 'disableChaos', value = active }
    elseif effectId == 'meta_hide_chaos_ui' then
        payload = { key = 'hideChaosUI', value = active }
    elseif effectId == 'meta_votingmode_majority' then
        payload = { key = 'votingMode', value = active and 'majority' or 'none' }
    elseif effectId == 'meta_votingmode_antimajority' then
        payload = { key = 'votingMode', value = active and 'antimajority' or 'none' }
    end
    if payload then
        TriggerServerEvent('cc:meta_set', payload.key, payload.value)
    end
end

local function ChaosForEachVehicle(fn)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) then
            fn(veh)
        end
    end
end

local function ChaosForEachPed(fn)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) then
            fn(ped)
        end
    end
end

local function ChaosRunTimed(alive, onTick, onStop, waitMs)
    waitMs = waitMs or 0
    if alive then
        while alive() do
            onTick()
            Citizen.Wait(waitMs)
        end
    else
        onTick()
    end
    if onStop then
        onStop()
    end
end

local RANDOM_PED_MODELS = {
    "a_m_m_acult_01", "a_m_m_afriamer_01", "a_m_m_beach_02", "a_m_m_busicas_01",
    "a_m_m_farmer_01", "a_m_m_fatlatin_01", "a_m_m_hillbilly_02", "a_m_m_indian_01",
    "a_m_m_og_boss_01", "a_m_m_paparazzi_01", "a_m_m_rurmeth_01", "a_m_m_salton_04",
    "a_m_m_skater_01", "a_m_m_socenlat_01", "a_m_m_tourist_01", "a_m_o_acult_02",
    "a_m_o_beach_01", "a_m_o_salton_01", "a_m_y_acult_02", "a_m_y_beach_02",
    "a_m_y_beachvesp_02", "a_m_y_business_03", "a_m_y_cyclist_01", "a_m_y_eastsa_02",
    "a_m_y_genstreet_01", "a_m_y_genstreet_02", "a_m_y_hipster_01", "a_m_y_jetski_01",
    "a_m_y_mexthug_01", "a_m_y_motox_02", "a_m_y_musclbeac_01", "a_m_y_rurmeth_01",
    "a_m_y_salton_01", "a_m_y_skater_02", "a_m_y_stlat_01", "a_m_y_stwhi_02",
    "a_m_y_sunbathe_01", "a_m_y_surfer_01", "a_m_y_vindouche_01", "a_m_y_yoga_01",
    "a_f_m_beach_01", "a_f_m_fatcult_01", "a_f_m_salton_01", "a_f_m_skidrow_01",
    "a_f_m_tourist_01", "a_f_o_genstreet_01", "a_f_o_soucent_01", "a_f_y_beach_01",
    "a_f_y_hipster_01", "a_f_y_juggalo_01", "a_f_y_runner_01", "a_f_y_vinewood_04",
    "a_f_y_yoga_01", "s_m_m_autoshop_01", "s_m_m_bouncer_01", "s_m_m_chemsec_01",
    "s_m_m_ciasec_01", "s_m_m_dockwork_01", "s_m_m_highsec_01", "s_m_m_lifeinvad_01",
    "s_m_m_movprem_01", "s_m_m_pilot_02", "s_m_m_security_01", "s_m_m_ups_02",
    "s_m_y_airworker", "s_m_y_blackops_01", "s_m_y_construct_01", "s_m_y_fireman_01",
    "s_m_y_marine_01", "s_m_y_pilot_01", "s_m_y_prisoner_01",
}

local function _ChaosCreateRandomPed(x, y, z, heading)
    local modelName = RANDOM_PED_MODELS[math.random(#RANDOM_PED_MODELS)]
    local model = GetHashKey(modelName)
    RequestModel(model)
    local t = 20
    while not HasModelLoaded(model) and t > 0 do
        Citizen.Wait(50)
        t = t - 1
    end
    local ped = CreatePed(26, model, x, y, z, heading, true, false)
    SetModelAsNoLongerNeeded(model)
    return ped
end

local function _ChaosCreateHostilePed(model, weapon)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed, false)
    local ped = CreatePed(26, model, pos.x, pos.y, pos.z, GetEntityHeading(playerPed), true, false)
    SetPedAsEnemy(ped, true)
    GiveWeaponToPed(ped, weapon, 9999, true, true)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    TaskCombatPed(ped, playerPed, 0, 16)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
    return ped
end

function ChaosTranspilerFallback(effectId, effectName, alive)
    if not _chaosTranspilerFallbackNotice[effectId] then
        _chaosTranspilerFallbackNotice[effectId] = true
        print(('[CC] Fallback transpiler approximation active for %s (%s)'):format(effectName, effectId))
    end

    if effectId:find('^meta_') then
        ChaosFallbackMeta(effectId, true)
        if alive then
            while alive() do
                Citizen.Wait(250)
            end
        end
        ChaosFallbackMeta(effectId, false)
        return
    end

    if effectId:find('^screen_') or effectId == 'misc_flip_ui' or effectId == 'misc_dvdscreensaver' then
        ChaosFallbackScreen(effectId)
        if alive then
            while alive() do
                Citizen.Wait(250)
            end
        else
            Citizen.Wait(2500)
        end
        ClearTimecycleModifier()
        return
    end

    if effectId:find('pitch') or effectId:find('muffled') then
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.25)
        if alive then
            while alive() do
                SetGameplayCamShakeAmplitude(0.25)
                Citizen.Wait(250)
            end
            StopGameplayCamShaking(true)
        end
        return
    end

    if effectId == 'player_allweps' then
        local ped = PlayerPedId()
        local weapons = {
            GetHashKey("WEAPON_PISTOL"), GetHashKey("WEAPON_SMG"), GetHashKey("WEAPON_ASSAULTRIFLE"), GetHashKey("WEAPON_PUMPSHOTGUN"),
            GetHashKey("WEAPON_SNIPERRIFLE"), GetHashKey("WEAPON_RPG"), GetHashKey("WEAPON_GRENADE"), GetHashKey("WEAPON_MOLOTOV"),
        }
        for _, weapon in ipairs(weapons) do
            GiveWeaponToPed(ped, weapon, 999, false, false)
        end
        return
    end

    if effectId:find('5stars') or effectId:find('wanted_5') then
        SetPlayerWantedLevel(PlayerId(), 5, false)
        SetPlayerWantedLevelNow(PlayerId(), false)
        return
    end

    if effectId:find('3stars') or effectId:find('wanted_3') then
        SetPlayerWantedLevel(PlayerId(), 3, false)
        SetPlayerWantedLevelNow(PlayerId(), false)
        return
    end

    if effectId:find('clear_wanted') or effectId:find('never_wanted') then
        ClearPlayerWantedLevel(PlayerId())
        return
    end

    if effectId:find('superrun') then
        ChaosRunTimed(alive, function()
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
            SetSuperJumpThisFrame(PlayerId())
        end, function()
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        end, 0)
        return
    end

    if effectId:find('ragdollondmg') then
        ChaosRunTimed(alive, function()
            local playerPed = PlayerPedId()
            if HasEntityBeenDamagedByAnyPed(playerPed) or HasEntityBeenDamagedByAnyVehicle(playerPed) then
                ClearEntityLastDamageEntity(playerPed)
                SetPedToRagdoll(playerPed, 750, 750, 0, true, true, false)
            end
        end, nil, 50)
        return
    end

    if effectId:find('vehs_honk') or effectId:find('alarmloop') or effectId:find('lockdoors') or effectId:find('nogravity') or effectId:find('ghost') or effectId:find('invincible') or effectId:find('slippery') then
        ChaosRunTimed(alive, function()
            ChaosForEachVehicle(function(veh)
                if effectId:find('vehs_honk') then
                    SetHornPermanentlyOn(veh)
                end
                if effectId:find('alarmloop') then
                    SetVehicleAlarm(veh, true)
                    StartVehicleAlarm(veh)
                end
                if effectId:find('lockdoors') then
                    SetVehicleDoorsLocked(veh, 2)
                end
                if effectId:find('nogravity') then
                    SetVehicleGravity(veh, false)
                end
                if effectId:find('ghost') then
                    SetEntityAlpha(veh, 80, false)
                end
                if effectId:find('invincible') then
                    SetEntityInvincible(veh, true)
                end
                if effectId:find('slippery') then
                    SetVehicleReduceGrip(veh, true)
                end
            end)
        end, function()
            ChaosForEachVehicle(function(veh)
                SetVehicleAlarm(veh, false)
                SetVehicleDoorsLocked(veh, 1)
                SetVehicleGravity(veh, true)
                ResetEntityAlpha(veh)
                SetEntityInvincible(veh, false)
                SetVehicleReduceGrip(veh, false)
            end)
        end, 100)
        return
    end

    if effectId:find('poptires') then
        ChaosRunTimed(alive, function()
            ChaosForEachVehicle(function(veh)
                for i = 0, 7 do
                    SetVehicleTyreBurst(veh, i, true, 1000.0)
                end
            end)
        end, function()
            ChaosForEachVehicle(function(veh)
                for i = 0, 7 do
                    SetVehicleTyreFixed(veh, i)
                end
            end)
        end, 400)
        return
    end

    if effectId:find('fullaccel') then
        ChaosRunTimed(alive, function()
            ChaosForEachVehicle(function(veh)
                SetVehicleForwardSpeed(veh, GetVehicleModelEstimatedMaxSpeed(GetEntityModel(veh)) * 1.5)
            end)
        end, nil, 250)
        return
    end

    if effectId:find('jumpy') or effectId:find('bouncy') then
        ChaosRunTimed(alive, function()
            ChaosForEachVehicle(function(veh)
                if math.random() < 0.15 and not IsEntityInAir(veh) then
                    ApplyForceToEntity(veh, 1, 0.0, 0.0, effectId:find('bouncy') and 20.0 or 10.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                end
            end)
        end, nil, 100)
        return
    end

    if effectId:find('killengine') then
        ChaosForEachVehicle(function(veh)
            SetVehicleEngineHealth(veh, 0.0)
        end)
        return
    end

    if effectId:find('earthquake') then
        ChaosRunTimed(alive, function()
            ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 0.35)
            ChaosForEachVehicle(function(veh)
                if math.random() < 0.05 then
                    ApplyForceToEntity(veh, 1, 0.0, 0.0, 8.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                end
            end)
        end, function()
            StopGameplayCamShaking(true)
        end, 150)
        return
    end

    if effectId:find('fireworks') then
        ChaosRunTimed(alive, function()
            local pos = GetEntityCoords(PlayerPedId(), false)
            AddExplosion(pos.x + math.random(-20, 20), pos.y + math.random(-20, 20), pos.z + math.random(15, 30), 38, 0.0, false, false, 0.0, false)
        end, nil, 750)
        return
    end

    if effectId:find('poor') then
        SetPedMoney(PlayerPedId(), 0)
        return
    end

    if alive then
        while alive() do
            Citizen.Wait(250)
        end
    end
end
'''


def extract_parens(code, start):
    """Extract balanced (...) starting at start (must be '('). Returns (content, end_idx)."""
    depth = 0
    i = start
    while i < len(code):
        if code[i] == '(':
            depth += 1
        elif code[i] == ')':
            depth -= 1
            if depth == 0:
                return code[start+1:i], i+1
        i += 1
    return code[start+1:], len(code)


def translate_condition(cond):
    """Translate C++ condition to Lua."""
    cond = cond.strip()
    # != -> ~=
    cond = re.sub(r'!=', '~=', cond)
    # && -> and, || -> or
    cond = cond.replace('&&', ' and ').replace('||', ' or ')
    # !expr -> not expr (careful not to hit !=)
    cond = re.sub(r'(?<![=<>~!])!\s*', 'not ', cond)
    return cond


def translate_ternary(code):
    """Convert ternaries: COND ? A : B -> (COND and A or B)  (best-effort, single-line)."""
    def replace_ternary(m):
        lhs = m.group(1).strip()
        a = m.group(2).strip()
        b = m.group(3).strip()
        # Strip trailing C++ negation on b
        b = re.sub(r'^!', 'not ', b)
        # If LHS contains '=', split into assignment and condition
        # e.g. "Hash x = cond" or "local x = cond" -> keep "local x = " and make cond the ternary condition
        assign_m = re.match(r'^((?:local\s+)?\w+\s*=\s*)(.+)$', lhs)
        if assign_m:
            prefix = assign_m.group(1)
            cond = translate_condition(assign_m.group(2).strip())
            return f'{prefix}({cond} and {a} or {b})'
        else:
            cond = translate_condition(lhs)
            return f'({cond} and {a} or {b})'

    # Match: EXPR ? EXPR_A : EXPR_B  on a single line
    # Allow function calls, stop before trailing ) , ; \n
    code = re.sub(
        r'([^?\n]+?)\s*\?\s*([^:\n]+?)\s*:\s*([^,;\n\)]+?)(\s*[,;\n\)])',
        lambda m: replace_ternary(re.match(
            r'([^?\n]+?)\s*\?\s*([^:\n]+?)\s*:\s*([^,;\n\)]+)',
            m.group(0)
        )) + m.group(4) if re.match(r'([^?\n]+?)\s*\?\s*([^:\n]+?)\s*:\s*([^,;\n\)]+)', m.group(0)) else m.group(0),
        code
    )
    return code


def add_missing_braces(code):
    """Add { } around brace-less single-statement if/for/while bodies."""
    lines = code.split('\n')
    result = []
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        # Check if this is a block opener without a trailing {
        is_opener = (
            (stripped.startswith('if ') or stripped.startswith('if(')) and
            not stripped.endswith('{') and not stripped.endswith('\\') and
            not stripped.endswith('}')
        ) or (
            (stripped.startswith('for ') or stripped.startswith('for(')) and
            not stripped.endswith('{') and ')' in stripped and not stripped.endswith('\\')
        ) or (
            stripped.startswith('while (') and not stripped.endswith('{') and
            not stripped == 'while (true)'
        )
        if is_opener and i + 1 < len(lines):
            next_stripped = lines[i+1].strip()
            # If next line isn't a block itself, wrap it
            if next_stripped and not next_stripped.startswith('{'):
                result.append(line)
                result.append(lines[i].split(stripped)[0] + '{')
                result.append(lines[i+1])
                result.append(lines[i].split(stripped)[0] + '}')
                i += 2
                continue
        result.append(line)
        i += 1
    return '\n'.join(result)


def _fix_continue(code):
    """Replace `continue` with goto/label pairs inside for/while loops."""
    lines = code.split('\n')
    new_lines = []
    # Stack entries: ('loop', new_lines_idx_after_opener) or ('block', ...)
    block_stack = []
    label_before = {}  # maps new_lines index -> indent string

    for line in lines:
        s = line.strip()
        indent_str = line[:len(line) - len(line.lstrip())]

        if s == 'continue':
            # Find innermost loop on stack
            for kind, idx in reversed(block_stack):
                if kind == 'loop':
                    label_before[idx] = indent_str
                    break
            new_lines.append(indent_str + 'goto _continue_')
        else:
            cur_idx = len(new_lines)
            new_lines.append(line)
            if (s.startswith('for ') and s.endswith(' do')) or (s.startswith('while ') and s.endswith(' do')):
                block_stack.append(('loop', cur_idx + 1))
            elif s.endswith(' then') or s == 'do' or (s.startswith('function ') and s.endswith(')')) or s == 'else':
                block_stack.append(('block', cur_idx + 1))
            elif s == 'end' or s.startswith('end ') or s.startswith('end--'):
                if block_stack:
                    kind, start_idx = block_stack.pop()
                    if kind == 'loop' and start_idx in label_before:
                        new_lines.insert(len(new_lines) - 1, label_before[start_idx] + '::_continue_::')
                        del label_before[start_idx]
            elif s.startswith('elseif ') and s.endswith(' then'):
                if block_stack:
                    block_stack.pop()
                block_stack.append(('block', cur_idx + 1))

    return '\n'.join(new_lines)


def translate_cpp_body(code, defines=None):
    """Translate a C++ function body to approximate Lua."""
    defines = defines or {}

    # Remove comments
    code = re.sub(r'//[^\n]*', '', code)
    code = re.sub(r'/\*.*?\*/', '', code, flags=re.DOTALL)

    # Substitute #define constants
    for name, val in defines.items():
        code = re.sub(r'\b' + re.escape(name) + r'\b', val, code)

    # Hash literals
    code = translate_hash_literals(code)

    # Pre-strip C++ type declarations so ternary pass doesn't eat "Type var = cond ? a : b"
    # This turns "Hash x = ..." into "local x = ..." BEFORE ternary runs
    _EARLY_TYPE_PAT = r'(?:static\s+)?(?:constexpr\s+)?(?:const\s+)?(?:unsigned\s+)?(?:DWORD64|DWORD|UINT|INT|int|float|bool|double|Ped|Vehicle|Entity|Object|Hash|Vector3|ChaosVector2|ChaosVector3|Any|auto|std::string|size_t|uint32_t|int64_t|UINT64)'
    # Inline C-style array declarations: static const int boneIds[] = { ... }
    code = re.sub(r'(?m)^(\s*)' + _EARLY_TYPE_PAT + r'\s+(\w+)\s*\[\s*\d*\s*\]\s*=\s*', r'\1local \2 = ', code)
    code = re.sub(r'(?m)^(\s*)' + _EARLY_TYPE_PAT + r'\s*[&*]?\s*(\w+)\s*=', r'\1local \2 =', code)
    code = re.sub(r'(?m)^(\s*)' + _EARLY_TYPE_PAT + r'\s*[&*]?\s*(\w+)\s*;', r'\1local \2', code)

    # Ternary operators (before native translation to avoid confusion)
    code = translate_ternary(code)
    # Fix ternary wrapping variable declarations: (local x = ...) -> local x = ...
    code = re.sub(r'(?m)^\s*\(local (\w+) = (.+)\)\s*$', lambda m: m.group(0).split('(')[0] + f'local {m.group(1)} = {m.group(2)}', code)
    code = re.sub(r'\(local (\w+) = ([^)]+)\)', r'local \1 = \2', code)

    # Range-based for BEFORE native translation so GetAllPeds() is still simple
    # Use balanced extraction to get the full for(...) content
    def replace_range_for_all(code_str):
        result = []
        i = 0
        while i < len(code_str):
            m = re.search(r'\bfor\s*\(', code_str[i:])
            if not m:
                result.append(code_str[i:])
                break
            result.append(code_str[i:i+m.start()])
            paren_start = i + m.end() - 1
            inner, end = extract_parens(code_str, paren_start)
            # Check if it's a range-for (has colon but not semicolons pattern)
            # Handles: const Type &var : col  |  Type *var : col  |  auto var : col
            colon_m = re.match(
                r'\s*(?:const\s+)?(?:auto\s*[&*]?|\w+(?:\s*[*]\s*|\s+[&*]?\s*))(\w+)\s*:\s*(.+)',
                inner, re.DOTALL
            )
            semi_m = re.match(r'.*?;.*?;', inner, re.DOTALL)
            # Iterator for: for (auto it = x.begin(); it != x.end(); ...)
            # Also handles semi-stripped version: for (auto it = x.begin() it != x.end() ...)
            iter_m = re.match(
                r'\s*(?:auto|[\w:<>, ]+::iterator)\s+(\w+)\s*=\s*(\w+)\.(?:begin|cbegin)\s*\(\s*\)',
                inner
            )
            iter_bare_m = re.match(
                r'\s*(?:auto|[\w:<>*\s]+)?\s*(\w+)\s*=\s*(\w+)\.(?:begin|cbegin)\s*\(\s*\)',
                inner
            )
            # std::map iterator — use pairs() instead of ipairs()
            map_iter_m = re.match(
                r'\s*(?:auto|[\w:<>, ]+::iterator)\s+(\w+)\s*=\s*(\w+)\.(?:begin|cbegin)\s*\(\s*\).*?;.*',
                inner
            )
            if map_iter_m:
                it_var = map_iter_m.group(1)
                container = map_iter_m.group(2)
                result.append(f'for _k, _v in pairs({container}) do')
            elif iter_m:
                it_var = iter_m.group(1)
                container = iter_m.group(2)
                result.append(f'for _, {it_var} in ipairs({container}) do')
            elif iter_bare_m:
                it_var = iter_bare_m.group(1)
                container = iter_bare_m.group(2)
                result.append(f'for _, {it_var} in ipairs({container}) do')
            elif colon_m and not semi_m:
                var = colon_m.group(1)
                col = colon_m.group(2).strip()
                # Strip trailing braces/extra from collection
                col = re.sub(r'\s*\{[^}]*\}\s*$', '', col).strip()
                # Translate pool functions in collection now (before full native pass)
                for cpp_pool, lua_pool in POOL_MAP.items():
                    col = re.sub(r'\b' + re.escape(cpp_pool) + r'\s*\(\s*\)', lua_pool, col)
                result.append(f'for _, {var} in ipairs({col}) do')
            else:
                # Standard for or unknown — put it back
                result.append(f'for ({inner})')
            i = end
        return ''.join(result)
    code = replace_range_for_all(code)

    # std:: C++ stdlib translations (before native translation)
    # std::max/min -> math.max/math.min
    code = re.sub(r'\bstd::max\b', 'math.max', code)
    code = re.sub(r'\bstd::min\b', 'math.min', code)
    code = re.sub(r'\bstd::abs\b', 'math.abs', code)
    code = re.sub(r'\bstd::floor\b', 'math.floor', code)
    code = re.sub(r'\bstd::ceil\b', 'math.ceil', code)
    code = re.sub(r'\bstd::round\b', 'math.round', code)
    code = re.sub(r'\bstd::sin\b', 'math.sin', code)
    code = re.sub(r'\bstd::cos\b', 'math.cos', code)
    code = re.sub(r'\bstd::sqrt\b', 'math.sqrt', code)
    code = re.sub(r'\bstd::to_string\s*\(', 'tostring(', code)
    # std::clamp(v, lo, hi) -> math.max(lo, math.min(hi, v))
    code = re.sub(
        r'std::clamp\s*\(([^,]+),\s*([^,]+),\s*([^)]+)\)',
        lambda m: f'math.max({m.group(2).strip()}, math.min({m.group(3).strip()}, {m.group(1).strip()}))',
        code
    )
    # std::lerp(a, b, t) -> (a + (b - a) * t)
    code = re.sub(
        r'std::lerp\s*\(([^,]+),\s*([^,]+),\s*([^)]+)\)',
        lambda m: f'({m.group(1).strip()} + ({m.group(2).strip()} - {m.group(1).strip()}) * {m.group(3).strip()})',
        code
    )
    # std::find(v.begin(), v.end(), x) == v.end() -> not tableContains(v, x)
    # std::find(v.begin(), v.end(), x) != v.end() -> tableContains(v, x)
    # For now, translate to a helper pattern
    code = re.sub(
        r'std::find\s*\(\s*(\w+)\.(?:begin|cbegin)\s*\(\s*\)\s*,\s*\1\.(?:end|cend)\s*\(\s*\)\s*,\s*([^)]+)\)\s*==\s*\1\.(?:end|cend)\s*\(\s*\)',
        lambda m: f'(function() for _,_v in ipairs({m.group(1)}) do if _v == {m.group(2).strip()} then return false end end return true end)()',
        code
    )
    code = re.sub(
        r'std::find\s*\(\s*(\w+)\.(?:begin|cbegin)\s*\(\s*\)\s*,\s*\1\.(?:end|cend)\s*\(\s*\)\s*,\s*([^)]+)\)\s*~=\s*\1\.(?:end|cend)\s*\(\s*\)',
        lambda m: f'(function() for _,_v in ipairs({m.group(1)}) do if _v == {m.group(2).strip()} then return true end end return false end)()',
        code
    )
    # std::vector<T>().swap(v) -> v = {}
    code = re.sub(r'std::vector<[^>]+>\s*\(\s*\)\.swap\s*\((\w+)\)', r'\1 = {}', code)
    # std::vector<T> v  or  std::list<T> v declarations -> local v = {}
    code = re.sub(r'(?m)^(\s*)(?:static\s+)?std::(?:vector|list|array)<[^>]+>\s+(\w+)\b(?!\s*=)', r'\1local \2 = {}', code)
    # std::array<T, N> points { ... } declarations
    code = re.sub(r'(?m)^(\s*)(?:static\s+)?std::array<[^>]+>\s+(\w+)\s*\{', r'\1local \2 = {', code)
    # .erase(it) or .erase(container.begin() + n) -> table.remove
    code = re.sub(r'(\w+)\.erase\s*\((\w+)\.begin\s*\(\s*\)\s*\+\s*(\w+)\s*\)', r'table.remove(\1, \3 + 1)', code)

    # Native calls (after range-for so GetAllPeds etc. don't confuse balanced paren extraction)
    code = translate_natives(code)

    # WAIT -> Citizen.Wait
    code = re.sub(r'\bWAIT\s*\(', 'Citizen.Wait(', code)

    # Remove type casts like (float), (int), (DWORD) etc before further processing
    code = re.sub(r'\(\s*(?:float|double|DWORD64|DWORD|UINT|INT|uint32_t|int64_t)\s*\)', '', code)
    code = re.sub(r'\(int\)\s*', '', code)
    # static_cast<T>(x) -> x
    code = re.sub(r'static_cast\s*<[^>]+>\s*\(([^)]+)\)', r'\1', code)
    # CurrentEffect:: stubs (no-arg and with args)
    code = re.sub(r'CurrentEffect::\w+\s*\([^)]*\)\s*;?', '', code)
    # CreatePoolPed -> CreatePed
    code = re.sub(r'\bCreatePoolPed\s*\(', 'CreatePed(', code)
    code = re.sub(r'\bCreateRandomPoolPed\s*\(', '_ChaosCreateRandomPed(', code)
    code = re.sub(r'\bCreatePoolPedInsideVehicle\s*\(', 'CreatePedInsideVehicle(', code)
    code = re.sub(
        r'\bCreatePoolVehicle\s*\(([^)]+)\)',
        r'CreateVehicle(\1, true, true)',
        code
    )
    code = re.sub(
        r'\bCreatePoolPedInsideVehicle\s*\(([^)]+)\)',
        r'CreatePedInsideVehicle(\1, true, true)',
        code
    )
    # CreateHostilePed(model, weapon) -> create a hostile ped helper
    code = re.sub(
        r'CreateHostilePed\s*\(([^,]+),\s*([^)]+)\)',
        r'_ChaosCreateHostilePed(\1, \2)',
        code
    )
    # SetCompanionRelationship -> no-op
    code = re.sub(r'SetCompanionRelationship\s*\([^)]+\)\s*;?', '', code)
    # Hooks:: audio/shader calls -> no-op comments
    code = re.sub(r'Hooks::\w+\s*\([^)]*\)\s*;?', '', code)
    # XInput:: rumble -> no-op
    code = re.sub(r'XInput::\w+\s*\([^)]*\)\s*;?', '', code)
    # LoadModel(X) -> RequestModel(X) (custom helper in source)
    code = re.sub(r'\bLoadModel\s*\(', 'RequestModel(', code)

    # Out-param / multi-return fixes — MUST run before replace_if so conditions are clean
    # AddRelationshipGroup out-param: AddRelationshipGroup("X", &var) -> var = AddRelationshipGroup("X")
    code = re.sub(
        r'AddRelationshipGroup\s*\(\s*("[^"]*")\s*,\s*&\s*(\w+)\s*\)',
        r'\2 = AddRelationshipGroup(\1)',
        code
    )
    # GetModelDimensions(hash, &min, &max) -> local min, max = GetModelDimensions(hash)
    code = re.sub(
        r'GetModelDimensions\s*\(([^,]+),\s*&\s*(\w+)\s*,\s*&\s*(\w+)\s*\)',
        r'local \2, \3 = GetModelDimensions(\1)',
        code
    )
    # GetGroundZFor3dCoord(x,y,z, &gz, useWater, ignore) -> local _ret, gz = GetGroundZFor3dCoord(...)
    code = re.sub(
        r'GetGroundZFor3dCoord\s*\(([^,]+),\s*([^,]+),\s*([^,]+),\s*&\s*(\w+)\s*,\s*([^,]+),\s*([^)]+)\)',
        r'local _, \4 = GetGroundZFor3dCoord(\1, \2, \3, 0.0, \5, \6)',
        code
    )
    # GetCurrentPedWeapon(ped, &weaponHash, includeUnarmed) -> local _, weaponHash = GetCurrentPedWeapon(ped, includeUnarmed)
    code = re.sub(
        r'GetCurrentPedWeapon\s*\(([^,]+),\s*&\s*(\w+)\s*,\s*([^)]+)\)',
        r'local _, \2 = GetCurrentPedWeapon(\1, \3)',
        code
    )
    # GetAmmoInClip(ped, hash, &ammo) -> local _, ammo = GetAmmoInClip(ped, hash)
    code = re.sub(
        r'GetAmmoInClip\s*\(([^,]+),\s*([^,]+),\s*&\s*(\w+)\s*\)',
        r'local _, \3 = GetAmmoInClip(\1, \2)',
        code
    )
    # GetVehicleColours(veh, &col1, &col2) -> local col1, col2 = GetVehicleColours(veh)
    code = re.sub(
        r'GetVehicleColours\s*\(([^,]+),\s*&\s*(\w+)\s*,\s*&\s*(\w+)\s*\)',
        r'local \2, \3 = GetVehicleColours(\1)',
        code
    )
    # GetVehicleExtraColours(veh, &col1, &col2) -> local col1, col2 = GetVehicleExtraColours(veh)
    code = re.sub(
        r'GetVehicleExtraColours\s*\(([^,]+),\s*&\s*(\w+)\s*,\s*&\s*(\w+)\s*\)',
        r'local \2, \3 = GetVehicleExtraColours(\1)',
        code
    )
    # Generic single &var in NoLongerNeeded/Delete calls: strip &
    code = re.sub(r'\b(DeleteEntity|DeletePed|DeleteObject|DeleteVehicle|SetEntityAsNoLongerNeeded|SetPedAsNoLongerNeeded|SetObjectAsNoLongerNeeded|SetVehicleAsNoLongerNeeded)\s*\(\s*&\s*(\w+)\s*\)', r'\1(\2)', code)
    # Remaining &var in argument position -> just var (strip the &)
    code = re.sub(r'&(\w+)', r'\1', code)
    # Memory:: calls have no FiveM equivalent — stub with a comment
    code = re.sub(r'Memory::\w+\s*\([^)]*\)', '--[[Memory:: not available in FiveM]]', code)

    # Compound assignments: x += y  x -= y  x *= y  x /= y
    code = re.sub(r'(\w+(?:\.\w+)*)\s*\+=\s*([^;\n]+)', r'\1 = \1 + (\2)', code)
    code = re.sub(r'(\w+(?:\.\w+)*)\s*-=\s*([^;\n]+)', r'\1 = \1 - (\2)', code)
    code = re.sub(r'(\w+(?:\.\w+)*)\s*\*=\s*([^;\n]+)', r'\1 = \1 * (\2)', code)
    code = re.sub(r'(\w+(?:\.\w+)*)\s*\/=\s*([^;\n]+)', r'\1 = \1 / (\2)', code)

    # Standard for: for (TYPE i = start; i < end; i++) -> for i = start, end-1 do
    # Handles numeric and variable upper bounds
    def replace_std_for(code_str):
        result = []
        i = 0
        while i < len(code_str):
            m = re.search(r'\bfor\s*\(', code_str[i:])
            if not m:
                result.append(code_str[i:])
                break
            result.append(code_str[i:i+m.start()])
            paren_start = i + m.end() - 1
            inner, end = extract_parens(code_str, paren_start)
            # Try to match c-style for: TYPE? var = start; var CMP limit; increment
            cstyle = re.match(
                r'\s*(?:(?:int|size_t|unsigned\s+int|auto)\s+)?(\w+)\s*=\s*(.+?)\s*;\s*\1\s*([<>]=?|!=)\s*(.+?)\s*;\s*(.+)',
                inner
            )
            if cstyle:
                var = cstyle.group(1)
                start = cstyle.group(2).strip()
                cmp = cstyle.group(3)
                limit = cstyle.group(4).strip()
                increment = cstyle.group(5).strip()
                # Determine step from increment expression
                step_m = re.match(r'(?:\+\+\w+|\w+\+\+)$', increment)
                step_neg = re.match(r'(?:--\w+|\w+--)$', increment)
                step_add = re.match(r'\w+\s*\+=\s*(\d+)', increment)
                step_val = '-1' if step_neg else (step_add.group(1) if step_add else None)
                # Adjust limit for < vs <=
                if cmp == '<':
                    # Try numeric
                    try:
                        limit_lua = str(int(limit) - 1)
                    except ValueError:
                        limit_lua = f'({limit}) - 1'
                elif cmp == '<=':
                    limit_lua = limit
                else:
                    # Can't cleanly translate !=, >, >=
                    result.append(f'for ({inner})')
                    i = end
                    continue
                if step_val and step_val != '1':
                    result.append(f'for {var} = {start}, {limit_lua}, {step_val} do')
                else:
                    result.append(f'for {var} = {start}, {limit_lua} do')
            else:
                # Last-chance: any begin()/cbegin() call
                any_iter = re.search(r'(\w+)\.(?:begin|cbegin)\s*\(\s*\)', inner)
                if any_iter:
                    container = any_iter.group(1)
                    it_var_m = re.match(r'\s*(?:[\w:<>*&\s]+\s+)?(\w+)\s*=', inner)
                    it_var = it_var_m.group(1) if it_var_m else '_it'
                    result.append(f'for _, {it_var} in pairs({container}) do')
                else:
                    # Try range-for pattern (no semicolons, has colon + container)
                    range_last = re.match(
                        r'\s*(?:const\s+)?(?:auto\s*[&*]?|\w[\w:<>*&\s]+\s+)(\w+)\s*:\s*(\w+)',
                        inner
                    )
                    if range_last:
                        result.append(f'for _, {range_last.group(1)} in ipairs({range_last.group(2)}) do')
                    else:
                        # Totally unknown — leave as comment placeholder
                        result.append(f'--[[for ({inner})]] do')
            i = end
        return ''.join(result)
    code = replace_std_for(code)

    # while(true) -> while true do
    code = re.sub(r'\bwhile\s*\(\s*true\s*\)\s*\{?', 'while true do', code)
    # while (!condition) -> while not condition do  (brace-less while)
    def replace_while(code_str):
        result = []
        i = 0
        while i < len(code_str):
            m = re.search(r'\bwhile\s*\(', code_str[i:])
            if not m:
                result.append(code_str[i:])
                break
            result.append(code_str[i:i+m.start()])
            paren_start = i + m.end() - 1
            cond, end = extract_parens(code_str, paren_start)
            if cond.strip() == 'true':
                result.append('while true do')
            else:
                cond_lua = translate_condition(cond)
                result.append(f'while {cond_lua} do')
            # Skip optional {
            rest = code_str[end:].lstrip()
            if rest.startswith('{'):
                end = end + (len(code_str[end:]) - len(rest)) + 1
            i = end
        return ''.join(result)
    code = replace_while(code)

    # else if (...) { -> elseif ... then  (before general if handling)
    def replace_else_if(s):
        # find the condition
        rest = s[s.index('('):]
        cond, _ = extract_parens(rest, 0)
        cond = translate_condition(cond)
        return f'elseif {cond} then'
    code = re.sub(r'\}\s*else\s+if\s*\(', lambda m: '} else if (', code)  # normalize spacing first

    # if (cond) with balanced paren extraction
    def replace_if(code_str):
        result = []
        i = 0
        while i < len(code_str):
            # Look for 'if' keyword
            m = re.search(r'\bif\s*\(', code_str[i:])
            if not m:
                result.append(code_str[i:])
                break
            # Append everything before this if
            result.append(code_str[i:i+m.start()])
            paren_start = i + m.end() - 1  # position of '('
            cond, end = extract_parens(code_str, paren_start)
            cond = translate_condition(cond)
            # Check if followed by {
            rest = code_str[end:].lstrip()
            if rest.startswith('{'):
                result.append(f'if {cond} then')
                result.append(code_str[end:end + (len(code_str[end:]) - len(rest))])  # whitespace
                i = end + (len(code_str[end:]) - len(rest)) + 1  # skip {
            else:
                result.append(f'if {cond} then')
                i = end
        return ''.join(result)
    code = replace_if(code)

    # } else if (cond) { -> elseif cond then  AND bare else if (cond) -> elseif cond then
    def replace_elseif(code_str):
        result = []
        i = 0
        while i < len(code_str):
            m = re.search(r'(?:\}\s*)?else\s+if\s*\(', code_str[i:])
            if not m:
                result.append(code_str[i:])
                break
            result.append(code_str[i:i+m.start()])
            # If starts with }, emit end first
            seg = m.group(0)
            if seg.lstrip().startswith('}'):
                result.append('end\nelseif ')
            else:
                result.append('elseif ')
            paren_start = i + m.end() - 1
            cond, end = extract_parens(code_str, paren_start)
            cond = translate_condition(cond)
            rest = code_str[end:].lstrip()
            if rest.startswith('{'):
                result.append(f'{cond} then')
                i = end + (len(code_str[end:]) - len(rest)) + 1
            else:
                result.append(f'{cond} then')
                i = end
        return ''.join(result)
    code = replace_elseif(code)

    # } else { -> else
    code = re.sub(r'\}\s*else\s*\{', 'else', code)
    # } else\n -> else (no brace)
    code = re.sub(r'\}\s*else\b', 'else', code)

    # Remaining trailing { on block-opener lines -> strip it (already have 'do'/'then')
    code = re.sub(r'((?:while|for)\s+[^{}\n]+)\s*\{', r'\1', code)
    code = re.sub(r'(if\s+[^{}\n]+then)\s*\{', r'\1', code)

    # Double 'do' from 'while X do {' -> 'while X do'
    code = re.sub(r'\bdo\s+do\b', 'do', code)

    # Standalone { on its own line -> do  (naked blocks)
    code = re.sub(r'(?m)^\s*\{', 'do', code)

    # Protect {} empty tables and { ... } array literals before } -> end conversion
    code = code.replace('{}', '\x00EMPTYTABLE\x00')
    # Also protect brace-initializer list patterns: = { values }
    def protect_brace_literal(m):
        inner = m.group(1)
        # Only protect if it looks like a value list (not block keywords)
        if not re.search(r'\b(do|then|end|if|for|while|else)\b', inner):
            return '\x00BRACELITSTART\x00' + inner + '\x00BRACELITEND\x00'
        return m.group(0)
    code = re.sub(r'\{([^{}]*)\}', protect_brace_literal, code, flags=re.DOTALL)

    # } -> end
    code = re.sub(r'\}', 'end', code)

    # Restore protected literals
    code = code.replace('\x00EMPTYTABLE\x00', '{}')
    code = re.sub(r'\x00BRACELITSTART\x00(.*?)\x00BRACELITEND\x00', lambda m: '{' + m.group(1) + '}', code, flags=re.DOTALL)

    CPP_TYPE_PAT = r'(?:static\s+)?(?:constexpr\s+)?(?:const\s+)?(?:unsigned\s+)?(?:DWORD64|DWORD|UINT|INT|int|float|bool|double|Ped|Vehicle|Entity|Object|Hash|Vector3|ChaosVector2|ChaosVector3|Any|auto|std::string|size_t|uint32_t|int64_t|UINT64)'
    # C++ variable declarations -> local  (anywhere on line, not just line-start)
    code = re.sub(
        r'(?m)^(\s*)' + CPP_TYPE_PAT + r'\s+(\w+)\s*=',
        r'\1local \2 =',
        code
    )
    code = re.sub(
        r'(?m)^(\s*)' + CPP_TYPE_PAT + r'\s+(\w+)\s*;',
        r'\1local \2',
        code
    )

    # std::vector<T> varName -> local varName = {}
    code = re.sub(
        r'(?m)^(\s*)(?:static\s+)?(?:const\s+)?std::(?:vector|list|deque|set)<[^>]+>\s+(\w+)\s*;',
        r'\1local \2 = {}',
        code
    )
    # With inline initializer: varName = { ... }  (may span lines)
    def _replace_vec_init(m):
        indent = m.group(1)
        name = m.group(2)
        inner = m.group(3).strip().strip(',')
        items = [x.strip() for x in inner.split(',') if x.strip()]
        return indent + 'local ' + name + ' = {' + ', '.join(items) + '}'
    code = re.sub(
        r'^(\s*)(?:static\s+)?(?:const\s+)?std::(?:vector|list|deque|set)<[^>]+>\s+(\w+)\s*=\s*\{([^{}]*)\};?',
        _replace_vec_init,
        code,
        flags=re.MULTILINE | re.DOTALL
    )
    # Fallback: single-line with no braces
    code = re.sub(
        r'(?m)^(\s*)(?:static\s+)?(?:const\s+)?std::(?:vector|list|deque|set)<[^>]+>\s+(\w+)\s*=\s*[^;\n{]+;?',
        r'\1local \2 = {}',
        code
    )

    # std::vector<T>::iterator varName -> strip (iterator declarations not needed in Lua)
    code = re.sub(r'(?m)^[^\n]*std::\w+(?:<[^>]+>)?::iterator\s+\w+[^\n]*\n?', '', code)

    # container.erase(container.begin()) -> table.remove(container, 1)
    code = re.sub(r'(\w+)\.erase\s*\(\s*\1\.begin\s*\(\s*\)\s*\)', r'table.remove(\1, 1)', code)
    # container.erase(container.begin() + N) -> table.remove(container, N+1)  (handled elsewhere)
    # it = container.erase(it) -> table.remove style (mark with index)
    code = re.sub(r'it\s*=\s*(\w+)\.erase\s*\(\s*it\s*\)', r'table.remove(\1, _itIdx); _itIdx = _itIdx - 1', code)
    # animationHandleByPed.erase(it = it + 1) -> it = it + 1
    code = re.sub(r'\w+\.erase\s*\(it\s*=\s*it\s*\+\s*1\)', r'it = it + 1', code)

    # vector.push_back(x) -> table.insert(vector, x)
    code = re.sub(r'(\w+)\.push_back\s*\(([^)]+)\)', r'table.insert(\1, \2)', code)

    # vector.emplace_back(a, b) -> table.insert(vector, {a, b})  (best-effort)
    code = re.sub(r'(\w+)\.emplace_back\s*\(([^)]+)\)', lambda m: f'table.insert({m.group(1)}, {{{m.group(2)}}})', code)

    # vector.clear() -> varName = {}
    code = re.sub(r'(\w+)\.clear\s*\(\s*\)', r'\1 = {}', code)

    # map.count(key) == 0 -> map[key] == nil
    code = re.sub(r'(\w+)\.count\s*\(([^)]+)\)\s*==\s*0', r'\1[\2] == nil', code)
    # map.count(key) > 0 / != 0 / >= 1 -> map[key] ~= nil
    code = re.sub(r'(\w+)\.count\s*\(([^)]+)\)\s*(?:!=|>|>=)\s*\d+', r'\1[\2] ~= nil', code)
    # map.contains(key) -> map[key] ~= nil
    code = re.sub(r'(\w+)\.contains\s*\(([^)]+)\)', r'\1[\2] ~= nil', code)
    # map.emplace(k, v) -> map[k] = v
    code = re.sub(r'(\w+)\.emplace\s*\(([^,]+),\s*([^)]+)\)', r'\1[\2] = \3', code)

    # (it.first/it.second moved below arrow-op conversion)

    # vector.size() -> #vector
    code = re.sub(r'(\w+)\.size\s*\(\s*\)', r'#\1', code)

    # vector.empty() -> #vector == 0
    code = re.sub(r'(\w+)\.empty\s*\(\s*\)', r'#\1 == 0', code)

    # Vector3 constructor -> vector3
    code = re.sub(r'\bVector3\s*\(([^)]*)\)', r'vector3(\1)', code)
    # Empty vector3() -> vector3(0,0,0)
    code = re.sub(r'\bvector3\s*\(\s*\)', 'vector3(0,0,0)', code)

    # Vector3.DistanceTo(other) -> #(vec - other)
    code = re.sub(r'(\w+)\.DistanceTo\s*\(([^)]+)\)', r'#(\1 - \2)', code)

    # XInput:: -> comment stub (not available in FiveM)
    code = re.sub(r'XInput::\w+\s*\([^)]*\)', '--[[XInput not available in FiveM]]', code)

    # g_Random -> math.random helpers
    code = re.sub(r'g_Random\.GetRandomFloat\s*\(([^,]+),\s*([^)]+)\)',
                  lambda m: f'({m.group(1).strip()} + math.random() * ({m.group(2).strip()} - {m.group(1).strip()}))',
                  code)
    code = re.sub(r'g_Random\.GetRandomInt\s*\(([^,]+),\s*([^)]+)\)',
                  r'math.random(\1, \2)', code)

    # nullptr/NULL -> nil
    code = re.sub(r'\b(?:nullptr|NULL)\b', 'nil', code)

    # true/false already correct in Lua
    # C++ float literals: 1.f -> 1.0,  1.5f -> 1.5,  .8f -> 0.8
    code = re.sub(r'(\d+)\.f\b', r'\1.0', code)
    code = re.sub(r'(\d+\.\d+)f\b', r'\1', code)
    code = re.sub(r'(?<!\w)\.(\d+)f\b', r'0.\1', code)
    # Handle negative float literals: -1.f etc
    code = re.sub(r'(-\d+)\.f\b', r'\1.0', code)

    # break is valid Lua
    # return is valid Lua

    # Strip semicolons
    code = re.sub(r';', '', code)

    # Final cleanup: 'else if X then' -> 'elseif X then'
    code = re.sub(r'\belse\s+if\b', 'elseif', code)

    # Fix "if local X, Y = FUNC(...) then" -> "local X, Y = FUNC(...)\nif X then"
    # Also handles "if local X, Y = FUNC() and OTHER then" -> split + chain AND
    def fix_if_multi_return(m):
        indent = m.group(1)
        varlist = m.group(2)  # e.g. "_, groundZ"
        func_call = m.group(3)  # e.g. "GetGroundZFor3dCoord(...)"
        rest = m.group(4) or ''  # e.g. " and  OtherCond" or ""
        first_var = varlist.split(',')[0].strip()
        if rest.strip():
            # rest already starts with "and" keyword, just append as-is
            rest_clean = re.sub(r'^\s*and\s+', '', rest.strip())
            cond = f'{first_var} and {rest_clean}'
        else:
            cond = first_var
        return f'{indent}local {varlist} = {func_call}\n{indent}if {cond} then'
    code = re.sub(
        r'(?m)^(\s*)if local ([\w\s,_]+) = ([\w.]+\([^)]*\))((?:\s+and\s+[^\n]+)?) then',
        fix_if_multi_return,
        code
    )

    # Fix 'not #x == 0' -> '#x ~= 0'  (from !x.empty() translation)
    code = re.sub(r'not\s+(#\w+)\s*==\s*0', r'\1 ~= 0', code)

    # Pre-decrement/increment: --var -> var = var - 1,  ++var -> var = var + 1
    # Must run BEFORE post-increment to avoid double-translate
    code = re.sub(r'--(\w+)', r'\1 = \1 - 1', code)
    code = re.sub(r'\+\+(\w+)', r'\1 = \1 + 1', code)
    # Post-increment/decrement: var++ -> var = var + 1,  var-- -> var = var - 1
    code = re.sub(r'\b(\w+)\+\+', r'\1 = \1 + 1', code)
    code = re.sub(r'\b(\w+)--', r'\1 = \1 - 1', code)

    # Fix "if VAR = VAR - 1 CMP VAL then" -> "VAR = VAR - 1\nif VAR CMP VAL then"
    # Must run AFTER --var transformation above (which produces "VAR = VAR - 1")
    def fix_if_pre_decrement(m):
        indent = m.group(1)
        var = m.group(2)
        op = m.group(3)
        val = m.group(4)
        return f'{indent}{var} = {var} - 1\n{indent}if {var} {op} {val} then'
    code = re.sub(
        r'(?m)^(\s*)if (\w+) = \2 - 1 ([=<>!~]+) (\S+) then',
        fix_if_pre_decrement,
        code
    )

    # Arrow operator -> dot (best-effort for simple cases: ptr->field -> ptr.field)
    code = re.sub(r'(\w+)->', r'\1.', code)

    # map/unordered_map iterator: it.first -> _k, it.second -> _v (from pairs() loop)
    # Must run AFTER arrow-op conversion (it->first becomes it.first first)
    code = re.sub(r'\bit\.first\b', '_k', code)
    code = re.sub(r'\bit\.second\b', '_v', code)

    # table.remove(map, _itIdx) -> map[_k] = nil  (map erase via iterator)
    code = re.sub(r'table\.remove\s*\((\w+),\s*_itIdx\)\s*_itIdx\s*=\s*_itIdx\s*-\s*1', r'\1[_k] = nil', code)

    # Indent cleanup: normalize indentation (4 spaces)
    lines = code.split('\n')
    clean = []
    indent = 0
    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue
        # Decrease before end/else/elseif
        if (stripped == 'end' or stripped.startswith('end ') or stripped.startswith('end--') or
                stripped == 'else' or stripped.startswith('else ') or
                stripped.startswith('elseif ')):
            indent = max(0, indent - 1)
        clean.append('    ' * indent + stripped)
        # Increase after openers
        if (stripped.endswith(' do') or stripped.endswith(' then') or
                stripped == 'else' or stripped == 'do'):
            indent += 1
        if stripped == 'end':
            pass  # already decreased before

    code = '\n'.join(clean)

    # Fix `continue` -> goto/label pattern (Lua 5.4 / FiveM supports goto)
    if 'continue' in code:
        code = _fix_continue(code)

    return code


def build_lua_id(effect_id):
    """Convert snake_case id like 'player_rocket' to PascalCase like 'PlayerRocket'."""
    return ''.join(word.capitalize() for word in effect_id.split('_'))


def build_shared_entry(effect_id, effect_name, lua_id, is_timed, is_short):
    weight = 5 if is_short else 10
    extra_fields = ''
    if not is_timed:
        extra_fields += ',\n        instant = true'
    if is_short:
        extra_fields += ',\n        short = true'
    return (
        f'    {{\n'
        f'        id = "{effect_id}",\n'
        f'        name = "{effect_name}",\n'
        f'        fn = FX_{lua_id},\n'
        f'        weight = {weight}{extra_fields},\n'
        f'    }},'
    )


def translate_file(cpp_path):
    """Translate a single .cpp file. Returns a list of (shared_entry, client_func)."""
    src = cpp_path.read_text(encoding='utf-8', errors='replace')

    # Collect #define constants before stripping
    defines = {}
    for m in re.finditer(r'#define\s+(\w+)\s+(\S+)', src):
        defines[m.group(1)] = m.group(2).rstrip('f')  # strip trailing f from floats

    # Strip #define and #include lines
    src = re.sub(r'#define\s+[^\n]+\n', '\n', src)
    src = re.sub(r'#include\s+[^\n]+\n', '\n', src)

    infos = [info for info in parse_register_effects(src) if info.get('id')]
    if not infos:
        return None

    results = []
    chaos_vars = parse_chaos_vars(src)
    override_dir = ROOT / 'tools' / 'overrides'

    for info in infos:
        effect_id = info['id']
        effect_name = info['name'] or effect_id
        is_timed = info['is_timed']
        is_short = info['is_short']
        lua_id = build_lua_id(effect_id)
        shared_entry = build_shared_entry(effect_id, effect_name, lua_id, is_timed, is_short)

        override_file = override_dir / f'FX_{lua_id}.lua'
        if override_file.exists():
            results.append((shared_entry, override_file.read_text(encoding='utf-8').strip()))
            continue

        start_body = find_function(src, info['on_start']) if info['on_start'] else None
        stop_body = find_function(src, info['on_stop']) if info['on_stop'] else None
        tick_body = find_function(src, info['on_tick']) if info['on_tick'] else None

        fn_lines = []
        fn_lines.append(f'-- AUTO-GENERATED from {cpp_path.name}')
        fn_lines.append(f'function FX_{lua_id}(alive)')

        for type_, vname, val in chaos_vars:
            if val:
                if type_ == 'array':
                    fn_lines.append(f'    local {vname} = {val}')
                else:
                    val_lua = translate_cpp_body(val, defines)
                    fn_lines.append(f'    local {vname} = {val_lua}')
            else:
                fn_lines.append(f'    local {vname}')

        if start_body:
            translated = translate_cpp_body(start_body, defines)
            for line in translated.split('\n'):
                fn_lines.append('    ' + line)

        if tick_body or is_timed:
            fn_lines.append('    while alive() do')
            if tick_body:
                translated = translate_cpp_body(tick_body, defines)
                for line in translated.split('\n'):
                    fn_lines.append('        ' + line)
            fn_lines.append('        Citizen.Wait(0)')
            fn_lines.append('    end')

        if stop_body:
            fn_lines.append('    -- OnStop cleanup')
            translated = translate_cpp_body(stop_body, defines)
            for line in translated.split('\n'):
                fn_lines.append('    ' + line)

        fn_lines.append('end')
        client_func = '\n'.join(fn_lines)

        unresolved_reason = find_unresolved_cpp_construct(client_func)
        parses, parse_error = lua_parses(client_func)
        if unresolved_reason or not parses:
            reason = unresolved_reason or parse_error or 'Lua parse failure'
            client_func = build_fallback_function(effect_id, effect_name, lua_id, cpp_path, reason)

        results.append((shared_entry, client_func))

    return results


# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    if not EFFECTS_DIR.exists():
        print(f"ERROR: Effects dir not found: {EFFECTS_DIR}", file=sys.stderr)
        sys.exit(1)

    cpp_files = sorted(EFFECTS_DIR.rglob('*.cpp'))
    print(f"Found {len(cpp_files)} .cpp files")

    client_parts = []
    shared_parts = []
    skipped = []
    ok = 0
    fallback_count = 0
    shared_ids = set()

    for path in cpp_files:
        try:
            result = translate_file(path)
        except Exception as e:
            skipped.append((path.name, str(e)))
            continue

        if result is None:
            skipped.append((path.name, 'no REGISTER_EFFECT or missing id'))
            continue

        for shared_entry, client_func in result:
            id_match = re.search(r'id = "([^"]+)"', shared_entry)
            if not id_match:
                continue
            effect_id = id_match.group(1)
            if effect_id in shared_ids:
                continue
            shared_ids.add(effect_id)
            client_parts.append(client_func)
            shared_parts.append(shared_entry)
            ok += 1
            if '-- FALLBACK-GENERATED' in client_func:
                fallback_count += 1

    # Write client file
    client_out = (
        '--[[\n'
        '    AUTO-GENERATED by tools/transpile_effects.py\n'
        '    DO NOT EDIT — run transpiler again to regenerate, then manually refine.\n'
        ']]\n\n'
        + FALLBACK_HELPERS + '\n\n'
    ) + '\n\n'.join(client_parts) + '\n'

    OUT_CLIENT.write_text(client_out, encoding='utf-8')
    print(f"Wrote {OUT_CLIENT}")

    # Write shared file
    shared_out = (
        '--[[\n'
        '    AUTO-GENERATED effects pool — appended to Effects.Pool at runtime.\n'
        '    Loaded after resource/shared/effects.lua\n'
        ']]\n\n'
        'local generated = {\n'
    ) + '\n'.join(shared_parts) + '\n}\n\n' + (
        'for _, e in ipairs(generated) do\n'
        '    Effects.Pool[#Effects.Pool + 1] = e\n'
        'end\n'
    )

    OUT_SHARED.write_text(shared_out, encoding='utf-8')
    print(f"Wrote {OUT_SHARED}")

    print(f"\nTranslated: {ok}")
    print(f"Fallbacks:  {fallback_count}")
    if skipped:
        print(f"Skipped:    {len(skipped)}")
        for name, reason in skipped[:20]:
            print(f"  {name}: {reason}")
        if len(skipped) > 20:
            print(f"  ... and {len(skipped)-20} more")


if __name__ == '__main__':
    main()
