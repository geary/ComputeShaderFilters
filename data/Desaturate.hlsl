struct Pixel {
	int colour;
};

StructuredBuffer<Pixel> Buffer0 : register( t0 );
RWStructuredBuffer<Pixel> BufferOut : register( u0 );

float3 readPixel( int x, int y ) {
	float3 output;
	uint index = ( x + y * 1024 );
	
	output.x = (float)( ( Buffer0[index].colour & 0x000000ff ) ) / 255.0f;
	output.y = (float)( ( Buffer0[index].colour & 0x0000ff00 ) >> 8 ) / 255.0f;
	output.z = (float)( ( Buffer0[index].colour & 0x00ff0000 ) >> 16 ) / 255.0f;
	
	return output;
}

void writeToPixel( int x, int y, float3 colour ) {
	uint index = ( x + y * 1024 );
	
	int ired = (int)( clamp( colour.r, 0, 1 ) * 255 );
	int igreen = (int)( clamp( colour.g, 0, 1 ) * 255 ) << 8;
	int iblue = (int)( clamp( colour.b, 0, 1 ) * 255 ) << 16;

	BufferOut[index].colour = ired + igreen + iblue;
}

int clampRGB( float value ) {
	return (int)( clamp( value, 0, 1 ) * 255 );
}

[numthreads( 32, 16, 1 )]
void CSMain( uint3 dispatchThreadID : SV_DispatchThreadID ) {
	float3 pixel = readPixel( dispatchThreadID.x, dispatchThreadID.y );
#if 0
	pixel.rgb = pixel.r * 0.3 + pixel.g * 0.59 + pixel.b * 0.11;
	writeToPixel( dispatchThreadID.x, dispatchThreadID.y, pixel.rgb );
#else
	int r = clampRGB( pixel.r );
	int g = clampRGB( pixel.g );
	int b = clampRGB( pixel.b );
	int color = r | ( g << 8 ) | ( b << 16 );
	int x = g;
	int y = 256 - b;
	int index = x + y * 1024;
	float pixOld;
	InterlockedXor(
		BufferOut[index].colour,
		color,
		pixOld
	);
#endif
}
