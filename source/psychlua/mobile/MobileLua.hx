package psychlua.mobile;

import flixel.FlxG;
import openfl.system.System;
import lime.system.System as LimeSystem;

class MobileLua
{
    public static function addCallbacks(lua:FunkinLua)
    {
        lua.addLuaCallback("vibrate", function(time:Float = 0.1)
        {
            #if (android || ios)
            LimeSystem.vibrate(cast(time * 1000, Int));
            #end
        });

        lua.addLuaCallback("setFPSCap", function(fps:Int)
        {
            FlxG.updateFramerate = fps;
            FlxG.drawFramerate = fps;
        });

        lua.addLuaCallback("getMemory", function()
        {
            return System.totalMemory;
        });

        lua.addLuaCallback("touchPressed", function()
        {
            return FlxG.touches.justStarted().length > 0;
        });

        lua.addLuaCallback("touchHeld", function()
        {
            return FlxG.touches.list.length > 0;
        });

        lua.addLuaCallback("touchReleased", function()
        {
            return FlxG.touches.justReleased().length > 0;
        });

        lua.addLuaCallback("getTouchX", function(id:Int = 0)
        {
            if (FlxG.touches.list.length > id)
                return FlxG.touches.list[id].x;
            return -1;
        });

        lua.addLuaCallback("getTouchY", function(id:Int = 0)
        {
            if (FlxG.touches.list.length > id)
                return FlxG.touches.list[id].y;
            return -1;
        });

        lua.addLuaCallback("isLandscape", function()
        {
            return FlxG.width > FlxG.height;
        });

        lua.addLuaCallback("setLowQuality", function(value:Bool)
        {
            FlxG.save.data.lowQuality = value;
        });
    }
}
