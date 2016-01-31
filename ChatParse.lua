
local Frame = CreateFrame("FRAME");
Frame:RegisterEvent("CHAT_MSG_YELL");
Frame:RegisterEvent("CHAT_MSG_SAY");
Frame:RegisterEvent("CHAT_MSG_WHISPER");
Frame:RegisterEvent("CHAT_MSG_CHANNEL");
Frame:RegisterEvent("CHAT_MSG_GUILD");
Frame:SetScript("OnEvent", function () EventHandler(event, arg1, arg2) end)


local keyword_count = 7;
local KeyWords = {
"+55",
"55healing",
"healing power",
"55 healing",
"+55healing",
}
local my_name = UnitName("player");
function EventHandler(event, text, player)
	if text ~= nil and player ~= my_name then
		textLower = string.lower(text);
		local i = 1;
		while KeyWords[i] do
			if string.find(textLower, KeyWords[i]) then
				SendChatMessage(player..": "..text, "WHISPER", nil, my_name);
				SendChatMessage("I can do +55 healing, if you were asking for that. This is an automated response and if you were not looking for a +55 healing enchanter, ignore this message. Have a good day!","WHISPER",nil, player);
				break;
			end
			i = i + 1;
		end
	end
end


--Prints a message in the default chatframe.
--Only visible to you.
function _print( msg )
    if not DEFAULT_CHAT_FRAME then return end
    DEFAULT_CHAT_FRAME:AddMessage ( msg )
end
