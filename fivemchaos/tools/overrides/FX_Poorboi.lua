function FX_Poorboi(alive)
    StatSetInt(GetHashKey("SP0_TOTAL_CASH"), 0, true)
    StatSetInt(GetHashKey("SP1_TOTAL_CASH"), 0, true)
    StatSetInt(GetHashKey("SP2_TOTAL_CASH"), 0, true)
    SetPedMoney(PlayerPedId(), 0)
end
