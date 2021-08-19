//基本形，距離関数はsdを頭に着ける

vec3 trans(vec3 p){
	return mod(p,4.0) -2.0;
} //mod くらい関数なんて作らずに自分でさっさと実装した方がいい

mat2 rot(float a){
    float c = cos(a) , s = sin(a);
    return mat2(c, s, -s, c);
}

//absで鏡写しに


const float pi = acos(-1.0);
const float pi2 = pi * 2.0;

vec2 pmod(vec2 p, float r){
    float a = atan(p.x, p.y) + pi/r; //入力座標の計算
    float n = pi2/ r; //単位分割当たりの角度
    a = floor(a/n ) * n; //空間IDをfloorで算出、*nでラジアンにしてる
    return p*rot(-a);
}



float sdSphrere(vec3 pos, float r){
	float d = length(pos) - r;
	return d;
}


float distFunc(vec3 pos){
	float d = length(pos) - 0.5;
	return d;
}

float sdPlane(vec3 p){
	float d = p.y ;
	return d;
}

float sdBox(vec3 p, float s){ //sはsize
	p = abs(p) - s;
	return max(max(p.x, p.y), p.z);
}

float DE(vec3 z){
	z.xy = mod((z.xy), 1.) - vec2(0.5);
	return length(z) - 0.3;
}

float IFS(vec3 p, int iter){ //イテレートファンクションシステム
    for(int i=0; i < iter; i++ ){
        p = abs(p) -vec3(1.); // fold
        p.xz *= rot(1.);
        p.xy *= rot(1.); //rotationK 
    }
    float d = length(p) - 0.5;
    return sdBox(p,0.2);
}

vec3 getNormal (vec3 p ){
	float delta = 0.0001;
	return normalize(vec3(
		distFunc(p + vec3(delta, 0., 0.)) - distFunc(p + vec3(-delta, 0., 0.)),
		distFunc(p + vec3(0., delta, 0.)) - distFunc(p + vec3(0., -delta, 0.)),
		distFunc(p + vec3(0., 0., delta)) - distFunc(p + vec3(0., 0., -delta))
	));
}




void mainImage(out vec4 fragColor, in vec2 fragCoord){
	vec2 p = (fragCoord.xy * 2. - iResolution.xy) / min(iResolution.x, iResolution.y);
	
	vec3 cameraPos = vec3(0., 0., -5);
	float screenZ = 2.5;
	vec3 rayDirection = normalize(vec3(p, screenZ));
	vec3 lightDir =   vec3(0, 0, 5); //vec3(cos(iTime), sin(iTime), -1.); 2.*sin(iTime)

	float depth = 0.;


	//ray marching
	vec3 col = vec3(0.);
	vec3 rayPos = cameraPos;
	float dist = 0.;
	for(int i ; i <64 ; i++){
        int timeN = int(mod(floor(iTime),10.));
		dist = IFS(rayPos,timeN); //距離関数使用

		depth += dist;
		rayPos = cameraPos + rayDirection * depth;
	}

	
	if( dist < 0.0001){
		vec3 normal = getNormal(rayPos);
		float diffuse = clamp(dot(lightDir, normal), 0.1, 1.);
		col = vec3(diffuse);
	}
	
	fragColor = vec4(col, 1.0);
}

