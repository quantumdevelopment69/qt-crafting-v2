
Here's a well-organized README structure for your GitHub repository:

qt-library
A versatile Lua library for FiveM, providing essential functions for resource management and interaction.

Installation
Follow these steps to set up the qt-library and qt-crafting resources:

Download qt-library:
Download the library from the GitHub repository.

Start the library:
Ensure that the qt-library resource is started before the qt-crafting resource in your server.cfg.

Configure qt-crafting:
Open the shared.lua file in the qt-crafting resource directory.
Select the appropriate framework, target, and inventory path according to your server setup to properly install the script.

Client Exports
The following client-side exports are available for use:

Open Crafting Menu:
exports['qt-crafting']:OpenMenu(table_id)
Use this function to open a specific crafting table from an external script.
