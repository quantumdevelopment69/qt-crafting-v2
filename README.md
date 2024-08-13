-- # INSTALATION
1. Download qt-library from github 
2. Ensure to start library before qt-crafting resource 
3. Go to the shared.lua in qt-crafting resource 
4. Select framework, target and inventory path that you use for properly script install 
-- # --

-- # CLIENT EXPORT 
exports['qt-crafting']:OpenMenu(table_id) -- #  FOR EXTERNAL SCRIPT OPEN CERTAIN CRAFTING TABLE 
exports['qt-library]:Load() -- # DEFINING LIB FUNCTIONS FOR CLIENT 
-- # --

-- # SERVER EXPORT
exports['qt-library]:Load() -- # DEFINING LIB FUNCTIONS FOR SERVER
-- # --

-- # CHECK FOR BUSY STATE ( GLOBAL FUNCTION )

 !IMPORTANT!  DEFINE QT-LIBRARY 
  QT.IS_BUSY() -- # return boolean (true, false)
 
  !explanation! - In some of our new resources, we have added a busy system, either externally or internally. If you want to prevent the opening of the inventory or other actions while our resource is performing a task, you can add this check function. Enjoy!
-- # 

-- # LIBRARY COMMON FUNCTIONS WITH RESOURCE 

   QT.RemoveContext() -- # closing context menu 
   QT.CloseQuestion() -- # closing question form 
   
-- DOWNLOAD 

-- # QT-LIBRARY 
SRC : https://github.com/quantumdevelopment69/qt-library
