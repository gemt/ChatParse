--local BS = AceLibrary("Babble-Spell-2.2")

local ChatParse = CreateChatParse("FRAME");

ChatParse:RegisterEvent("CHAT_MSG_YELL");
ChatParse:RegisterEvent("CHAT_MSG_SAY");
--ChatParse:RegisterEvent("CHAT_MSG_WHISPER");
ChatParse:RegisterEvent("CHAT_MSG_CHANNEL");
ChatParse:RegisterEvent("CHAT_MSG_GUILD");
ChatParse:RegisterEvent("PLAYER_LOGIN");

ChatParse:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
ChatParse:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out

ChatParse:SetScript("OnEvent", function () ChatParse_EventHandler(event, arg1, arg2) end)

SLASH_ChatParse1 = '/chatparse'
SLASH_ChatParse2 = "/cp"
SlashCmdList['chatparse'] = ChatParse_Command;

function ChatParse_OnLoad()

end

function ChatParse_Command()
    _print("test");
end

local healingWepKey = {
"+55",
"55heal",
"healing power",
"55 heal",
}

local agiWep = {
"15 agi",
"15agi",
"weapon - agility",
}

local bracerHealing = {
"healing bracer",
"+24",
"+ 24",
"24 heal",
}

local bracerStr = {
"9 str",
"9str",
"superior str",
"bracer strength",

}

local glovesStr = {
"greater strength",
"7 str",
"7str",
"bracer strength"
}

local statsChest = {
"4 stats",
"greater stats",
}

--these will not be whispered
local blacklist = {
	"koboss" ,
	"Kampot",
	 "Allapologies",
	 "Drudruide",
	 "Vekkasha",
	"Oelberg",
	 "Daaman",
	 "Slochy",
	 "Lerf",
	"Yacopok",
	 "Tonoke",
	"Skorms",
	 "Kalzo",
	 "Mcdeep",
	"Bwiti", --idiot yell-selling stuff
	"Gebius",
	 "Jurary",
	 "Napan",
	 "Frbreakless", -- remove later, wanted 55 water
	 "Mojhesh", -- selling some other shit ""155 g""
	 "Troyanus", -- selling random shit wtf
	 "Tiqqer", --complained 
	 "Tesaija", -- weird advertising, triggered a lot
	 "Dreymon",
	 "Shuuk", --other enchanter that "cant do +55 healing"	
	 "Tupp",
	 "Prdelka", -- enchanter
	 "Bingtian", -- enchanter
	 "Destroy", --enchanter
	 "Mefire", --enchanter
}

--size of blacklist
local blacklist_size = 1;

local bailout_keywords = {
	"lfw",
	"enchanting",
	"wts",
	"service",
	"water",
	"lfg",
	"sfk", -- aproximately lvl 24 dungeon, triggering +24 healing enchant rip.
	"300",
}

local my_name = UnitName("player");

local function whispered(name)
	blacklist[blacklist_size] = name;
	blacklist_size = blacklist_size +1;
end

local queued_front = 1;
local queued_tail = 1;
local queue_size = 10
local queued_timestamps = {nil,nil,nil,nil,nil,nil,nil,nil,nil,nil}
local queued_messages = {nil,nil,nil,nil,nil,nil,nil,nil,nil,nil}
local queued_players = {nil,nil,nil,nil,nil,nil,nil,nil,nil,nil}
local advertise_wait_timeout = 3;

local function chatparse_advertise(name, message)
	whispered(name);
	
	--does insert work?
	--queued_timestamps.insert(GetTime());
	queued_timestamps[queued_front] = GetTime();
	queued_messages[queued_front] = message;
	queued_players[queued_front] = name;
	queued_front = queued_front + 1;
	
	if queued_front > queue_size then
		queued_front = 1;
	end
	
	--SendChatMessage(message,"WHISPER",nil, name);
end

local function create_msg(specific_msg)
	chatparse_advertise_msg_return =  "I can do "..specific_msg..". This is an automated response. If you were not looking for an enchanter you can ignore this message. Have a nice day!";
	return chatparse_advertise_msg_return;
end

--[[
function frame:OnEvent(event, arg1)
	if event == "ADDON_LOADED" and arg1 == "ChatParse" then
		-- Our saved variables are ready at this point. If there are none, both variables will set to nil.
		if HaveWeMetCount == nil then
			HaveWeMetCount = 0; -- This is the first time this addon is loaded; initialize the count to 0.
		end
		
		if HaveWeMetBool then
			print("Hello again, " .. UnitName("player") .. "!");
		else
			HaveWeMetCount = HaveWeMetCount + 1; -- It's a new character.
			print("Hi; what is your name?");
		end
		
	elseif event == "PLAYER_LOGOUT" then
		HaveWeMetBool = true; -- We've met; commit it to memory.
	end
end
	
frame:SetScript("OnEvent", frame.OnEvent);
SLASH_HAVEWEMET1 = "/hwm";
function SlashCmdList.HAVEWEMET(msg)
print("HaveWeMet has met " .. HaveWeMetCount .. " characters.");
--end
]]--


-- ChatParse:SetScript("OnUpdate", function(self, elapsed)

 function ChatParse_OnUpdate(self, elapsed)
	while queued_timestamps[queued_tail] do
	
		local elapsed = GetTime()  -  queued_timestamps[queued_tail];
		
		if elapsed >= advertise_wait_timeout then
			SendChatMessage(queued_messages[queued_tail],"WHISPER",nil, queued_players[queued_tail]);
			
			queued_timestamps[queued_tail] = nil;
			queued_messages[queued_tail] = nil;
			queued_players[queued_tail] = nil;
		else
			return;
		end
		
		queued_tail = queued_tail + 1;
		
		if queued_tail > queue_size then
			queued_tail = 1;
		end
	end
end)

function ChatParse_EventHandler(event, text, player)
	
	if event == "PLAYER_LOGIN" then
		while blacklist[blacklist_size] do
			blacklist_size = blacklist_size + 1;
		end
		return;
	end
	
	local x = 1;
	while blacklist[x] do
		if player == blacklist[x] then
			--_print("");
			_print("_"..player.."_ asked for an enchant, but is already in the blacklist.");
			--_print("");
			return;
		end
		x = x + 1;
	end
	
	if text ~= nil  and player ~= my_name  then
		local i = 1;
		textLower = string.lower(text);
		
		while bailout_keywords[i] do
			if string.find(textLower, bailout_keywords[i]) then
				return;
			end
			
			i = i + 1;
		end
		
		i = 1;
	
		local i = 1;
		--55 healing weapon
		while healingWepKey[i] do
			if string.find(textLower, healingWepKey[i]) then
				chatparse_advertise(player, create_msg("+55 healing, 25g fee"));
				return;
			end
			i = i + 1;
		end
		
		i = 1;
		--24 healing bracer
		while bracerHealing[i] do
			if string.find(textLower, bracerHealing[i]) then
				chatparse_advertise(player, create_msg("24 healing on bracer, 5g fee"));
				return;
			end
			i = i + 1;
		end
		
		i = 1;
		--15 agi weapon
		while agiWep[i] do
			if string.find(textLower, agiWep[i]) then
				chatparse_advertise(player, create_msg("+15 agility on weapon, 6g fee"));
				return;
			end
			i = i + 1;
		end
		
		i = 1;
		--9 str bracer
		while bracerStr[i] do
			if string.find(textLower, bracerStr[i]) then
				chatparse_advertise(player, create_msg("9 strength on bracer, 5g fee"));
				return;
			end
			i = i + 1;
		end
					
		i = 1;
		--4 stats on chest
		while statsChest[i] do
			if string.find(textLower, statsChest[i])
			then
				chatparse_advertise(player, create_msg("4 stats on chest, 6g fee"));
				return;
			end
			i = i + 1;
		end
		
		-- crusader
		if string.find(textLower, "crusader")
		then
			chatparse_advertise(player, create_msg("crusader, 7g fee"));
			return;
		end
				
		
	end
end


--Prints a message in the default chatframe.
--Only visible to you.
function _print( msg )
    if not DEFAULT_CHAT_FRAME then return end
    DEFAULT_CHAT_FRAME:AddMessage ( msg )
    ChatFrame3:AddMessage ( msg )
    ChatFrame4:AddMessage ( msg )
end
