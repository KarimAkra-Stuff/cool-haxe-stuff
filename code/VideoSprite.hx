package;

#if (hxCodec >= "3.0.0")
import hxcodec.flixel.FlxVideoSprite as MainVideoSprite;
#elseif (hxCodec >= "2.6.1")
import hxcodec.VideoSprite as MainVideoSprite;
#elseif (hxCodec == "2.6.0")
import VideoSprite as MainVideoSprite;
#else
import vlc.MP4Sprite as MainVideoSpriteprite;
#end
import states.PlayState;
import haxe.extern.EitherType;
import flixel.util.FlxSignal;
import haxe.io.Path;

/**
 * A class used to allow video playback with any hxCodec version.
 */
class VideoSprite extends MainVideoSprite
{
	public var playbackRate(get, set):Float;
	public var paused(default, set):Bool = false;
	public var onVideoEnd:FlxSignal;
	public var onVideoStart:FlxSignal;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		onVideoEnd = new FlxSignal();
		onVideoEnd.add(destroy);
		onVideoStart = new FlxSignal();
		#if (hxCodec >= "3.0.0")
		onVideoEnd.add(destroy);
		bitmap.onOpening.add(onVideoStart.dispatch);
		bitmap.onEndReached.add(onVideoEnd.dispatch);
		#else
		openingCallback = onVideoStart.dispatch;
		finishCallback = onVideoEnd.dispatch;
		#end
	}

	public function startVideo(path:String, loop:Bool = false):MainVideoSprite
	{
		#if (hxCodec >= "3.0.0")
		play(path, loop);
		#else
		playVideo(path, loop, false);
		#end
		return this;
	}

	@:noCompletion
	private function set_paused(shouldPause:Bool):Bool
	{
		#if (hxCodec >= "3.0.0")
		var parentResume = resume;
		var parentPause = pause;
		#else
		var parentResume = bitmap.resume;
		var parentPause = bitmap.pause;
		#end

		if (shouldPause)
		{
			#if (hxCodec >= "3.0.0")
			pause();
			#else
			bitmap.pause();
			#end

			if (FlxG.autoPause)
			{
				if (FlxG.signals.focusGained.has(parentResume))
					FlxG.signals.focusGained.remove(parentResume);

				if (FlxG.signals.focusLost.has(parentPause))
					FlxG.signals.focusLost.remove(parentPause);
			}
		}
		else
		{
			#if (hxCodec >= "3.0.0")
			resume();
			#else
			bitmap.resume();
			#end

			if (FlxG.autoPause)
			{
				FlxG.signals.focusGained.add(parentResume);
				FlxG.signals.focusLost.add(parentPause);
			}
		}
		return shouldPause;
	}

	@:noCompletion
	private function set_playbackRate(multi:Float):Float
	{
		return bitmap.rate = multi;
	}

	@:noCompletion
	private function get_playbackRate():Float
	{
		return bitmap.rate;
	}

	override function destroy():Void
	{
		super.destroy();
		#if (hxCodec < "3.0.0")
		try
		{
			bitmap.onEndReached();
		}
		catch (e:Dynamic)
		{
			trace(e);
		}
		#end
	}
}
