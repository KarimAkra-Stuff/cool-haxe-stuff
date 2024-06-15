package;
import openfl.Assets as OpenFlAssets;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
#if (target.threaded)
import sys.thread.Mutex;
import sys.thread.Thread;
#end
import haxe.ds.Map;
import flixel.util.FlxSignal;
import flixel.util.typeLimit.OneOfTwo;
class CoolFunctions
{
    /**
     * A function that's like sys.FileSystem.readDirectory but for openfl!
     * @param directory Directory to read (Dosen't require a library)
     * @return An array of string for the files in the directory
     */
    public static function readDirectory(directory:String):Array<String>
	{
		var dirsWithNoLibrary = OpenFlAssets.list().filter(folder -> folder.startsWith(directory));
		var dirsWithLibrary:Array<String> = [];
		for(dir in dirsWithNoLibrary)
		{
			@:privateAccess
			for(library in lime.utils.Assets.libraries.keys())
			{
				if(OpenFlAssets.exists('$library:$dir') && library != 'default' && (!dirsWithLibrary.contains('$library:$dir') || !dirsWithLibrary.contains(dir)))
					dirsWithLibrary.push('$library:$dir');
				else if(OpenFlAssets.exists(dir) && !dirsWithLibrary.contains(dir))
						dirsWithLibrary.push(dir);
			}
		}
		return dirsWithLibrary;
	}

	// TODO: Re-write this shit

	public static var cachedGraphics:Map<String, FlxGraphic> = new Map();
    public static var onGraphicCache:FlxTypedSignal<CacheData->Void> = new FlxTypedSignal<CacheData->Void>();
	
	/**
	 * A function that caches a bitmap asynchorously
	 * @param input A String or Array of image(s) to cache.
	 * @param library the library to cache them from (incase openfl Assets ie beign used)
	 */
	public static function cacheImage(input:OneOfTwo<String, Array<String>>, ?library:String)
	{
        var mutex:Mutex = new Mutex();
        #if (target.threaded)
        Thread.create(() -> {
            mutex.acquire();
        #end
        var keys:Array<String> = [];
        if(input is String) keys.push(cast input);
        else keys = cast input;
        for(key in keys){
            try {
                var bitmap:BitmapData = null;
                var file:String = null;

                #if MODS_ALLOWED
                file = Paths.modsImages(key);
                if (Paths.currentTrackedAssets.exists(file)) {
                    var cacheData:CacheData = {
                        graphic: Paths.currentTrackedAssets.get(file),
                        key: key,
                        file: file
                    };
                    if(!Paths.localTrackedAssets.contains(file))
                        Paths.localTrackedAssets.push(file);
                    cachedGraphics.set(cacheData.key, cacheData.graphic);
                    onGraphicCache.dispatch(cacheData);
                    mutex.release();
                    return;
                }
                else if (FileSystem.exists(file))
                    bitmap = BitmapData.fromFile(file);
                else
                    #end
                {
                    file = Paths.getPath('images/$key.png', IMAGE, library);
                    if (Paths.currentTrackedAssets.exists(file)) {
                        #if (target.threaded)
                        var cacheData:CacheData = {
                            graphic: Paths.currentTrackedAssets.get(file),
                            key: key,
                            file: file
                        };
                        if(!Paths.localTrackedAssets.contains(file))
                            Paths.localTrackedAssets.push(file);
                        cachedGraphics.set(cacheData.key, cacheData.graphic);
                        onGraphicCache.dispatch(cacheData);
                        mutex.release();
                        #end
                        return;
                    }
                    else if (OpenFlAssets.exists(file, IMAGE))
                        bitmap = OpenFlAssets.getBitmapData(file);
                    else {
                        trace('no such image $file exists');
                        #if (target.threaded)
                        mutex.release();
                        #end
                        return;
                    }
                }

                if (bitmap != null){
                    var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
                    newGraphic.persist = true;
                    newGraphic.destroyOnNoUse = false;
                    var cacheData:CacheData = {
                        graphic: newGraphic,
                        key: key,
                        file: file
                    };
                    if(!Paths.localTrackedAssets.contains(file))
                        Paths.localTrackedAssets.push(file);
             		Paths.currentTrackedAssets.set(file, cacheData.graphic);
                    cachedGraphics.set(cacheData.key, cacheData.graphic);
                        onGraphicCache.dispatch(cacheData);
                    }
                    else trace('oh no the image is null NOOOO ($file)');
                    #if (target.threaded)
                    mutex.release();
                    #end
                }
                catch(e:Dynamic) {
                    #if (target.threaded)
                    mutex.release();
                    #end
                    trace('ERROR! failed to cache image $key (${Std.string(e)})');
                }
            }
        #if (target.threaded)
        });
        #end
	}
}