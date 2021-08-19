#define S(a, b , t ) smoothstep(a, b, t)
//a以下は0, b以上は１，それ以外はスムーズな01曲線

#define sat(x) clamp(x, 0., 1.)

//mix... x(1-a)+y*aを返す（つまり線形補間）

//数値tを範囲(0,1)から範囲(a,b)へ変換
float remap01(float a, float b,float t ){
    return (t-a)/(b-a );
}

 // 数値tを範囲(a,b)から範囲(c,d)へ変換
float remap(float a, float b, float c, float d,float t ){
    return sat(((t-a)/(b-a )) * (d-c) + c);
}

vec2 within (vec2 uv, vec4 rectangle){
	return (uv - rectangle.xy )/ (rectangle.zw - rectangle.xy);

}

vec4 Mouse(vec2 uv){
	uv -= .5;
    vec4 col = vec4(.5, .18, .05, 1.);

	uv.y *= 1.5;
	uv.y -= uv.x * uv.x * 2.;
	float d = length(uv);
	col.a = S(.5, .48 ,d); //透過度とSをつかって形を作ろう

	float td = length(uv -vec2(0. , .6));
	vec3 toothCol = vec3(1.) * S(.6, .35, d);
	col.rgb = mix(col.rgb , toothCol, S(.4, .37,td));

	td = length(uv + vec2(0., .5));
	col.rgb = mix(col.rgb, vec3(1., .5, .5), S(.5, .2, td));
    return col;
}

vec4 Eye(vec2 uv){
	uv -= .5;
    vec4 col = vec4(1.);
	float d = length(uv);
	float t = abs(sin(iTime));

	vec4 irisCol = vec4(.3, .5, 1., 1.);
	col = mix(vec4(1.), irisCol, S(.1, .7, d)* .5);

	col.rgb *= 1. - S(.45, .5, d)* 0.5 * sat(-uv.y);



	col.rgb = mix(col.rgb , vec3(0.), S(.3, .28, d)); //iris outline

	irisCol.rgb *= 1. + S(.3, .05, d);
	col.rgb = mix(col.rgb , irisCol.rgb, S(.28, .25, d));
	col.rgb = mix(col.rgb , vec3(0.), S(.16, .14, d)); //Sが大から小なら半径の内側

	float highlight = S(.1, .09, length(uv-vec2(-0.15, .15)));
	highlight +=  S(.07, .05, length(uv+vec2(-.08, .08)));
	highlight *= t + 0.3;
	col.rgb = mix(col.rgb, vec3(1.), highlight); //レイヤー形式。こことirisを逆に描くと下に書かれて描画されない。

	col.a = S(.5, .48, d);

    return col;
}

vec4 Head(vec2 uv){
    vec4 col = vec4(.9, .65, .1, 1.);

    float d = length(uv);

    col.a = S(.5, .49, d);

    float edgeShadow = remap01(.35, .5, d);

	col.rgb *= 1. - edgeShadow * 0.5;
	col.rgb = mix(col.rgb, vec3(.6, .3, .1), S(.47, .48, d)); //mixでふちを作る

	float highlight = S(.41, .405, d);
	highlight *= remap(.41, -0.1, .75, 0. , uv.y);
	col.rgb = mix(col.rgb , vec3(1.), highlight);

	d= length(uv - vec2(.25, -0.2)); //vec2(.25, -0.2)が中心座標。ここにチークを円状にのせる
	float cheek = S(.2, .01, d) *.4; //チークの大きさを決める。今回は半径０．２の円となる。これ反転させると、色も反転してしまうので注意
	//*0.4で色の濃さを調節
	cheek *= S(.17, .16, d); //円のふちをスムーズに
	col.rgb = mix(col.rgb, vec3(1., .1, .1) , cheek); //ここでチークのいろを定義


    return col;
}

vec4 Smiley(vec2 uv){
    vec4 col = vec4(0.);

	uv.x = abs(uv.x); 

    vec4 head = Head(uv);
	vec4 eye = Eye(within(uv, vec4(.03, -0.1, .37, .25))); //?
	vec4 mouse = Mouse(within(uv, vec4(-.3, -.4, .3, -.1))); //?

    col = mix(col, head , head.a);
	col = mix(col, eye, eye.a);
	col = mix(col, mouse, mouse.a);

    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
	vec2 p = (fragCoord.xy * 2. - iResolution.xy) / min(iResolution.x, iResolution.y);

    fragColor = Smiley(p);
}