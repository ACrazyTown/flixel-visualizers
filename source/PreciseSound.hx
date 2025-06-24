package;

import flixel.sound.FlxSound;

@:forward
abstract PreciseSound(FlxSound) from FlxSound to FlxSound
{
    /**
     * The current playing position of this sound.
     * 
     * `FlxSound.time` updates with the game loop instead of independently,
     * which makes it inaccurate to use in some cases.
     * 
     * @see https://github.com/HaxeFlixel/flixel/pull/3272
     */
    public var position(get, never):Float;

    @:noCompletion inline function get_position():Float 
    {
        @:privateAccess
        return this._channel?.position ?? 0;
    }

    /**
     * The current playing, latency compensated, position of this sound.
     * 
     * This is the position of the sound as it comes out of the speakers.
     */
    public var realPosition(get, never):Float;

    @:noCompletion inline function get_realPosition():Float
    {
        @:privateAccess
        return position + this._channel?.__audioSource.latency;
    }
}
