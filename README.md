Extract the files into the DestinyCore\src\server\game directory for compilation.

Create a lua_scripts folder in the same directory as DestinyCore (place your lua scripts inside), and add the following parameters to worldserver.conf:

###################################################################################################
# Eluna LUA ENGINE CONFIGURATION
###################################################################################################

Logger.eluna = 3,Console

Eluna.ScriptPath = "lua_scripts"

Eluna.Require.PathExtra = ""

Eluna.Require.CPathExtra = ""

###################################################################################################
