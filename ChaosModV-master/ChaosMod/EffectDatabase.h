#pragma once

#include <unordered_map>
#include <string>
#include <vector>

// Forward declaration - adjust based on actual Chaos Mod structure
class RegisteredEffect;

namespace EffectDatabase
{
    extern std::unordered_map<std::string, RegisteredEffect*> g_EffectRegistry;
    
    void InitializeRegistry();
    
    RegisteredEffect* GetEffectById(const std::string& effectId);
    
    std::vector<std::string> GetAllEffectIds();
    
    bool HasEffect(const std::string& effectId);
}