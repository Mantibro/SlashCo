local DOCUMENT = {}

DOCUMENT.Name = "The Watcher" -- His name in his lua file under SLASHER.Name is "The Watcher" so we should use that one instead of the name given to register him.
DOCUMENT.Type = "Slasher"
DOCUMENT.Slasher = "Watcher"

-- NOTE: The Description is straight out of the SlashCo VR wiki -> https://slashco-vr.fandom.com/wiki/The_Watcher
DOCUMENT.Description = [[An umbra entity, taking the form of an extremely tall old man wearing an olive overcoat, round glasses and a hat. The entity awkwardly stumbles when moving, and has mostly been reported to observe victims patiently while hidden in the dark. This Slasher has been reported to prefer to stay in groups, and has shown to be a brutal killer when acting alone.]]
DOCUMENT.AdditionalDescription = [[This Slasher cannot passively gain [ANGER]. The Watcher will VERY RAPIDLY gain [ANGER] when observing a victim.]]

SlashCo.RegisterDocument(DOCUMENT)