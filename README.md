# qt-crafting

## Installation

Download the `qt-library` from GitHub and ensure it is started before the `qt-crafting` resource.

1. **Download qt-library**:  
   Download the library from the [GitHub repository](https://github.com/quantumdevelopment69/qt-library).
   
2. **Start the library**:  
   Ensure that the `qt-library` resource is started before the `qt-crafting` resource in your `server.cfg`.

3. **Configure `qt-crafting`**:  
   Go to the `shared.lua` file in the `qt-crafting` resource directory.  
   Select the appropriate framework, target, and inventory path according to your server setup.

## Client and Server Exports

You can use the following client-side and server-side exports:

```lua
-- Open a specific crafting table from an external script (Client-side)
exports['qt-crafting']:OpenMenu(table_id)

-- Load the library functions for the client (Client-side)
exports['qt-library']:Load()

-- Load the library functions for the server (Server-side)
exports['qt-library']:Load()


