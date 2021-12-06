REAL4 CustomIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
/** 
SUMMARY:
    Implements a kind of transformation of type 
    a) z = z - const1
    b) z = a*z + b/z +c
	
    NOTE:  This is an early, lazy variant - a*z, and b/z do NOT use triplex multiplication
    This would be a new feature

    It's however already good to be used to create rings in your fractals

CHANGES:
    AddRecip_02.cl:
	  Removes the values that can be added to c - since MB2 has this step built-in already

**/

{
	REAL3 tmp;
	REAL sq_r;
	
	//Pre-shift
	tmp.x = z.x - fractal->transformCommon.offset000.x;
	tmp.y = z.y - fractal->transformCommon.offset000.y;
	tmp.z = z.z - fractal->transformCommon.offset000.z;
	
	//Calculate the inverse
	sq_r = 1.0/(tmp.x*tmp.x + tmp.y*tmp.y + tmp.z*tmp.z + fractal->transformCommon.offset);
	
	tmp.x = tmp.x*sq_r;
	tmp.y = -tmp.y*sq_r;
	tmp.z = -tmp.z*sq_r;
	
	//Bring everything together
	z.x = fractal->transformCommon.constantMultiplier000.x*tmp.x + fractal->transformCommon.constantMultiplier001.x*z.x;
	z.y = fractal->transformCommon.constantMultiplier000.y*tmp.y + fractal->transformCommon.constantMultiplier001.y*z.y;
	z.z = fractal->transformCommon.constantMultiplier000.z*tmp.z + fractal->transformCommon.constantMultiplier001.z*z.z;
	
	return z;
}
