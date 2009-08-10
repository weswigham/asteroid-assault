--Yea, I'll admit to getting the base chatcmd system code from GMS. But hey, why fix what ain't broken? This system works, and it works well.
/*---------------------------------------------------------
  ChatCommand system
---------------------------------------------------------*/
ChatCommands = {}
AllCmds = {}
function RegisterChatCmd(cmd,tbl)
         ChatCommands[cmd] = tbl
		 print("ChatCmds Registered!")
		 table.insert(AllCmds,cmd)
end

function RunChatCmd(ply,...)
	if #arg > 0 and ChatCommands[string.lower(arg[1])] != nil then --no longer case sensitive
		local cmd = string.lower(arg[1])
		table.remove(arg,1)
		ChatCommands[cmd]:Run( ply, unpack(arg) )
		return ""
	end
end

function CheckForChatCmd(ply,text,all)
	local text2 = string.Explode(" ", text)
	RunChatCmd( ply, unpack(text2) )
	--return text --no need to return anything at all, don't want to block it or anything.
end

hook.Add( "PlayerSay", "AASayHook", CheckForChatCmd )

/*---------------------------------------------------------
  Help
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!help"
CHATCMD.Desc = "- lists chat cmds"
function CHATCMD:Run( ply, ... )
	if arg[1] and ChatCommands[arg[1]] then
		ply:PrintMessage( HUD_PRINTTALK, arg[1]..":\n Usage: "..(ChatCommands[arg[1]].Usage or "No arguments").."\n Description: "..(ChatCommands[arg[1]].Desc or "No Description") )
	else
		ply:PrintMessage( HUD_PRINTTALK, "Chat Commands: "..table.concat(AllCmds, ", ") )
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
  Help
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!submitbug"
CHATCMD.Desc = "- Submit a bug to the server"
CHATCMD.Usage = "(description of bug)"
function CHATCMD:Run( ply, ... )
	if arg[1] then
		
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
  RunLua
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!runlua"
CHATCMD.Desc = "- Runs Lua -Admin Only"
function CHATCMD:Run( ply, ... )
local luaStr = table.concat( arg, " " )
	if ply:IsAdmin() then
		local err = RunString( luaStr )
		if err then
			ply:ChatPrint("Running Lua has failed because of "..err)
		else
			ply:ChatPrint("Command run sucessfully!")
		end
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)


/*---------------------------------------------------------
  Giveme
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!giveme"
CHATCMD.Desc = "- gives self money -Admin Only"
function CHATCMD:Run( ply, ... )
	if ply:IsAdmin() then
		ply:SetNWInt("money", ply:GetNWInt("money")+tonumber(arg[1]))
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
  Give
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!give"
CHATCMD.Desc = "- gives specified user (or group of users with common name portions) money -Admin Only"
CHATCMD.Usage = "(*,username)"
function CHATCMD:Run( ply, ... )
	if ply:IsAdmin() then
		local found = false
		if tonumber(arg[2]) then
			for k,v in pairs(player.GetAll()) do
				if arg[1] == "*" then
					v:SetNWInt("money", v:GetNWInt("money")+tonumber(arg[2]))
					found = true
				elseif string.find(string.lower(v:GetName()),string.lower(arg[1])) != nil then
					v:SetNWInt("money", v:GetNWInt("money")+tonumber(arg[2]))
					found = true
				end
				if found != true then
					ply:PrintMessage( HUD_PRINTTALK, "Player "..arg[1].." was not found." )
				end
			end
		end
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
 Skipcurrentphase
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!skip"
CHATCMD.Desc = "- skips this phase - Admin Only"
function CHATCMD:Run( ply, ... )
	if ply:IsAdmin() then
		if GetGlobalInt("buildmode") > 1 then
			SetGlobalInt("buildmode",1)
		elseif GetGlobalInt("armeggadon") > 1 then
			SetGlobalInt("armeggadon",1)
		end
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
 Give Perk
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!perkme"
CHATCMD.Desc = "- adds perk - Admin Only"
CHATCMD.Usage = "(Perk Name)"
function CHATCMD:Run( ply, ... )
	if ply:IsAdmin() then
		local perk = table.concat(arg, " ")
		GivePerk(ply,perk)
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
 Give Exp
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!plusexp"
CHATCMD.Desc = "- adds exp"
CHATCMD.Usage = "(number)"
function CHATCMD:Run( ply, ... )
	if ply:IsAdmin() then
		ply:SetNWInt("exp", ply:GetNWInt("exp")+arg[1])
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
Stuck
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!stuck"
CHATCMD.Desc = "- frees you"
function CHATCMD:Run( ply, ... )
	ply:SetPos(ply:GetPos()+Vector(0,0,10))
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
Save
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!save"
CHATCMD.Desc = "- saves your data"
function CHATCMD:Run( ply, ... )
	GAMEMODE:Save(ply)
	ply:PrintMessage( HUD_PRINTTALK, "Your experience has been saved.")
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
Map Change
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!votemapchange"
CHATCMD.Desc = "- Starts a vote to change the map"
function CHATCMD:Run( ply, ... )
	if not GAMEMODE.ActiveVoting then
		local OnPass = function() 
			PrintMessage( HUD_PRINTTALK,"The vote to change the map has passed!")
			game.ConsoleCommand( "changelevel " .. GAMEMODE:NextMap() .. "\n" )
		end
		local OnFail = function() 
			PrintMessage( HUD_PRINTTALK,"The vote to change the map has failed!")
		end
		GAMEMODE:SetupVote("Change the map to "..GAMEMODE:NextMap(), 40, 0.67, OnPass, OnFail) --Name, Duration, OnPass, OnFail
	else
		ply:PrintMessage( HUD_PRINTTALK, "A vote is already in progress!")
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
Clean Up Map
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!votecleanup"
CHATCMD.Desc = "- Starts a vote to clean the map (will happen on next phase change, cannot be canceled once passed)"
function CHATCMD:Run( ply, ... )
	if not GAMEMODE.ActiveVoting then
		if not self.GunnaCleanUpNow then
			local OnPass = function() 
				PrintMessage( HUD_PRINTTALK,"The vote to clean up the map has passed!")
				GAMEMODE:QueCleanup()
			end
			local OnFail = function() 
				PrintMessage( HUD_PRINTTALK,"The vote to clean up the map has failed!")
			end
			GAMEMODE:SetupVote("Clean Up The Map", 40, 1, OnPass, OnFail) --Name, Duration, OnPass, OnFail
		else
			ply:PrintMessage( HUD_PRINTTALK, "A map clean-up is already scheduled. It will occur the next time you switch into build phase.")
		end
	else
		ply:PrintMessage( HUD_PRINTTALK, "A vote is already in progress!")
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
Skip build phase
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!voteskip"
CHATCMD.Desc = "- Starts a vote to skip the build phase"
function CHATCMD:Run( ply, ... )
	if not GAMEMODE.ActiveVoting then
	if GetGlobalInt("buildmode") > 1 then
		local OnPass = function() 
			PrintMessage( HUD_PRINTTALK,"The vote to skip the build phase has passed!")
			SetGlobalInt("buildmode",1)
		end
		local OnFail = function() 
			PrintMessage( HUD_PRINTTALK,"The vote to skip the build phase has failed!")
		end
		GAMEMODE:SetupVote("Skipping Build Phase", math.Clamp(20,0,(GetGlobalInt("buildmode")-1)), 1, OnPass, OnFail) --Name, Duration, OnPass, OnFail
	else
		ply:PrintMessage( HUD_PRINTTALK, "You're not in build mode!")
	end
	else
		ply:PrintMessage( HUD_PRINTTALK, "A vote is already in progress!")
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
"Yes!"
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "yes"
CHATCMD.Desc = "- A yes vote."
function CHATCMD:Run( ply, ... )
	if ply.HasVoted then return end
	if GAMEMODE.ActiveVoting == true then
		ply:PrintMessage( HUD_PRINTTALK, "Your yes vote has been recorded.")
		ply.HasVoted = true
		GAMEMODE.CurrentVote.Yes = GAMEMODE.CurrentVote.Yes + 1
		PrintMessage( HUD_PRINTTALK, "The Vote For "..GAMEMODE.CurrentVote.Name.." is now at "..GAMEMODE.CurrentVote.Yes.." with yes to "..GAMEMODE.CurrentVote.No.." with no." )
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
"No!"
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "no"
CHATCMD.Desc = "- A no vote."
function CHATCMD:Run( ply, ... )
	if ply.HasVoted then return end
	if GAMEMODE.ActiveVoting == true then
		ply:PrintMessage( HUD_PRINTTALK, "Your no vote has been recorded.")
		ply.HasVoted = true
		GAMEMODE.CurrentVote.No = GAMEMODE.CurrentVote.No + 1
		PrintMessage( HUD_PRINTTALK, "The Vote For "..GAMEMODE.CurrentVote.Name.." is now at "..GAMEMODE.CurrentVote.Yes.." with yes to "..GAMEMODE.CurrentVote.No.." with no." )
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
"Yes!"
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "y"
CHATCMD.Desc = "- A yes vote."
function CHATCMD:Run( ply, ... )
	if ply.HasVoted then return end
	if GAMEMODE.ActiveVoting == true then
		ply:PrintMessage( HUD_PRINTTALK, "Your yes vote has been recorded.")
		ply.HasVoted = true
		GAMEMODE.CurrentVote.Yes = GAMEMODE.CurrentVote.Yes + 1
		PrintMessage( HUD_PRINTTALK, "The Vote For "..GAMEMODE.CurrentVote.Name.." is now at "..GAMEMODE.CurrentVote.Yes.." with yes to "..GAMEMODE.CurrentVote.No.." with no." )
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
"No!"
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "n"
CHATCMD.Desc = "- A no vote."
function CHATCMD:Run( ply, ... )
	if ply.HasVoted then return end
	if GAMEMODE.ActiveVoting == true then
		ply:PrintMessage( HUD_PRINTTALK, "Your no vote has been recorded.")
		ply.HasVoted = true
		GAMEMODE.CurrentVote.No = GAMEMODE.CurrentVote.No + 1
		PrintMessage( HUD_PRINTTALK, "The Vote For "..GAMEMODE.CurrentVote.Name.." is now at "..GAMEMODE.CurrentVote.Yes.." with yes to "..GAMEMODE.CurrentVote.No.." with no." )
	end
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)