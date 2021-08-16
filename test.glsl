
//基本形，距離関数はsdを頭に着ける

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
	vec3 lightDir = vec3(-0.577, 0.577, 0.577);

	float depth = 0.;


	//ray marching
	vec3 col = vec3(0.);
	vec3 rayPos = cameraPos;
	float dist = 0.;
	for(int i ; i <16 ; i++){
		dist = distFunc(rayPos); //距離関数使用

		depth += dist;
		rayPos = cameraPos + rayDirection * depth;
	}

	
	if( dist < 0.0001){
		vec3 normal = getNormal(rayPos);
		float diff = clamp(dot(lightDir, normal), 1., 1.);
		col = vec3(normal);
	}
	
	fragColor = vec4(col, 1.0);
}

