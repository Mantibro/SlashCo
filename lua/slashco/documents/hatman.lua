local DOCUMENT = {}

DOCUMENT.Name = "Hat Man"
DOCUMENT.Type = "Slasher"
DOCUMENT.Slasher = nil -- Its not a slasher. Now we gotta define more stuff
DOCUMENT.Class = SlashCo.SlasherClass.Unknown
DOCUMENT.DangerLevel = SlashCo.DangerLevel.Unknown
DOCUMENT.ID = "hatman" -- used for the icon

-- NOTE: The Description is straight out of the SlashCo VR wiki -> https://slashco-vr.fandom.com/wiki/Hat_Man
DOCUMENT.Description = [[A consistent hallucination reported to be seen by those who have ingested excessive doses of Diphenhydramine. Most who have experienced this entity claim to be somehow monetarily indebted to it. Other common hallucinations include visions of various large insects as well as silhouettes of people. The Hat Man will continuously head towards your current location. Staring at The Hat Man will stop him, and after a short moment will get him to temporarily disappear.]]
DOCUMENT.AdditionalDescription = [[]]

SlashCo.RegisterDocument(DOCUMENT)