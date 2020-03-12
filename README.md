# No Suicide in FF2

#### A plugin that blocks players from entering commands to suicide, with a few additional features made explicitly for Freak Fortress 2 servers.

Please note that I create this plugin for my server based in Hong Kong, so all the PrintToChat functions contain Cantonese, you should enter your phrases for your server in those functions and compile for yourself.

##What this plugin does:
- Prevent non-boss players suicide by entering command 'kill', 'explode', and 'hurtme'
- Stun players for 5 seconds if they do so
- Allow the boss player to suicide after some time following round start (For a situation like getting stuck in the map)
- But also disable suicide for Boss players if they lose in an RPS Taunt even if the timer has passed (Stun for 5 seconds if they do so)

##ConVars
```
sm_nosuicide_delay <seconds> <Interval in second before enabling boss suicide in each round>
```
