package midi;

import openfl.display.BlendMode;
import flixel.system.FlxAssets.FlxShader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import grig.midi.MessageType;
import grig.midi.MidiFile;
import grig.midi.file.event.MidiMessageEvent;
import haxe.io.BytesInput;

class FlxMIDIRenderer extends FlxTypedSpriteContainer<FlxMIDINote>
{
    public static final PX_PER_MS:Float = 0.3;

    public var colors:Array<FlxColor>;

    public var bpm:Float;
    public var tickLength:Float;

    public var midiFile:MidiFile;

    public function new(x:Float = 0, y:Float = 0, midiPath:String, colors:Array<FlxColor>)
    {
        super(x, y);
        this.colors = colors;

        var midiBytes = FlxG.assets.getBytes(midiPath);
        midiFile = MidiFile.fromInput(new BytesInput(midiBytes));

        // trace(midiFile.timeDivision);

        var lowestNote:Int = 999;
        var highestNote:Int = 0;

        // trace("hello my midi");
        // trace(midiFile.tracks.length);

        var ci:Int = 0;
        for (track in midiFile.tracks)
        {
            var curColor = colors[ci];
            ci = FlxMath.wrap(ci + 1, 0, colors.length - 1);

            var noteOns = [];
            var noteOffs = [];

            for (midiEvent in track.midiEvents)
            {
                switch (midiEvent.type)
                {
                    // case TimeSignature(event):
                        // trace(event);

                    case TempoChange(event):
                        // TODO: this wont work with tempo changes
                        bpm = FlxMath.roundDecimal(60000000 / event.microsecondsPerQuarterNote, 2);
                        tickLength = (60 / (midiFile.timeDivision * bpm)) * 1000;

                    case MidiMessage(event):
                        if (event.midiMessage.messageType == NoteOn)
                        {
                            lowestNote = Std.int(Math.min(event.midiMessage.pitch.toMidiNote(), lowestNote));
                            highestNote = Std.int(Math.max(event.midiMessage.pitch.toMidiNote(), highestNote));

                            if (event.midiMessage.velocity > 0)
                                noteOns.push(event);
                            else
                                noteOffs.push(event);

                            // curOnEvent = event;

                            // curNote = new FlxMIDINote(-10000, -10000, this, event, curColor);
                        }
                        else if (event.midiMessage.messageType == NoteOff)
                        {   
                            // var note = new FlxMIDINote(-10000, -10000, this, curOnEvent, event, curColor);
                            // note.active = false;
                            // note.visible = true;
                            // add(note);
                            noteOffs.push(event);
                        }

                    default:
                }
            }

            noteOns.sort((a, b) -> return a.absoluteTime - b.absoluteTime);
            noteOffs.sort((a, b) -> return a.absoluteTime - b.absoluteTime);

            for (note in noteOns)
            {
                var counterpart = Lambda.find(noteOffs, (e) -> return e.absoluteTime >= note.absoluteTime && e.midiMessage.pitch == note.midiMessage.pitch);
                if (counterpart != null)
                {
                    // trace(counterpart.absoluteTime - note.absoluteTime);

                    var note = new FlxMIDINote(-10000, -10000, this, note, counterpart, curColor);
                    note.active = false;
                    add(note);
                }
            }
        }

        trace(lowestNote);
        trace(highestNote);

        var numNotes = highestNote - lowestNote;

        // var pxPerNote:Int = Std.int(FlxG.height / (numOctaves * 12));
        var pxPerNote:Int = Std.int(FlxG.height / numNotes);
        // trace(pxPerNote);

        forEach((note) ->
        {
            note.scale.y = pxPerNote;
            note.width = note.scale.x;
            note.height = note.scale.y;

            // trace(note.scale.y);
            note.y = (highestNote - note.onEvent.midiMessage.pitch.toMidiNote()) * pxPerNote;
        }); 
    }

    public function updateNotes(timeInMS:Float):Void
    {
        // var timeInTicks:Float = Std.int(timeInMS * tickLength);
        forEach((note) -> 
        {
            note.x = x + ((note.time - timeInMS) * PX_PER_MS);

            if ((note.x - scale.x) < -100)
            {
                note.active = false;
                // note.visible = false;
            }
            else if (note.x < FlxG.width * 2)
            {
                note.active = true;
                // note.visible = true;
            }
        });
    }
}
