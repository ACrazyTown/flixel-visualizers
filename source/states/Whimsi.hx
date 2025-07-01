package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.waveform.FlxWaveform;
import flixel.addons.plugin.screenrecorder.FlxScreenRecorder;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import openfl.filters.ShaderFilter;
import props.Camera;
import props.midi.FlxMIDIRenderer;
import util.Conductor;
import util.PreciseSound;
import vfx.CircleWarpShader;
import vfx.FisheyeShader;
import vfx.WiggleEffect;

class Whimsi extends FlxState
{
	final SONG_NAME:String = "whimsi";
	final COOL_COLOR_1:FlxColor = 0xFF5AD89D;

	var mainCamera:Camera;
	var bgCamera:Camera;
	var midiCamera:Camera;
	var waveformCamera:Camera;
	var hudCamera:Camera;

	var music:PreciseSound;
	var canvas:FlxSprite;
	var waveform:FlxWaveform;
	var waveformLeft:FlxWaveform;
	var waveformRight:FlxWaveform;
	var dvdShadow:FlxSprite;
	var dvd:FlxSprite;
	var bar:FlxSprite;
	var curTime:FlxText;
	var remainingTime:FlxText;
	var conductor:Conductor;
	var coolScroll:FlxText;
	var overlay:FlxSprite;
	var wiggleEffect:WiggleEffect;
	var midi:FlxMIDIRenderer;

	// var recorder:FlxScreenRecorder;

	override public function create()
	{
		super.create();

		// bgColor = 0xFF06110D;

		FlxG.mouse.visible = false;
		FlxG.autoPause = false;
		FlxG.fixedTimestep = false;
		FlxG.updateFramerate = 120;
		FlxG.drawFramerate = 60;

		#if NO_GC
		#if hl
		hl.Gc.enable(false);
		#end
		#end

		// recorder = new FlxScreenRecorder();
		// add(recorder);

		// recorder.start({
		// 	width: FlxG.width,
		// 	height: FlxG.height,
		// 	crf: 17,
		// 	videoCodec: H264,
		// 	framerate: 60
		// });

		music = cast FlxG.sound.load('assets/whimsi/whimsi.wav');

		conductor = new Conductor(135);
		conductor.targetSound = music;
		add(conductor);

		// canvas = new FlxSprite(0, 100).makeGraphic(500, 500);
		// add(canvas);
		
		mainCamera = new Camera();
		FlxG.cameras.reset(mainCamera);

		wiggleEffect = new WiggleEffect();
		wiggleEffect.effectType = FLAG;
		wiggleEffect.waveAmplitude = 0.08;
		wiggleEffect.waveFrequency = 0.2;
		wiggleEffect.waveSpeed = 0.8;
		bgCamera = new Camera();
		FlxG.cameras.add(bgCamera, false);
		// bgCamera.filters = [new ShaderFilter(wiggleEffect.shader)];

		midiCamera = new Camera();
		FlxG.cameras.add(midiCamera, false);
		var fisheye = new FisheyeShader();
		fisheye.power = -0.2;
		midiCamera.filters = [new ShaderFilter(fisheye)];

		waveformCamera = new Camera();
		FlxG.cameras.add(waveformCamera, false);
		var circle = new CircleWarpShader();
		waveformCamera.filters = [new ShaderFilter(circle)];
		circle.bitmap.wrap = REPEAT;

		hudCamera = new Camera();
		FlxG.cameras.add(hudCamera, true);

		// there's some weird fuckery if you apply the shader directly to the bg
		// the waveform circle will stop rendering entirely
		// I have no idea why and TBH im not gonna look into it
		// var bg:FlxSprite = new FlxSprite().loadGraphic("assets/bg.png");
		// bg.camera = bgCamera;
		// bg.scale.set(1.3, 1.3);
		// add(bg);

		// var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF020A06);
		var bg = new FlxSprite(0, 0, "assets/whimsi/whimsi-bg.png");
		bg.camera = bgCamera;
		bg.alpha = 0.6;
		add(bg);

		midi = new FlxMIDIRenderer(0, 0, 'assets/whimsi/whimsi.mid', [0xFF0C291B]);
		midi.camera = midiCamera;
		// midi.setBlend(ADD);
		// midi.blend = ADD;
		// midi.alpha = 0.7;
		midi.screenCenter(Y);
		midi.alpha = 0.8;
		add(midi);

		dvdShadow = new FlxSprite().loadGraphic("assets/dvdShadow.png");
		dvdShadow.alpha = 0;
		dvdShadow.screenCenter();
		add(dvdShadow);

		dvd = new FlxSprite().loadGraphic("assets/whimsi/whimsi-dvd.png");
		dvd.screenCenter();
		add(dvd);

		curTime = new FlxText(5, 5, 0, "8:88", 16);
		curTime.color = COOL_COLOR_1;
		curTime.camera = hudCamera;
		add(curTime);

		remainingTime = new FlxText(0, 5, 0, "8:88", 16);
		remainingTime.color = COOL_COLOR_1;
		remainingTime.alignment = RIGHT;
		remainingTime.camera = hudCamera;
		add(remainingTime);

		var halfHeightText:Int = Std.int(curTime.height);
		var barWidth:Int = Std.int(FlxG.width - curTime.width - remainingTime.width - 20);
		bar = new FlxSprite(curTime.x + 5, 5 + Std.int(halfHeightText / 4)).makeGraphic(barWidth, halfHeightText, COOL_COLOR_1);
		bar.screenCenter(X);
		bar.clipRect = FlxRect.get(0, 0, 0, 10);
		bar.camera = hudCamera;
		add(bar);

		waveform = new FlxWaveform(0, 0, FlxG.width, FlxG.height, COOL_COLOR_1, FlxColor.TRANSPARENT);
		waveform.loadDataFromFlxSound(music);
		waveform.waveformDuration = 20;
		waveform.waveformGainMultiplier = 1.6;
		waveform.waveformDrawBaseline = true;
		// waveform.waveformDrawMode = SPLIT_CHANNELS;
		waveform.camera = waveformCamera;
		add(waveform);

		// call beforehand to cache
		waveform.generateWaveformBitmap();

		var waveformPadding:Int = Std.int(curTime.y + curTime.height + 5);
		var waveformPadding2:Int = waveformPadding * 2;

		waveformLeft = new FlxWaveform(0, waveformPadding, 30, FlxG.height - waveformPadding2, COOL_COLOR_1, FlxColor.TRANSPARENT);
		waveformLeft.loadDataFromFlxWaveformBuffer(waveform.waveformBuffer);
		waveformLeft.waveformDuration = 1000;
		waveformLeft.waveformGainMultiplier = 1.2;
		waveformLeft.waveformOrientation = VERTICAL;
		waveformLeft.waveformDrawMode = SINGLE_CHANNEL(0);
		waveformLeft.waveformDrawBaseline = true;
		add(waveformLeft);

		waveformRight = new FlxWaveform(FlxG.width - 30, waveformPadding, 30, FlxG.height - waveformPadding2, COOL_COLOR_1, FlxColor.TRANSPARENT);
		waveformRight.loadDataFromFlxWaveformBuffer(waveform.waveformBuffer);
		waveformRight.waveformDuration = 1000;
		waveformRight.waveformGainMultiplier = 1.2;
		waveformRight.waveformOrientation = VERTICAL;
		waveformRight.waveformDrawMode = SINGLE_CHANNEL(1);
		waveformRight.waveformDrawBaseline = true;
		add(waveformRight);

		coolScroll = new FlxText(0, 0, 0, 'A Crazy Town - $SONG_NAME');
		coolScroll.y = FlxG.height - coolScroll.height - 5;
		coolScroll.x = -coolScroll.width;
		coolScroll.color = COOL_COLOR_1;
		add(coolScroll);

		overlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		overlay.alpha = 1;
		add(overlay);

		// Hide everything and show it when we do intro
		// curTime.alpha = 0;
		// remainingTime.alpha = 0;
		// bar.alpha = 0;
		// dvd.alpha = 0;
		// waveform.alpha = 0;
		// waveformLeft.alpha = 0;
		// waveformRight.alpha = 0;

		music.onComplete = playOutro;
		FlxG.sound.play("assets/info.ogg");
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.watch.addQuick("beat", conductor.curBeat);
		FlxG.watch.addQuick("step", conductor.curStep);

		if (doneIntro)
		{
			if (music.playing)
			{
				waveform.waveformTime = music.realPosition;
				waveformLeft.waveformTime = music.realPosition;
				waveformRight.waveformTime = music.realPosition;

				bar.clipRect.width = (music.realPosition / music.length) * bar.width;

				curTime.text = FlxStringUtil.formatTime(music.realPosition / 1000, false);
				remainingTime.text = FlxStringUtil.formatTime((music.length - music.realPosition) / 1000, false);
				remainingTime.x = FlxG.width - remainingTime.width - 5;
				coolScroll.x += elapsed * 20;
				if (coolScroll.x > (FlxG.width + coolScroll.width))
					coolScroll.x = -coolScroll.width;
				midi.updateNotes(music.realPosition);
			}
		}
		else
		{
			if (FlxG.keys.justPressed.SPACE && !inIntro)
			{
				playIntro();
			}
		}
		dvd.angle += (conductor.beatLength / 1000) * elapsed * 20;

		wiggleEffect.update(elapsed);
		// recorder.captureFrame();
	}

	var inIntro:Bool = false;
	var doneIntro:Bool = false;

	function playIntro():Void
	{
		inIntro = true;

		overlay.alpha = 1;
		dvd.alpha = 1;
		// FlxTween.tween(overlay, {alpha: 0}, 1);
		overlay.alpha = 0;

		curTime.text = FlxStringUtil.formatTime(music.realPosition / 1000, false);
		remainingTime.text = FlxStringUtil.formatTime((music.length - music.realPosition) / 1000, false);
		remainingTime.x = FlxG.width - remainingTime.width - 5;

		music.play();
		doneIntro = true;

		waveformCamera.visible = false;
		for (camera in FlxG.cameras.list)
		{
			camera.zoom = 2.0;
			camera.scroll.set(-FlxG.width / 4, -FlxG.height / 4);
		}

		conductor.onBeatHit.add((beat:Int) ->
		{
			switch (beat)
			{
				case 1:
					for (camera in FlxG.cameras.list)
					{
						camera.zoom = 2.0;
						camera.scroll.set(FlxG.width / 4, -FlxG.height / 4);
					}

				case 2:
					for (camera in FlxG.cameras.list)
					{
						camera.zoom = 2.0;
						camera.scroll.set(-FlxG.width / 4, FlxG.height / 4);
					}

				case 3:
					for (camera in FlxG.cameras.list)
					{
						camera.zoom = 2.0;
						camera.scroll.set(FlxG.width / 4, FlxG.height / 4);
					}

				case 4:
					for (camera in FlxG.cameras.list)
					{
						camera.zoom = 1.0;
						camera.scroll.set();
						waveformCamera.visible = true;
					}

				default:
			}
		});
	}
	
	function playOutro():Void
	{
		music.time = music.length;

		// FlxTween.tween(dvdShadow, {alpha: 0}, 1);
		// FlxTween.tween(curTime, {alpha: 0}, 1);
		// FlxTween.tween(remainingTime, {alpha: 0}, 1);
		// FlxTween.tween(bar, {alpha: 0}, 1);

		// FlxTween.tween(waveform, {alpha: 0}, 1);
		// FlxTween.tween(waveformLeft, {alpha: 0}, 1);
		// FlxTween.tween(waveformRight, {alpha: 0}, 1);

		// curTime.text = FlxStringUtil.formatTime(music.realPosition / 1000, false);
		// remainingTime.text = FlxStringUtil.formatTime((music.length - music.realPosition) / 1000, false);
		// remainingTime.x = FlxG.width - remainingTime.width - 5;

		FlxTimer.wait(2, () ->
		{
			FlxTween.tween(overlay, {alpha: 1}, 1);
			FlxTimer.wait(2, () ->
			{
				// recorder.stop();
				FlxG.sound.play("assets/info.ogg");
			});
		});
	}
}
