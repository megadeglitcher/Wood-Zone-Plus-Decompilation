#ifndef DISCORDRPC_H
#define DISCORDRPC_H

void handleDiscordReady(const struct DiscordUser* request);
void handleDiscordDisconnected(int errorCode, const char* message);
void handleDiscordError(int errorCode, const char* message);
void handleDiscordJoinGame(const char* joinSecret);
void handleDiscordSpectateGame(const char* spectateSecret);
void handleDiscordJoinRequest(const struct DiscordUser* request);
void SetDiscordAppID(const char* data);
void DiscordRPCState(const char* data);
void DiscordRPCDetails(const char* data);
void DiscordRPCSmallImageKey(const char* data);
void DiscordRPCLargeImageKey(const char* data);
void DiscordRPCSmallImageText(const char* data);
void DiscordRPCLargeImageText(const char* data);
void UpdateRPCTimer(int time);
void UpdateRPCParty(int size, int max);

#endif // !DISCORDRPC_H