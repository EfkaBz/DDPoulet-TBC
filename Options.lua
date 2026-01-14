-- Options.lua - Doigt de Poulet (BCC) v4.0
-- FINAL : welcome + options + Hakaza + /ddpsons
-- Behavior: Welcome shows ONCE per SESSION if checkbox is enabled.
-- Closing WoW resets session, so it shows again next time (if enabled).
-- Commands: /ddpoptions, /ddpsons, /ddpwelcome, /ddpwelcome_reset

local ADDON_NAME = ...
local BASE = "Interface\\AddOns\\" .. ADDON_NAME .. "\\data\\"

-- =========================
-- DATABASE (SavedVariables)
-- =========================
DDPouletDB_BCC = DDPouletDB_BCC or {
  showImage = true,
  playSound = true,
  showWelcomeWindow = true, -- controls whether welcome is allowed
}

-- =========================
-- SESSION FLAG (not saved)
-- =========================
local DDP_WelcomeShownThisSession = false

-- =========================
-- OPTIONS PANEL
-- =========================
local panel = CreateFrame("Frame")
panel.name = "DDPoulet"

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -12)
title:SetText("Doigt de Poulet — Options (BCC)")

-- LOGO OPTIONS
panel.icon = panel:CreateTexture(nil, "OVERLAY")
panel.icon:SetTexture(BASE .. "pics\\icone_DDPoulet.tga")
panel.icon:SetSize(64, 64)
panel.icon:SetPoint("TOPRIGHT", -10, -10)

-- IMAGE HAKAZA FOURMIS (OPAQUE)
panel.background = panel:CreateTexture(nil, "BACKGROUND")
panel.background:SetTexture(BASE .. "pics\\Hakaza_fourmis.tga")
panel.background:SetSize(520, 320)
panel.background:SetPoint("CENTER", panel, "CENTER", 0, -40)
panel.background:SetAlpha(1)

-- Checkbox Image
local checkboxImage = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
checkboxImage:SetPoint("TOPLEFT", 16, -48)
checkboxImage.text = checkboxImage:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
checkboxImage.text:SetPoint("LEFT", checkboxImage, "RIGHT", 6, 0)
checkboxImage.text:SetText("Afficher l’image")
checkboxImage:SetScript("OnClick", function(self)
  DDPouletDB_BCC.showImage = self:GetChecked() and true or false
end)

-- Checkbox Sound
local checkboxSound = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
checkboxSound:SetPoint("TOPLEFT", 16, -76)
checkboxSound.text = checkboxSound:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
checkboxSound.text:SetPoint("LEFT", checkboxSound, "RIGHT", 6, 0)
checkboxSound.text:SetText("Jouer les sons")
checkboxSound:SetScript("OnClick", function(self)
  DDPouletDB_BCC.playSound = self:GetChecked() and true or false
end)

-- Placeholder: welcomeFrame is created later, but checkbox wants to reference it.
local welcomeFrame

-- Checkbox Welcome (SESSION behavior)
local checkboxWelcome = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
checkboxWelcome:SetPoint("TOPLEFT", 16, -104)
checkboxWelcome.text = checkboxWelcome:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
checkboxWelcome.text:SetPoint("LEFT", checkboxWelcome, "RIGHT", 6, 0)
checkboxWelcome.text:SetText("Afficher la fenêtre de bienvenue")
checkboxWelcome:SetScript("OnClick", function(self)
  local checked = self:GetChecked() and true or false
  DDPouletDB_BCC.showWelcomeWindow = checked

  if checked then
    -- allow it to show once again during this session (at next login, or via manual command)
    DDP_WelcomeShownThisSession = false
  else
    -- if disabled, hide immediately
    if welcomeFrame and welcomeFrame.Hide then
      welcomeFrame:Hide()
    end
  end
end)

panel:SetScript("OnShow", function()
  checkboxImage:SetChecked(DDPouletDB_BCC.showImage)
  checkboxSound:SetChecked(DDPouletDB_BCC.playSound)
  checkboxWelcome:SetChecked(DDPouletDB_BCC.showWelcomeWindow)
end)

-- =========================
-- REGISTER OPTIONS (SETTINGS BCC)
-- =========================
local ddpCategory
if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
  ddpCategory = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
  Settings.RegisterAddOnCategory(ddpCategory)
end

SLASH_DDPOPTIONS1 = "/ddpoptions"
SlashCmdList["DDPOPTIONS"] = function()
  if Settings and Settings.OpenToCategory and ddpCategory and ddpCategory.GetID then
    Settings.OpenToCategory(ddpCategory:GetID())
  end
end

-- =========================
-- SOMMAIRE DES SONS (/ddpsons)
-- =========================
local soundFrame = CreateFrame("Frame", "DDPouletBCC_SoundFrame", UIParent, "BasicFrameTemplateWithInset")
soundFrame:SetSize(260, 420)
soundFrame:SetPoint("CENTER")
soundFrame:SetMovable(true)
soundFrame:EnableMouse(true)
soundFrame:RegisterForDrag("LeftButton")
soundFrame:SetScript("OnDragStart", soundFrame.StartMoving)
soundFrame:SetScript("OnDragStop", soundFrame.StopMovingOrSizing)
soundFrame:SetFrameStrata("DIALOG")
soundFrame:Hide()

local sTitle = soundFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
sTitle:SetPoint("TOP", 0, -6)
sTitle:SetText("Sommaire des Sons DDPoulet")

-- 🔥 NOMS PROPRES (COMME AVANT)
local soundList = {
  { label = "DDPoulet 1",      file = "DDPoulet.mp3" },
  { label = "DDPoulet 2",      file = "DDPoulet2.mp3" },
  { label = "DDPoulet 3",      file = "DDPoulet3.mp3" },
  { label = "DDPoulet 4",      file = "DDPoulet4.mp3" },
  { label = "Poulet !",        file = "ChickenDeathA.ogg" },
  { label = "Hey Moula",       file = "heymoula.mp3" },
  { label = "Hakaza Fourmis",  file = "hakaza_fourmis.mp3" },
  { label = "Meilleur war",    file = "resistar1.mp3" },
  { label = "AIDEZ-MOI",       file = "resistar_aidezmoi.mp3" },
  { label = "Tu Dekaliss",     file = "tudekaliss.mp3" },
  { label = "Daeler Back !",   file = "daelerback.mp3" },
  { label = "Brutalité !",     file = "brutalite.mp3" },
}

for i, sound in ipairs(soundList) do
  local btn = CreateFrame("Button", nil, soundFrame, "UIPanelButtonTemplate")
  btn:SetSize(180, 24)
  btn:SetPoint("TOP", 0, -20 - (i * 26))
  btn:SetText(sound.label)
  btn:SetScript("OnClick", function()
    PlaySoundFile(BASE .. "sounds\\" .. sound.file, "Master")
  end)
end

-- Bouton fermer (comme avant)
local closeBtn = CreateFrame("Button", nil, soundFrame, "UIPanelButtonTemplate")
closeBtn:SetSize(120, 26)
closeBtn:SetPoint("BOTTOM", 0, 12)
closeBtn:SetText("Fermer")
closeBtn:SetScript("OnClick", function()
  soundFrame:Hide()
end)

SLASH_DDPSOUND1 = "/ddpsons"
SlashCmdList["DDPSOUND"] = function()
  if soundFrame:IsShown() then
    soundFrame:Hide()
  else
    soundFrame:Show()
  end
end

-- =========================
-- BOUTON "Sommaire des Sons" DANS LES OPTIONS
-- =========================
local soundSummaryButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
soundSummaryButton:SetSize(200, 30)
soundSummaryButton:SetPoint("TOPLEFT", checkboxWelcome, "BOTTOMLEFT", 0, -1)
soundSummaryButton:SetText("Sommaire des Sons")
soundSummaryButton:SetScript("OnClick", function()
  if soundFrame:IsShown() then
    soundFrame:Hide()
  else
    soundFrame:Show()
  end
end)


-- =========================
-- WELCOME WINDOW (SESSION)
-- =========================
welcomeFrame = _G["DDPouletBCC_WelcomeFrame"] or CreateFrame("Frame", "DDPouletBCC_WelcomeFrame", UIParent, "BasicFrameTemplateWithInset")
welcomeFrame:SetSize(360, 220)
welcomeFrame:SetPoint("CENTER")
welcomeFrame:SetFrameStrata("DIALOG")
welcomeFrame:Hide()

-- Build only once to avoid stacking on /reload
if not welcomeFrame._ddpBuilt then
  welcomeFrame._ddpBuilt = true

  -- Title
  welcomeFrame.wTitle = welcomeFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  welcomeFrame.wTitle:SetPoint("TOP", welcomeFrame, "TOP", 0, -5)
  welcomeFrame.wTitle:SetText("Bienvenue dans Doigt de Poulet")

  -- Icon
  welcomeFrame.welcomeIcon = welcomeFrame:CreateTexture(nil, "OVERLAY")
  welcomeFrame.welcomeIcon:SetTexture(BASE .. "pics\\icone_DDPoulet.tga")
  welcomeFrame.welcomeIcon:SetSize(46, 46)
  welcomeFrame.welcomeIcon:SetPoint("TOPRIGHT", welcomeFrame, "TOPRIGHT", -14, -30)

  -- Message (bigger)
  welcomeFrame.welcomeMessage = welcomeFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  welcomeFrame.welcomeMessage:SetPoint("TOP", welcomeFrame, "TOP", 0, -62)
  welcomeFrame.welcomeMessage:SetWidth(320)
  welcomeFrame.welcomeMessage:SetJustifyH("CENTER")
  welcomeFrame.welcomeMessage:SetJustifyV("TOP")

  -- Close button (session only)
  welcomeFrame.closeButton = CreateFrame("Button", nil, welcomeFrame, "UIPanelButtonTemplate")
  welcomeFrame.closeButton:SetSize(140, 32)
  welcomeFrame.closeButton:SetPoint("BOTTOM", welcomeFrame, "BOTTOM", 0, 14)
  welcomeFrame.closeButton:SetText("Fermer")
  welcomeFrame.closeButton:SetScript("OnClick", function()
    welcomeFrame:Hide()
    -- Mark as shown for the session only
    DDP_WelcomeShownThisSession = true
  end)
end

-- Update text every load (safe to edit)
welcomeFrame.welcomeMessage:SetText(
  "DDPoulet v4.0 (BCC)\n" ..
  "Version TBC Anniversary\n\n" ..
  "• Nouvelle icône aux couleurs de TBC !\n" ..
  "• Menu options : /ddpoptions\n" ..
  "• Menu des sons : /ddpsons\n\n" ..
  "Bon jeu !"
)

-- =========================
-- SHOW WELCOME ON LOGIN (once per session, if enabled)
-- =========================
local boot = _G["DDPouletBCC_WelcomeBoot"] or CreateFrame("Frame", "DDPouletBCC_WelcomeBoot", UIParent)
boot:UnregisterAllEvents()
boot:RegisterEvent("PLAYER_LOGIN")
boot:SetScript("OnEvent", function()
  if DDPouletDB_BCC.showWelcomeWindow and not DDP_WelcomeShownThisSession then
    DDP_WelcomeShownThisSession = true
    C_Timer.After(1, function()
      welcomeFrame:Show()
    end)
  end
end)

-- =========================
-- MANUAL TEST COMMANDS
-- =========================
SLASH_DDPWELCOME1 = "/ddpwelcome"
SlashCmdList["DDPWELCOME"] = function()
  welcomeFrame:Show()
end

SLASH_DDPWELCOMERESET1 = "/ddpwelcome_reset"
SlashCmdList["DDPWELCOMERESET"] = function()
  DDP_WelcomeShownThisSession = false
  print("DDPoulet: welcome reset pour la session.")
end
