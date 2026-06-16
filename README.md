Extract the files into the DestinyCore\src\server\game directory for compilation.

Create a lua_scripts folder in the same directory as DestinyCore (place your lua scripts inside), and add the following parameters to worldserver.conf:

###################################################################################################
# Eluna LUA ENGINE CONFIGURATION
###################################################################################################

Logger.eluna = 3,Console
#
#    Eluna.ScriptPath
#        Description: Path to the lua scripts folder.
#        Default:     "lua_scripts"
#
Eluna.ScriptPath = "lua_scripts"

#
#    Eluna.Require.PathExtra
#        Description: Extra paths to search for lua modules.
#        Default:     ""
#
Eluna.Require.PathExtra = ""

#    Eluna.Require.CPathExtra
#        Description: Extra paths to search for C/C++ modules.
#        Default:     ""
#
Eluna.Require.CPathExtra = ""

###################################################################################################
