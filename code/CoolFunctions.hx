package;

class CoolFunctions
{
    /**
     * A function that's like sys.FileSystem.readDirectory but for openfl!
     * @param directory Directory to read (Dosen't require a library)
     * @return An array of string for the files in the directory
     */
    public static function readDirectory(directory:String):Array<String>
	{
		var dirsWithNoLibrary = Assets.list().filter(folder -> folder.startsWith(directory));
		var dirsWithLibrary:Array<String> = [];
		for(dir in dirsWithNoLibrary)
		{
			@:privateAccess
			for(library in lime.utils.Assets.libraries.keys())
			{
				if(Assets.exists('$library:$dir') && library != 'default' && (!dirsWithLibrary.contains('$library:$dir') || !dirsWithLibrary.contains(dir)))
					dirsWithLibrary.push('$library:$dir');
				else if(Assets.exists(dir) && !dirsWithLibrary.contains(dir))
						dirsWithLibrary.push(dir);
			}
		}
		return dirsWithLibrary;
	}
}