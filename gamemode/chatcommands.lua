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
	if #arg > 0 and ChatCommands[arg[1]] != nil then
		local cmd = arg[1]
		table.remove(arg,1)
		ChatCommands[cmd]:Run( ply, unpack(arg) )
		return ""
	end
end

function CheckForChatCmd(ply,text,all)
	local text2 = string.Explode(" ", text)
	RunChatCmd( ply, unpack(text2) )
	return text
end

hook.Add( "PlayerSay", "ISaid", CheckForChatCmd )

/*---------------------------------------------------------
  Help
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!help"
CHATCMD.Desc = "- lists chat cmds"
function CHATCMD:Run( ply, ... )
	ply:PrintMessage( HUD_PRINTTALK, "Chat Commands: "..table.concat(AllCmds, ", ") )
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)

/*---------------------------------------------------------
  RunLua
---------------------------------------------------------*/
local CHATCMD = {}

CHATCMD.Command = "!runlua"
CHATCMD.Desc = "- Runs Lua"
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
CHATCMD.Desc = "- gives self money"
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
CHATCMD.Desc = "- gives specified user (or group of users with common name portions) money"
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
CHATCMD.Desc = "- skips this phase"
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
CHATCMD.Desc = "- adds perk"
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
CHATCMD.Desc = "- saves you"
function CHATCMD:Run( ply, ... )
	GAMEMODE:Save(ply)
	ply:PrintMessage( HUD_PRINTTALK, "Your experience has been saved.")
end
RegisterChatCmd(CHATCMD.Command,CHATCMD)