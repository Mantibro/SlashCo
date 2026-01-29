local DOCUMENT = {}

DOCUMENT.Name = "Hat Man"
DOCUMENT.Type = "Slasher"
DOCUMENT.Slasher = nil -- Its not a slasher. Now we gotta define more stuff
DOCUMENT.Class = SlashCo.SlasherClass.Unknown
DOCUMENT.DangerLevel = SlashCo.DangerLevel.Unknown
DOCUMENT.ID = "hatman" -- used for the icon

-- NOTE: The Description is straight out of the SlashCo VR wiki -> https://slashco-vr.fandom.com/wiki/Hat_Man
DOCUMENT.Description = "Hatman_docDesc"
DOCUMENT.AdditionalDescription = [[]]

SlashCo.RegisterDocument(DOCUMENT)