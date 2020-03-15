#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <multicolors>
#include <freak_fortress_2>

ConVar g_cvarDelay;
bool g_bKillEnabled = false;
bool g_bIsRPSLoser[MAXPLAYERS+1];
Handle SuicideTimer = INVALID_HANDLE;

public Plugin:myinfo = {
    name = "No Suicide in FF2",
    author = "WEEGEE",
    description = "Blocking suicide commands + additional features for FF2 gamemode",
    version = "1.0",
    url = "https://steamcommunity.com/groups/reachhl2"
}

public void OnPluginStart() 
{
    g_cvarDelay = CreateConVar("sm_nosuicide_delay", "90.0","Interval in second before enabling boss suicide in each round", FCVAR_NONE, true, 1.0, true, 999.0);
    HookEvent("arena_round_start", Event_ArenaStart);
    HookEvent("teamplay_round_win", Event_RoundWin);
    HookEvent("rps_taunt_event", Event_RPS);

    // Intercept all the common suicide commands
    AddCommandListener(NoKillCmd, "kill");
    AddCommandListener(NoKillCmd, "explode");
    AddCommandListener(NoKillCmd, "hurtme");
}

public void Event_ArenaStart(Event event, const char[] name, bool dontBroadcast)
{
    g_bKillEnabled = false;
    PrintToServer("[SM] Boss Suicide Disabled")

    if(SuicideTimer != INVALID_HANDLE)
    {
        KillTimer(SuicideTimer);
        SuicideTimer = INVALID_HANDLE;
    }
    SuicideTimer = CreateTimer(g_cvarDelay.FloatValue, EnableKill);
    
    for(int i = 0; i < sizeof(g_bIsRPSLoser); i++)
    {
        g_bIsRPSLoser[i] = false;
    }
}

public void Event_RoundWin(Event event, const char[] name, bool dontBroadcast)
{
    g_bKillEnabled = true;
    PrintToServer("[SM] Boss Suicide Enabled")
    if(SuicideTimer != INVALID_HANDLE)
    {
        KillTimer(SuicideTimer);
        SuicideTimer = INVALID_HANDLE;
    }
}

public void Event_RPS(Event event, const char[] name, bool dontBroadcast)
{
    int winner = event.GetInt("winner");
    int loser = event.GetInt("loser");
    g_bIsRPSLoser[loser] = true;
    g_bIsRPSLoser[winner] = false;
}

public Action EnableKill(Handle timer)
{
    SuicideTimer = INVALID_HANDLE;
    g_bKillEnabled = true;
    PrintToServer("[SM] Boss Suicide Enabled")
    for(int i = 1; i <= MaxClients ; i++)
    {
        // Notify the boss they are able to suicide now
        if(IsValidEdict(i) && !IsFakeClient(i) && IsPlayerAlive(i) && FF2_GetBossIndex(i) >= 0)
        {
            CPrintToChat(i, "{yellow}[瑞曲星] {default}回合開始已經超過%d秒。\n如果因為{cyan}正常原因(卡死等等){default}而無法繼續你可以選擇{yellow}自殺結束回合{default}。", g_cvarDelay.IntValue);
            CPrintToChat(i, "{red}[注意] {default}因其他不合理原因(如不想做Boss)自殺是{yellow}違反伺服器規則{default}，\n違者可被{red}封禁{default}。");
        }
    }
}

public Action NoKillCmd(int client, const char[] command, int args)
{
    PreventHumanKill(client);
    return Plugin_Handled;
}

public void PreventHumanKill(int client)
{
    if(!g_bKillEnabled)
    {
        if(!TF2_IsPlayerInCondition(client, TFCond_Dazed) && IsPlayerAlive(client))
        {
            TF2_StunPlayer(client, 5.0, 0.0, TF_STUNFLAGS_NORMALBONK);
            CPrintToChatAll("{yellow}%N{default}條撚樣想自殺喎，正一On9仔", client); // Tell everyone someone wants to suicide
        }
    }
    else
    {
        //Only allows Boss player to do so (if they didn't just lose an RPS taunt)
        if(FF2_GetBossIndex(client) >= 0 && IsPlayerAlive(client) && !g_bIsRPSLoser[client]) //Prevent the player to suicide after losing an RPS taunt even the timer has passed
        {
            ForcePlayerSuicide(client);
            CPrintToChatAll("{yellow}[瑞曲星] {default}玩家{cyan}%N{default}在成為Boss時主動自殺，\n如你認為該玩家自殺違規{yellow}請向Admin舉報。", client) //Notify everyone the boss has suicided
        }
        else
        {
            if(!TF2_IsPlayerInCondition(client, TFCond_Dazed) && IsPlayerAlive(client))
            {
                TF2_StunPlayer(client, 5.0, 0.0, TF_STUNFLAGS_NORMALBONK);
                if(g_bIsRPSLoser[client] && FF2_GetBossIndex(client) >= 0)
                {
                    CPrintToChatAll("{yellow}%N{default}條撚樣輸撚左包剪揼仲想自殺喎，正一On9仔", client); //Shame the boss if it wants to suicide after losing an RPS taunt
                }
                else
                {
                    CPrintToChatAll("{yellow}%N{default}條撚樣想自殺喎，正一On9仔", client);
                }
            }
        }
    }
}