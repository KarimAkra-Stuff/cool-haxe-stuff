package objects;

import openfl.Lib;
import openfl.display.Sprite;
import lime.ui.Window as LimeWindow;
import lime.ui.WindowAttributes;
import sys.thread.Thread;
import sys.thread.Mutex;

// THIS IS OLD AND UNOPTIMIZED, NEEDS SOME REWORK !!!!

/**
    A class that makes a new window and draws a FlxCamera into it.
    here are some issues with this thing:
    * when thw window gets so small, the objects size kinda become off
    * unable to to add per-object shader (if you want to add shaders you can use `this.sprite.shader` and for ShaderFilters you can use `this.sprite.filters` or `this.window.stage.filters`)
**/
class Window {

    /**
    * The window itself.
    **/
    public var window:LimeWindow;

    /**
    * A openfl Sprite that's added to the window, a FlxCamera is drawn onto this Sprite.
    **/
    public var sprite:Sprite = new Sprite();

    /**
    * A FlxCamera that is used to draw it's objects onto the window.
    **/
    public var displaySource:FlxCamera;

    /**
    * A Bool to check if the window is closed.
    **/
	public var closed(default, null):Bool = false;

    /**
    * The window's default width(the width when it was first created).
    **/
    public var defaultWidth(default, null):Int;
    /**
    * The window's default height(the height when it was first created).
    **/
    public var defaultHeight(default, null):Int;

    @:noCompletion
    private var thread(null, null):Thread;

    /**
    * Creats A New Window.
    * @param title    The Window's Title.
    * @param width    The Window's Width.
    * @param height    The Window's Height.
    * @param x          The Window's X Position.
    * @param Y          The Window's Y Position.
    **/
    public function new(title:String, width:Int, height:Int, ?x:Int, ?y:Int, ?resizable:Bool = true, ?hidden:Bool = false, 
        ?fullscreen:Bool = false, ?borderless:Bool = false, ?alwaysOnTop:Bool = false, ?allowHighDPI:Bool = false) {
        if(x == null)
            x = FlxG.stage.window.x;
        if(y == null)
            y = FlxG.stage.window.y;
        defaultWidth = width;
        defaultHeight = height;
        var attributes:WindowAttributes = {
            allowHighDPI: allowHighDPI,
            alwaysOnTop: alwaysOnTop,
            borderless: borderless,
            frameRate: 30,
            fullscreen: fullscreen,
            width: width,
            height: height,
            hidden: hidden,
            resizable: resizable,
            title: title,
            x: x,
            y: y,
            context: {
                colorDepth: 32,
                hardware: true,
                vsync: true
            }
        };
        window = Lib.application.createWindow(attributes);
        // The window dosen't use the X and Y from the attributes so gotta set them manually
        window.x = x;
        window.y = y;
        displaySource = new FlxCamera();
        displaySource.bgColor.alpha = 0;
        FlxG.cameras.list.insert(FlxG.cameras.list.indexOf(PlayState.instance.camGame) -1, displaySource);
        // Adds events listeners and signals.
        //@:privateAccess
        //FlxG.signals.postDraw.add(displaySource.render);
        FlxG.stage.window.onRender.add(updateDisplay);
        FlxG.stage.window.onClose.add(destroy);
        window.onClose.add(() -> closed = true);
        window.onResize.add(resizeSprite);
        window.stage.addChild(sprite);
        window.stage.addChild(displaySource.flashSprite);
        FlxG.stage.window.focus();
    }

    /**
    * simple function to resize the window
    @return a `FlxPoint` with the width and height
    **/
    public function resizeWindow(width:Int, height:Int):FlxPoint {
        window.width = width;
        window.height = height;
        resizeSprite(width, height);

        return FlxPoint.get(window.width, window.height);
    }

    /**
    * Resizs the sprite inside the window
    * (IT KINDA STARTS FAILING WHEN THE WINDOW GETS TOO SMALL)
    **/
    function resizeSprite(width:Int, height:Int){
        for(i in 0...window.stage.numChildren){
            var child = window.stage.getChildAt(i);
            var scale = Math.min(width / defaultWidth, height / defaultHeight);
            child.scaleX = child.scaleY = scale;
            sprite.x = (width - child.width) / 2;
            sprite.y = (height - child.height) / 2;
        }
    }

    /**
    * Closes the window removing all of it's events
    **/
    public function destroy() {
        if(!closed){
            @:privateAccess
            FlxG.signals.postDraw.remove(displaySource.render);
            FlxG.stage.window.onRender.remove(updateDisplay);
            FlxG.stage.window.onClose.remove(destroy);
            window.close();
            window = null;
            closed = true;
        }
    }

    /**
        A Simple function that draws the `displaySource` FlxCamera's canvas onto this window's sprite.
    **/
    @:noCompletion
    private function updateDisplay(a:lime.graphics.RenderContext) {
        if(!closed && !window.minimized){
            sprite.graphics.clear();
            sprite.graphics.copyFrom(displaySource.canvas.graphics);
            sprite.graphics.drawRect(0, 0, 0, 0);
            sprite.graphics.endFill();
        }
	}
}