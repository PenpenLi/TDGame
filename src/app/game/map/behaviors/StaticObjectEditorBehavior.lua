
local math2d = import("...math2d")
local MapConstants    = import("..MapConstants")
local EditorConstants = require("app.editor.EditorConstants")

local BehaviorBase = import(".BehaviorBase")
local StaticObjectEditorBehavior = class("StaticObjectEditorBehavior", BehaviorBase)

StaticObjectEditorBehavior.FIRE_CIRCLE_SELECTED_COLOR = {0, 0, 0, 255}
StaticObjectEditorBehavior.FIRE_CIRCLE_UNSELECTED_COLOR = {255, 0, 0, 255}

function StaticObjectEditorBehavior:ctor()
    StaticObjectEditorBehavior.super.ctor(self, "StaticObjectEditorBehavior", nil, 0)
end

function StaticObjectEditorBehavior:bind(object)
    object.isSelected_ = false

    local function isSelected(object)
        return object.isSelected_
    end
    object:bindMethod(self, "isSelected", isSelected)

    local function setSelected(object, isSelected)
        object.isSelected_ = isSelected
    end
    object:bindMethod(self, "setSelected", setSelected)

    local function checkPointIn(object, x, y)
        return math2d.dist(x,
                           y,
                           object.x_ + object.radiusOffsetX_,
                           object.y_ + object.radiusOffsetY_) <= object.radius_
    end
    object:bindMethod(self, "checkPointIn", checkPointIn)

    local function createView(object, batch, marksLayer, debugLayer)
        -- object.idLabel_ = ui.newTTFLabel({
        --     text  = object:getId(),
        --     font  = EditorConstants.LABEL_FONT,
        --     size  = EditorConstants.LABEL_FONT_SIZE,
        --     align = ui.TEXT_ALIGN_CENTER,
        -- })
        object.idLabel_ = g_UICreator:createLabelTTF(object:getId(), EditorConstants.LABEL_FONT_SIZE);
        object.idLabel_.offsetY = math.floor(-object.radius_ - EditorConstants.LABEL_OFFSET_Y)
        debugLayer:addChild(object.idLabel_, EditorConstants.LABEL_ZORDER)

        object.radiusCircle_ = display.newCircle(object.radius_)
        -- object.radiusCircle_:setLineColor(ccc4FFromccc4B(ccc4(unpack(EditorConstants.UNSELECTED_COLOR))))
        -- object.radiusCircle_:setLineStipple(checknumber("1111000011110000", 2))
        -- object.radiusCircle_:setLineStippleEnabled(true)
        debugLayer:addChild(object.radiusCircle_, EditorConstants.CIRCLE_ZORDER)

        object.flagSprite_ = display.newSprite("CenterFlag.png")
        debugLayer:addChild(object.flagSprite_, EditorConstants.FLAG_ZORDER)
        -- object.flagSprite_:setColor(ccc3(255,0,0));
        if object:hasBehavior("FireBehavior") then
            object.fireRangeCircle_ = display.newCircle(object.fireRange_)
            -- object.fireRangeCircle_:setScaleY(MapConstants.RADIUS_CIRCLE_SCALE_Y)
            -- object.fireRangeCircle_:setLineStipple(checknumber("1111000011110000", 2))
            -- object.fireRangeCircle_:setLineStippleEnabled(true)
            debugLayer:addChild(object.fireRangeCircle_)
        end

        if object:hasBehavior("UpgradeBehavior") then
            object.levelLabel_ = g_UICreator:createLabelTTF("Lv." .. object:getLevel(), EditorConstants.LABEL_FONT_SIZE);
            debugLayer:addChild(object.levelLabel_)
            object.levelLabel_:setColor(ccc3(255,255,0))
        end

        if object:hasBehavior("PlayerBehavior") then
            object.playerIdLabel_ = ui.newTTFLabelWithOutline({
                text         = "Player",
                size         = 24,
                outlineColor = ccc3(10, 115, 107),
                color        = ccc3(255, 255, 255),
                align        = ui.TEXT_ALIGN_CENTER,
            })
            debugLayer:addChild(object.playerIdLabel_)
        end
    end
    object:bindMethod(self, "createView", createView)

    local function removeView(object)
        object.idLabel_:removeSelf()
        object.idLabel_ = nil

        object.radiusCircle_:removeSelf()
        object.radiusCircle_ = nil

        object.flagSprite_:removeSelf()
        object.flagSprite_ = nil

        if object.fireRangeCircle_ then
            object.fireRangeCircle_:removeSelf()
            object.fireRangeCircle_ = nil
        end
        

        if object.levelLabel_ then
            object.levelLabel_:removeSelf()
            object.levelLabel_ = nil
        end
        if object.playerIdLabel_ then
            object.playerIdLabel_:removeSelf()
            object.playerIdLabel_ = nil
        end
    end
    object:bindMethod(self, "removeView", removeView)

    local function updateView(object)
        local x, y = math.floor(object.x_), math.floor(object.y_)

        local scale = object.debugLayer_:getScale()
        if scale > 1 then scale = 1 / scale end

        local idString = {object:getId(), "/"}
        if object:hasBehavior("NPCBehavior") then
            idString[#idString + 1] = object:getNPCId()
        elseif object:hasBehavior("TowerBehavior") then
            idString[#idString + 1] = object:getTowerId()
        elseif object:hasBehavior("BuildingBehavior") then
            idString[#idString + 1] = object:getBuildingId()
        elseif object:hasBehavior("PlayerBehavior") then
            idString[#idString + 1] = object:getPlayerTestId()
        end

        idString = table.concat(idString)
        object.idLabel_:setString(idString)
        object.idLabel_:setPosition(x, y + object.idLabel_.offsetY + object.radiusOffsetY_)
        object.idLabel_:setScale(scale)

        object.radiusCircle_:setPosition(x + object.radiusOffsetX_, y + object.radiusOffsetY_)

        object.flagSprite_:setPosition(x, y)
        if object.isSelected_ then
            object.idLabel_:setColor(ccc3(unpack(EditorConstants.SELECTED_LABEL_COLOR)))
            -- object.radiusCircle_:setLineColor(ccc4FFromccc4B(ccc4(unpack(EditorConstants.SELECTED_COLOR))))
        else
            object.idLabel_:setColor(ccc3(unpack(EditorConstants.UNSELECTED_LABEL_COLOR)))
            -- object.radiusCircle_:setLineColor(ccc4FFromccc4B(ccc4(unpack(EditorConstants.UNSELECTED_COLOR))))
        end
        object.flagSprite_:setScale(scale)

        if object:hasBehavior("CollisionBehavior") then
            if object:isCollisionEnabled() then
            end
        end

        if object:hasBehavior("FireBehavior") then
            local circle = object.fireRangeCircle_
            circle:setPosition(x + object.radiusOffsetX_, y + object.radiusOffsetY_)
            if object.isSelected_ then
                -- object.fireRangeCircle_:setLineStippleEnabled(false)
            else
                -- object.fireRangeCircle_:setLineStippleEnabled(true)
            end
        end

        -- if object:hasBehavior("UpgradableBehavior") then
        --     object.levelLabel_:setString(tostring(object.level_))
        --     local x2 = x + object.radiusOffsetX_
        --     local y2 = y + object.radiusOffsetY_ + object.radius_ + MapConstants.LEVEL_LABEL_OFFSET_Y
        --     object.levelLabel_:setPosition(x2, y2)
        -- end

        if object:hasBehavior("UpgradeBehavior") then
            object.levelLabel_:setString("Lv." .. object:getLevel())
            local x2 = x + object.radiusOffsetX_
            local y2 = y + object.radiusOffsetY_ + object.radius_ + MapConstants.LEVEL_LABEL_OFFSET_Y
            object.levelLabel_:setPosition(x2, y2)
        end

        if object:hasBehavior("MovableBehavior") then
        end

        if object:hasBehavior("PlayerBehavior") then
            local label = object.playerIdLabel_
            local x = math.floor(object.x_ + object.radiusOffsetX_)
            local y = math.floor(object.y_ + object.radiusOffsetY_ + object.radius_ + 36)
            label:setPosition(x, y)
            label:setScale(scale)
        end
    end
    object:bindMethod(self, "updateView", updateView)

    local function fastUpdateView(object)
        if object.debugViewEnabled_ then
            updateView(object)
        end
    end
    object:bindMethod(self, "fastUpdateView", fastUpdateView)
end

function StaticObjectEditorBehavior:unbind(object)
    object.isSelected_ = nil

    object:unbindMethod(self, "isSelected")
    object:unbindMethod(self, "setSelected")
    object:unbindMethod(self, "checkPointIn")
    object:unbindMethod(self, "createView")
    object:unbindMethod(self, "removeView")
    object:unbindMethod(self, "updateView")
    object:unbindMethod(self, "fastUpdateView")
end

return StaticObjectEditorBehavior