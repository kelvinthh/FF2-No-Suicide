#include <sourcemod>
#include <tf2>
#include <multicolors>
#include <freak_fortress_2>

bool g_bIsRoundActive;

public Plugin:myinfo = {
    name = "No Suicide",
    author = "WEEGEE",
    description = "Prevent players from killing themselves via console commands",
    version = "1.0",
    url = "https://steamcommunity.com/groups/reachhl2"
}

public void OnPluginStart() 
{
    RegConsoleCmd("kill", Cmd_Kill);
    RegConsoleCmd("explode", Cmd_Explode);
    HookEvent("rps_taunt_event", Event_RPS);
    HookEvent("teamplay_round_active", Event_RoundActive);
    HookEvent("teamplay_round_win", Event_RoundWin);
}

public Action Cmd_Kill(int client, int args)
{

}

public Action Cmd_Explode(int client, int args)
{
    
}

public void Event_RPS(Event event, const char[] name, bool dontBroadcast)
{

}

public void Event_RoundActive(Event event, const char[] name, bool dontBroadcast)
{
    g_bIsRoundActive = true;
}

public void Event_RoundWin(Event event, const char[] name, bool dontBroadcast)
{
    g_bIsRoundActive = false;
}