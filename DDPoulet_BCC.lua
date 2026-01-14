-- Doigt de Poulet (BCC) - v4.0

local ADDON_NAME = ...
local BASE = "Interface\\AddOns\\" .. ADDON_NAME .. "\\data\\"

-- DB = identique à SavedVariables du .toc
DDPouletDB_BCC = DDPouletDB_BCC or {
  showImage = true,
  playSound = true,
  showWelcomeWindow = true,
  welcomeShown = false,
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_SAY")
frame:RegisterEvent("CHAT_MSG_YELL")
frame:RegisterEvent("CHAT_MSG_GUILD")
frame:RegisterEvent("CHAT_MSG_PARTY")
frame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
frame:RegisterEvent("CHAT_MSG_RAID")
frame:RegisterEvent("CHAT_MSG_RAID_LEADER")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("CHAT_MSG_CHANNEL")
frame:RegisterEvent("UNIT_HEALTH")

local imagePath = BASE .. "pics\\DDPoulet.tga"

local soundPaths1 = {
  BASE .. "sounds\\DDPoulet.mp3",
  BASE .. "sounds\\DDPoulet2.mp3",
  BASE .. "sounds\\DDPoulet3.mp3",
  BASE .. "sounds\\DDPoulet4.mp3",
}

local soundPath2         = BASE .. "sounds\\ChickenDeathA.ogg"
local soundPathMoula     = BASE .. "sounds\\heymoula.mp3"
local soundPathHakaza    = BASE .. "sounds\\hakaza_fourmis.mp3"
local soundPathResistar1 = BASE .. "sounds\\resistar1.mp3"
local soundPathResistar2 = BASE .. "sounds\\resistar_aidezmoi.mp3"
local soundPathIka       = BASE .. "sounds\\tudekaliss.mp3"
local soundPathDaeler    = BASE .. "sounds\\daelerback.mp3"
local soundPathBrutalite = BASE .. "sounds\\brutalite.mp3"

local lastPlayedAt = {}
local function Throttle(key, cooldown)
  cooldown = cooldown or 1.2
  local now = GetTime()
  if lastPlayedAt[key] and (now - lastPlayedAt[key]) < cooldown then
    return true
  end
  lastPlayedAt[key] = now
  return false
end

local function DDP_PlaySound(path, channel)
  if not path or path == "" then return end
  channel = channel or "Master"
  local ok = pcall(PlaySoundFile, path, channel)
  if not ok then
    pcall(PlaySoundFile, path)
  end
end

local function PlayRandomChickenSound()
  if #soundPaths1 == 0 then return end
  DDP_PlaySound(soundPaths1[math.random(1, #soundPaths1)], "Master")
end

frame.texture = frame:CreateTexture(nil, "BACKGROUND")
frame.texture:SetTexture(imagePath)
frame.texture:SetSize(200, 200)
frame.texture:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame.texture:Hide()

local function ShowImageAndSound()
  if Throttle("main", 1.5) then return end

  if DDPouletDB_BCC.showImage then
    frame.texture:Show()
    C_Timer.After(3, function()
      if frame and frame.texture then frame.texture:Hide() end
    end)
  end

  if DDPouletDB_BCC.playSound then
    PlayRandomChickenSound()
    C_Timer.After(2, function()
      DDP_PlaySound(soundPath2, "Master")
    end)
  end
end

local isBelow20Percent = false

local function NormalizeMessage(msg)
  msg = tostring(msg or ""):lower()
  msg = msg:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
  return msg
end

local function OnEvent(self, event, ...)
  if event == "UNIT_HEALTH" then
    local unit = ...
    if unit ~= "player" then return end
    local health = UnitHealth("player")
    local maxHealth = UnitHealthMax("player")
    if not maxHealth or maxHealth == 0 then return end

    local hp = (health / maxHealth) * 100
    if hp <= 20 and not isBelow20Percent then
      if not Throttle("hp20", 10) then
        DDP_PlaySound(soundPathResistar2, "Master")
      end
      isBelow20Percent = true
    elseif hp > 20 and isBelow20Percent then
      isBelow20Percent = false
    end
    return
  end

  local message = NormalizeMessage((...))

  if message:find("doigt de poulet", 1, true) then
    ShowImageAndSound()

  elseif message:find("moula", 1, true) then
    if DDPouletDB_BCC.playSound and not Throttle("moula", 2.0) then
      DDP_PlaySound(soundPathMoula, "Master")
    end

  elseif message:find("hakaza fourmis", 1, true) then
    if DDPouletDB_BCC.playSound and not Throttle("hakaza", 2.0) then
      DDP_PlaySound(soundPathHakaza, "Master")
    end

  elseif message:find("putain", 1, true) then
    if DDPouletDB_BCC.playSound and not Throttle("putain", 2.0) then
      DDP_PlaySound(soundPathResistar1, "Master")
    end

  elseif message:find("ikalyss", 1, true) then
    if DDPouletDB_BCC.playSound and not Throttle("ika", 2.0) then
      DDP_PlaySound(soundPathIka, "Master")
    end

  elseif message:find("brutalite", 1, true) then
    if DDPouletDB_BCC.playSound and not Throttle("brutalite", 2.0) then
      DDP_PlaySound(soundPathBrutalite, "Master")
    end

  elseif message:find("daeler", 1, true) then
    if DDPouletDB_BCC.playSound and not Throttle("daeler", 2.0) then
      DDP_PlaySound(soundPathDaeler, "Master")
    end
  end
end

frame:SetScript("OnEvent", OnEvent)

SLASH_DDPTEST1 = "/ddptest"
SlashCmdList["DDPTEST"] = function() ShowImageAndSound() end
