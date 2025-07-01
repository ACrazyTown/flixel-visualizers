package vfx;

import flixel.graphics.tile.FlxGraphicsShader;

// https://www.shadertoy.com/view/4s2GRR
class FisheyeShader extends FlxGraphicsShader
{
    @:glFragmentSource('
    #pragma header

    uniform float _power;

    void main()
    {
        // gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

        float prop = openfl_TextureSize.x / openfl_TextureSize.y;//screen proroption
        vec2 m = vec2(0.5, 0.5 / prop);//center coords
        vec2 d = openfl_TextureCoordv.xy - m;//vector from center to current fragment
        float r = sqrt(dot(d, d)); // distance of pixel from center

        float bind;//radius of 1:1 effect
        if (_power > 0.0) bind = sqrt(dot(m, m));//stick to corners
        else {if (prop < 1.0) bind = m.x; else bind = m.y;}//stick to borders

        //Weird formulas
        vec2 uv;
        if (_power > 0.0)//fisheye
            uv = m + normalize(d) * tan(r * _power) * bind / tan( bind * _power);
        else if (_power < 0.0)//antifisheye
            uv = m + normalize(d) * atan(r * -_power * 10.0) * bind / atan(-_power * bind * 10.0);
        else uv = openfl_TextureCoordv.xy;//no effect for _power = 1.0

        vec4 col = flixel_texture2D(bitmap, vec2(uv.x, uv.y)); // flip y for correct direction

        gl_FragColor = col;
    }
    ')

    public function new()
    {
        super();
        power = -0.3;
    }

    public var power(get, set):Float;

    @:noCompletion function set_power(value:Float):Float
    {
        this._power.value = [value];
        return value;
    }

	@:noCompletion function get_power():Float 
    {
		return this._power.value[0];
	}
}
