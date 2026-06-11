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

function FX_MetaTimerspeed05x(alive)
    MetaSetInternal('timerModifier', 0.5)
    while alive() do Citizen.Wait(250) end
    MetaSetInternal('timerModifier', 1.0)
end

function FX_MetaTimerspeed2x(alive)
    MetaSetInternal('timerModifier', 2.0)
    while alive() do Citizen.Wait(250) end
    MetaSetInternal('timerModifier', 1.0)
end

function FX_MetaTimerspeed5x(alive)
    MetaSetInternal('timerModifier', 5.0)
    while alive() do Citizen.Wait(250) end
    MetaSetInternal('timerModifier', 1.0)
end

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

-- Meta effects call server directly since they originate from chaos system
function MetaSetInternal(key, value)
    TriggerServerEvent('cc:meta_set_internal', key, value)
end
