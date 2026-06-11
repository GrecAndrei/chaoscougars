function FX_PlayerRandclothes(alive)
    local playerPed = PlayerPedId()
    for i = 0, 11 do
        local drawableAmount = GetNumberOfPedDrawableVariations(playerPed, i)
        local drawable = drawableAmount > 0 and math.random(0, drawableAmount - 1) or 0
        local textureAmount = GetNumberOfPedTextureVariations(playerPed, i, drawable)
        local texture = textureAmount > 0 and math.random(0, textureAmount - 1) or 0
        SetPedComponentVariation(playerPed, i, drawable, texture, math.random(0, 3))
    end
end
