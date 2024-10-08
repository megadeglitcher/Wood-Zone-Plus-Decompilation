#include <iostream> 
#include <sstream>
#include <string>
#include "RetroEngine.hpp"
#include <discord_rpc.h>
#include <discord_register.h>

DiscordRichPresence discordPresence;

void LogDiscordPresence()
{
    std::stringstream ss;

    ss << "DiscordRichPresence Data:\n";
    ss << "State: " << (discordPresence.state ? discordPresence.state : "null") << "\n";
    ss << "Details: " << (discordPresence.details ? discordPresence.details : "null") << "\n";
    ss << "Start Timestamp: " << discordPresence.startTimestamp << "\n";
    ss << "End Timestamp: " << discordPresence.endTimestamp << "\n";
    ss << "Large Image Key: " << (discordPresence.largeImageKey ? discordPresence.largeImageKey : "null") << "\n";
    ss << "Large Image Text: " << (discordPresence.largeImageText ? discordPresence.largeImageText : "null") << "\n";
    ss << "Small Image Key: " << (discordPresence.smallImageKey ? discordPresence.smallImageKey : "null") << "\n";
    ss << "Small Image Text: " << (discordPresence.smallImageText ? discordPresence.smallImageText : "null") << "\n";
    ss << "Party Size: " << discordPresence.partySize << "\n";
    ss << "Party Max: " << discordPresence.partyMax << "\n";
    ss << "Join Secret: " << (discordPresence.joinSecret ? discordPresence.joinSecret : "null") << "\n";
    ss << "Spectate Secret: " << (discordPresence.spectateSecret ? discordPresence.spectateSecret : "null") << "\n";

    printLog(ss.str().c_str());
}

void handleDiscordReady(const struct DiscordUser* request) {
    printLog("ready", request->username, request->userId);
}

void handleDiscordDisconnected(int errorCode, const char* message) {
    printLog("disconnected", errorCode, message);
}

void handleDiscordError(int errorCode, const char* message) {
    printLog("error", errorCode, message);
}

void handleDiscordJoinGame(const char* joinSecret) {
    printLog("joined", joinSecret);
}

void handleDiscordSpectateGame(const char* spectateSecret) {
    printLog("spectating", spectateSecret);
}

void handleDiscordJoinRequest(const struct DiscordUser* request) {
    printLog("user request join", request->username, request->userId);
}

void SetDiscordAppID(const char* data)
{
    DiscordEventHandlers handlers;
    memset(&handlers, 0, sizeof(handlers));

    handlers.ready = handleDiscordReady;
    handlers.errored = handleDiscordError;
    handlers.disconnected = handleDiscordDisconnected;

    Discord_Initialize(data, &handlers, 0, NULL);

    discordPresence.state = "";
    discordPresence.details = "";
    discordPresence.largeImageKey = "";
    discordPresence.smallImageKey = "";

    Discord_UpdatePresence(&discordPresence);
}

void DiscordRPCState(const char* data)
{
    discordPresence.state = strdup(data);
    Discord_UpdatePresence(&discordPresence);

}

void DiscordRPCDetails(const char* data)
{
    discordPresence.details = strdup(data);
    Discord_UpdatePresence(&discordPresence);

}

void DiscordRPCSmallImageKey(const char* data)
{
    discordPresence.smallImageKey = strdup(data);
    Discord_UpdatePresence(&discordPresence);

}

void DiscordRPCLargeImageKey(const char* data)
{
    discordPresence.largeImageKey = strdup(data);
    Discord_UpdatePresence(&discordPresence);

}

void DiscordRPCSmallImageText(const char* data)
{
    discordPresence.smallImageText = strdup(data);
    Discord_UpdatePresence(&discordPresence);

}

void DiscordRPCLargeImageText(const char* data)
{
    discordPresence.largeImageText = strdup(data);
    Discord_UpdatePresence(&discordPresence);

}

void UpdateRPCTimer(int time)
{
    int64_t trueTimer = static_cast<int64_t>(time);
    discordPresence.startTimestamp = trueTimer;
    Discord_UpdatePresence(&discordPresence);
}

void UpdateRPCParty(int size, int max)
{
    discordPresence.partySize = size;
    discordPresence.partyMax = max;
    Discord_UpdatePresence(&discordPresence);
}