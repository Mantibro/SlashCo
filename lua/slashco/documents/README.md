Document example:

```lua
local DOCUMENT = {}

DOCUMENT.Name = "Example" -- Required: The name of the document
DOCUMENT.Type = "Slasher" -- The type of the document, can be any value but "Slasher" is used for all documents related to slashers.
DOCUMENT.Slasher = "Watcher" -- Optional: The Slasher ID, if not set it falls back to using the document name

-- NOTE: You don't have to care about new lines, the menu handles thoes for you.
DOCUMENT.Description = [[Some description]] -- A description visible as soon as they get the document
DOCUMENT.AdditionalDescription = [[Additional description]] -- A additional description shown when they managed to survive the slasher.

SlashCo.RegisterDocument(DOCUMENT)
```