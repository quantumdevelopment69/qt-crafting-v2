# qt-crafting

## Installation

Download the `qt-library` from GitHub and ensure it is started before the `qt-crafting` resource.

1. **Download qt-library**:  
   Download the library from the [GitHub repository](https://github.com/quantumdevelopment69/qt-library).
   
2. **Start the library**:  
   Ensure that the `qt-library` resource is started before the `qt-crafting-v2` resource in your `server.cfg`.

3. **Configure `qt-crafting`**:  
   Go to the `shared.lua` file in the `qt-crafting-v2` resource directory.  
   Select the appropriate framework, target, and inventory path according to your server setup.

4. **Ensure that folder name is `qt-crafting-v2`**

## NEW VERSION 2.0.1
1. **DATA STRUCTURE CHANGE**:  
   Because of data structure is changed you must to create again tables and items
2. **UI FIXES**: 
  Added responsive part to a crafting detail modul, builded tailwind base it will not load tailwind from cdn base  
3. **ITEM MULTIPLIER**: 
  Fixed item multiplier bug ( you can add same item with different recipes )
4. **QBOX FRAMEWORK SUPPORT**: 
  Added QBOX framework support ( only for ox_inventory rght now! )
5. **DISCORD LOGS**: 
  Added discord logs you can modify webhook and all into shared/bridge/server/editable.lua

## Client and Server Exports

You can use the following client-side and server-side exports:

```lua
-- Open a specific crafting table from an external script (Client-side)
exports['qt-crafting']:OpenMenu(table_id)

-- Load the library functions for the client (Client-side)
exports['qt-library']:Load()

-- Load the library functions for the server (Server-side)
exports['qt-library']:Load()


