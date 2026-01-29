local DOCUMENT = {}

DOCUMENT.Name = "The Watcher" -- His name in his lua file under SLASHER.Name is "The Watcher" so we should use that one instead of the name given to register him.
DOCUMENT.Type = "Slasher"
DOCUMENT.Slasher = "Watcher"

-- NOTE: The Description is straight out of the SlashCo VR wiki -> https://slashco-vr.fandom.com/wiki/The_Watcher
DOCUMENT.Description = "Watcher_docDesc"
DOCUMENT.AdditionalDescription = "Watcher_docDescAdd"

SlashCo.RegisterDocument(DOCUMENT)