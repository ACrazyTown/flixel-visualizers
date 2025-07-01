package props.midi;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import grig.midi.MidiMessage;
import grig.midi.file.event.MidiMessageEvent;

class FlxMIDINote extends FlxSprite
{
    public var time:Float;

    var parent:FlxMIDIRenderer;
    public var onEvent:MidiMessageEvent;
    public var offEvent:MidiMessageEvent;

    public function new(x:Float = 0, y:Float = 0, parent:FlxMIDIRenderer, onEvent:MidiMessageEvent, offEvent:MidiMessageEvent, color:FlxColor)
    {
        super(x, y);
        this.parent = parent;
        this.onEvent = onEvent;
        this.offEvent = offEvent;

        makeGraphic(1, 1, color);
        origin.set(0, 0);

        scale.x = Std.int(parent.tickLength * (offEvent.absoluteTime - onEvent.absoluteTime) * FlxMIDIRenderer.PX_PER_MS);
        time = parent.tickLength * onEvent.absoluteTime;
    }
}
