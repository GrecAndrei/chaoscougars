-- sync_mode: META — modifies server state, dispatched by server chaos system

function FX_MetaSpawnMultiple(alive)
    MetaSetInternal('additionalEffects', 2)
    while alive() do Citizen.Wait(250) end
    MetaSetInternal('additionalEffects', 0)
end

function FX_MetaDuration05x(alive)
    MetaSetInternal('durationModifier', 0.5)
    while alive() do Citizen.Wait(250) end
    MetaSetInternal('durationModifier', 1.0)
end

function FX_MetaDuration2x(alive)
    MetaSetInternal('durationModifier', 2.0)
    while alive() do Citizen.Wait(250) end
    MetaSetInternal('durationModifier', 1.0)
end

-- FX_MetaTimerspeed05x / 2x / 5x live in effects_generated.lua (loads after
-- this file). The duplicates that used to be here were dead code shadowed by
-- load order; both registries point at the generated definitions.

function FX_MetaNoChaos(alive)
    MetaSetInternal('disableChaos', true)
    while alive() do Citizen.Wait(250) end
    MetaSetInternal('disableChaos', false)
end

function FX_MetaHideUI(alive)
    MetaSetInternal('hideChaosUI', true)
    while alive() do Citizen.Wait(250) end
    MetaSetInternal('hideChaosUI', false)
end

-- === NEW: META ===

function FX_MetaSuperChaos(alive)
    MetaSetInternal('additionalEffects', 3)
    while alive() do Citizen.Wait(250) end
    MetaSetInternal('additionalEffects', 0)
end

function FX_MetaExtremeDuration(alive)
    MetaSetInternal('durationModifier', 3.0)
    while alive() do Citizen.Wait(250) end
    MetaSetInternal('durationModifier', 1.0)
end

function FX_MetaChaosRamp(alive)
    MetaSetInternal('additionalEffects', 1)
    MetaSetInternal('timerModifier', 0.5)
    while alive() do Citizen.Wait(250) end
    MetaSetInternal('additionalEffects', 0)
    MetaSetInternal('timerModifier', 1.0)
end

-- MetaSetInternal is a no-op now. The server applies meta state directly
-- in chaos.lua's DispatchEffect (see fx.meta in the registry). It calls
-- TriggerServerEvent('cc:meta_set_internal', ...) with admin ACE, so
-- direct client invocations would be rejected. This stub keeps the
-- client META effect bodies from crashing.
function MetaSetInternal(key, value)
end
