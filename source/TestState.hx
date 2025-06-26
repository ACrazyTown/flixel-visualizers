package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import midi.FlxMIDIRenderer;
import openfl.filters.ShaderFilter;
import vfx.FisheyeShader;
import vfx.PanoramaDistortionShader;

class TestState extends FlxState
{
    var midiRenderer:FlxMIDIRenderer;

    override function create() {
        super.create();

        trace("hello");

        midiRenderer = new FlxMIDIRenderer("assets/whimsi.mid", 
        [
            0xFF16002B,
            0xFF575605,
            0xFF850F0F,
            0xFF2C23A8,
            0xFFCF4AB9,
            0xFF7CE7B2,
            0xFFF0F5A8,
        ]);
        add(midiRenderer);

        var midiCam:FlxCamera = new FlxCamera();
        midiCam.bgColor = 0;
        FlxG.cameras.add(midiCam, false);

        midiRenderer.camera = midiCam;

        var shader = new FisheyeShader();
        shader.power = -5.0;
        midiCam.filters = [new ShaderFilter(shader)];

        var bg = new FlxSprite(0, 0, "assets/bg.png");
        bg.scale.x = 8 / 6;
        add(bg);
        bg.camera = midiCam;

        FlxG.sound.playMusic("assets/whimsi.wav");
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var ps:PreciseSound = cast FlxG.sound.music;
        midiRenderer.updateNotes(ps.position);
    }
}
