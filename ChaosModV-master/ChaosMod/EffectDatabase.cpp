#include "stdafx.h"
#include "EffectDatabase.h"
#include "Effects/Register/RegisteredEffects.h"
#include "Util/Logging.h"

namespace EffectDatabase
{
    std::unordered_map<std::string, RegisteredEffect*> g_EffectRegistry;
    
    void InitializeRegistry()
    {
        LOG("[Effect Database] Initializing effect registry...");
        
        // Log how many effects Chaos Mod has registered
        LOG("[Effect Database] Found " << g_RegisteredEffects.size() << " registered effects");
        
        // Register all effects from the global registered effects list
        for (auto& effect : g_RegisteredEffects)
        {
            const std::string& id = effect.GetId().Id();
            g_EffectRegistry[id] = &effect;
            
            // Optional: Log first few effects for debugging (comment out after testing)
            // static int debugCount = 0;
            // if (debugCount++ < 10)
            // {
            //     LOG("[Effect Database] Registered: " << id);
            // }
        }
        
        LOG("[Effect Database] Registered " << g_EffectRegistry.size() << " effects");
    }
    
    RegisteredEffect* GetEffectById(const std::string& effectId)
    {
        auto it = g_EffectRegistry.find(effectId);
        if (it != g_EffectRegistry.end())
        {
            return it->second;
        }
        
        LOG("[Effect Database] Unknown effect ID: " << effectId);
        
        // Debug: List similar effect IDs if not found
        auto allIds = GetAllEffectIds();
        LOG("[Effect Database] Available effects: " << allIds.size() << " total");
        
        // Show first few for debugging
        for (int i = 0; i < 5 && i < allIds.size(); i++)
        {
            LOG("[Effect Database] - " << allIds[i]);
        }
        
        return nullptr;
    }
    
    std::vector<std::string> GetAllEffectIds()
    {
        std::vector<std::string> ids;
        ids.reserve(g_EffectRegistry.size());
        
        for (const auto& pair : g_EffectRegistry)
        {
            ids.push_back(pair.first);
        }
        
        return ids;
    }
    
    bool HasEffect(const std::string& effectId)
    {
        return g_EffectRegistry.find(effectId) != g_EffectRegistry.end();
    }
}