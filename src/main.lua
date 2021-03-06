
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")



require "config"
if DEBUG > 0 then
	print = release_print;
end
require "cocos.init"



local function main()

	require "quick._load"

	require "config._load"
	
    -- require("app.MyApp"):create():run()

    local EditorScene = require("app.editor.EditorScene");
    local scene = EditorScene.new();
    display.runScene(scene, transition, time, more)

end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
