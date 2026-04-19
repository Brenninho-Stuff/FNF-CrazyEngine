package backend;

import debug.FPSCounter;
import flixel.FlxGame;
import flixel.FlxG;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import openfl.events.KeyboardEvent;
import lime.system.System as LimeSystem;

import states.TitleState;
import mobile.backend.MobileScaleMode;

#if COPYSTATE_ALLOWED
import states.CopyState;
#end

class Main extends Sprite
{
	private var gameConfig = {
		width: 1280,
		height: 720,
		initialState: TitleState,
		zoom: -1.0,
		framerate: 60,
		skipSplash: true,
		startFullscreen: false
	};

	public static var fpsVar:FPSCounter;

	#if mobile
	public static inline var platform:String = "Phones";
	#else
	public static inline var platform:String = "PCs";
	#end

	public static function main():Void
	{
		Lib.current.addChild(new Main());

		#if cpp
		cpp.NativeGc.enable(true);
		cpp.NativeGc.run(true);
		#end
	}

	public function new()
	{
		super();

		preInit();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function preInit():Void
	{
		#if mobile
		#if android
		StorageUtil.requestPermissions();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end

		backend.CrashHandler.init();
	}

	private function init(?e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);

		configureStage();
		setupGame();
		setupCallbacks();
	}

	private function configureStage():Void
	{
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
	}

	private function setupGame():Void
	{
		if (gameConfig.zoom == -1.0)
			gameConfig.zoom = 1.0;

		#if LUA_ALLOWED
		Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call));
		#end

		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.load();
		#end

		addChild(new FlxGame(
			gameConfig.width,
			gameConfig.height,
			#if COPYSTATE_ALLOWED !CopyState.checkExistingFiles() ? CopyState : #end
			gameConfig.initialState,
			gameConfig.framerate,
			gameConfig.framerate,
			gameConfig.skipSplash,
			gameConfig.startFullscreen
		));

		setupFPS();
		setupPlatform();
	}

	private function setupFPS():Void
	{
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);

		if (fpsVar != null)
			fpsVar.visible = ClientPrefs.data.showFPS;
	}

	private function setupPlatform():Void
	{
		#if desktop
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, toggleFullScreen);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		#if mobile
		LimeSystem.allowScreenTimeout = ClientPrefs.data.screensaver;
		FlxG.scaleMode = new MobileScaleMode();
		#end
	}

	private function setupCallbacks():Void
	{
		FlxG.signals.gameResized.add(onResize);
	}

	private function onResize(w:Int, h:Int):Void
	{
		if (fpsVar != null)
			fpsVar.positionFPS(10, 3, Math.min(
				Lib.current.stage.stageWidth / FlxG.width,
				Lib.current.stage.stageHeight / FlxG.height
			));

		if (FlxG.cameras != null)
		{
			for (cam in FlxG.cameras.list)
			{
				if (cam != null && cam.filters != null)
					resetSpriteCache(cam.flashSprite);
			}
		}

		if (FlxG.game != null)
			resetSpriteCache(FlxG.game);
	}

	private static function resetSpriteCache(sprite:Sprite):Void
	{
		@:privateAccess {
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	private function toggleFullScreen(event:KeyboardEvent):Void
	{
		if (Controls.instance.justReleased('fullscreen'))
			FlxG.fullscreen = !FlxG.fullscreen;
	}
}
