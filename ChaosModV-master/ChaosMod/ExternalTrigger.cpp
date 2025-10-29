#include "stdafx.h"
#include "ExternalTrigger.h"
#include "EffectDatabase.h"
#include "Components/EffectDispatcher.h"
#include "Components/Component.h"
#include "Util/Logging.h"
#include <nlohmann/json.hpp>

using json = nlohmann::json;

namespace ExternalTrigger
{
    TriggerServer::TriggerServer(int port)
        : m_Port(port), m_Running(false)
    {
    }

    TriggerServer::~TriggerServer()
    {
        Stop();
    }

    void TriggerServer::AddCORSHeaders(httplib::Response& res)
    {
        res.set_header("Access-Control-Allow-Origin", "*");
        res.set_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        res.set_header("Access-Control-Allow-Headers", "Content-Type, Accept");
        res.set_header("Access-Control-Max-Age", "86400");
    }

    void TriggerServer::SetupRoutes()
    {
        // CORS preflight
        m_Server.Options("/.*", [this](const httplib::Request& req, httplib::Response& res) 
        {
            AddCORSHeaders(res);
            res.status = 204;
        });

        // Ping endpoint
        m_Server.Get("/ping", [this](const httplib::Request& req, httplib::Response& res) 
        {
            AddCORSHeaders(res);
            res.set_content("pong", "text/plain");
            res.status = 200;
            
            LOG("[External Trigger] Ping received");
        });

        // Main trigger endpoint
        m_Server.Post("/trigger", [this](const httplib::Request& req, httplib::Response& res) 
        {
            AddCORSHeaders(res);
            
            try
            {
                auto json_body = json::parse(req.body);
                
                std::string effectId = json_body["effectId"].get<std::string>();
                int duration = json_body.value("duration", 0);
                
                LOG("[External Trigger] Received: " << effectId << " (duration: " << duration << "ms)");
                
                if (m_OnEffectReceived)
                {
                    m_OnEffectReceived(effectId, duration);
                    res.set_content("{\"status\":\"success\"}", "application/json");
                    res.status = 200;
                }
                else
                {
                    LOG("[External Trigger] ERROR: No effect callback registered");
                    res.set_content("{\"status\":\"error\",\"message\":\"No callback\"}", "application/json");
                    res.status = 500;
                }
            }
            catch (const json::parse_error& e)
            {
                LOG("[External Trigger] JSON parse error: " << e.what());
                res.set_content("{\"status\":\"error\",\"message\":\"Invalid JSON\"}", "application/json");
                res.status = 400;
            }
            catch (const std::exception& e)
            {
                LOG("[External Trigger] Error: " << e.what());
                res.set_content("{\"status\":\"error\",\"message\":\"Internal error\"}", "application/json");
                res.status = 500;
            }
        });

        // Status endpoint
        m_Server.Get("/status", [this](const httplib::Request& req, httplib::Response& res) 
        {
            AddCORSHeaders(res);
            
            json status_json =
            {
                {"running", m_Running.load()},
                {"port", m_Port},
                {"version", "1.0.0"}
            };
            
            res.set_content(status_json.dump(), "application/json");
            res.status = 200;
        });
    }

    void TriggerServer::Start()
    {
        if (m_Running)
        {
            LOG("[External Trigger] Already running");
            return;
        }

        m_Running = true;
        SetupRoutes();

        m_ServerThread = std::thread([this]() 
        {
            LOG("[External Trigger] Starting HTTP server on 0.0.0.0:" << m_Port);
            
            if (!m_Server.listen("0.0.0.0", m_Port))
            {
                LOG("[External Trigger] ERROR: Failed to start server on port " << m_Port);
                m_Running = false;
            }
        });

        std::this_thread::sleep_for(std::chrono::milliseconds(500));

        if (m_Running)
        {
            LOG("[External Trigger] HTTP server started successfully");
        }
    }

    void TriggerServer::Stop()
    {
        if (!m_Running)
            return;

        LOG("[External Trigger] Stopping HTTP server...");
        
        m_Running = false;
        m_Server.stop();
        
        if (m_ServerThread.joinable())
        {
            m_ServerThread.join();
        }

        LOG("[External Trigger] HTTP server stopped");
    }

    void TriggerServer::SetEffectCallback(std::function<void(const std::string&, int)> callback)
    {
        m_OnEffectReceived = callback;
        LOG("[External Trigger] Effect callback registered");
    }

    void Initialize(int port)
    {
        if (g_TriggerServer)
        {
            LOG("[External Trigger] Already initialized");
            return;
        }

        LOG("[External Trigger] Initializing...");

        g_TriggerServer = new TriggerServer(port);
        
        g_TriggerServer->SetEffectCallback([](const std::string& effectId, int duration) 
        {
            LOG("[External Trigger] Looking up effect: \"" << effectId << "\"");
            
            auto effect = EffectDatabase::GetEffectById(effectId);
            
            if (effect)
            {
                LOG("[External Trigger] Found effect: " << effect->GetId().Id());
                LOG("[External Trigger] Dispatching effect...");
                
                // Check if EffectDispatcher component exists and dispatch the effect
                if (ComponentExists<EffectDispatcher>())
                {
                    EffectIdentifier effectIdentifier(effectId);
                    GetComponent<EffectDispatcher>()->DispatchEffect(effectIdentifier);
                    LOG("[External Trigger] Effect dispatched successfully: " << effectId);
                }
                else
                {
                    LOG("[External Trigger] ERROR: EffectDispatcher component not available");
                }
            }
            else
            {
                LOG("[External Trigger] ERROR: Unknown effect ID: " << effectId);
            }
        });

        g_TriggerServer->Start();
        
        LOG("[External Trigger] Initialization complete");
    }

    void Shutdown()
    {
        if (g_TriggerServer)
        {
            g_TriggerServer->Stop();
            delete g_TriggerServer;
            g_TriggerServer = nullptr;
            
            LOG("[External Trigger] Shutdown complete");
        }
    }
}
