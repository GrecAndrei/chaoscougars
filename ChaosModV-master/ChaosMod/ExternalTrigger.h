#pragma once

#include <httplib.h>
#include <thread>
#include <functional>
#include <string>
#include <atomic>

namespace ExternalTrigger
{
    class TriggerServer
    {
    private:
        httplib::Server m_Server;
        std::thread m_ServerThread;
        std::function<void(const std::string&, int)> m_OnEffectReceived;
        int m_Port;
        std::atomic<bool> m_Running;
        
        void SetupRoutes();
        void AddCORSHeaders(httplib::Response& res);

    public:
        TriggerServer(int port = 8080);
        ~TriggerServer();

        void Start();
        void Stop();
        void SetEffectCallback(std::function<void(const std::string&, int)> callback);
        bool IsRunning() const { return m_Running; }
    };

    inline TriggerServer* g_TriggerServer = nullptr;

    void Initialize(int port = 8080);
    void Shutdown();
}