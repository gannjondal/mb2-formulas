REAL4 CustomIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	
/**
 *3 dimensional Newton, adapted from MB3D formula JIT_gnj_Pow3NewtonC_01.m3f
 *
 *The 'C' stands for 'correctly multiplied c value' (in triplex algebra)
 *This is for naming compatibility with the JIT formulas in MB3D
 *
 *CHANGES:
 *
 *MADE BY:
 *Gannjondal
 */
	
// Preparation operations
	REAL fac_eff = 0.6666666666;
	REAL offset = 1.0e-10;
	
	REAL cx = 0.0;
	REAL cy = 0.0;
	REAL cz = 0.0;

if (fractal->transformCommon.juliaMode)
    {
	    cx = fractal->transformCommon.constantMultiplier100.x;
	    cy = fractal->transformCommon.constantMultiplier100.y;
	    cz = fractal->transformCommon.constantMultiplier100.z;
	  }
else
    {
		cx = z.x;
		cy = z.y;
		cz = z.z;
	}
		
// Converting the diverging (x,y,z) back to the variable
// that can be used for the (converging) Newton method calculation
  REAL sq_r = fractal->transformCommon.scale/(aux->r * aux->r + offset);
  REAL x1 = z.x*sq_r + fractal->transformCommon.vec111.x;
  REAL y1 = -z.y*sq_r + fractal->transformCommon.vec111.y;
  REAL z1 = -z.z*sq_r + fractal->transformCommon.vec111.z;
	
	REAL x2 = x1*x1;
	REAL y2 = y1*y1;
	REAL z2 = z1*z1;
	
// Calculate the inverse power of t=(x,y,z),
// and use it for the Newton method calculations for t^power + c = 0
// i.e. t(n+1) = 2*t(n)/3 - c/2*t(n)^2
	
  sq_r = x2 + y2 + z2;
  sq_r = 1/(3*sq_r*sq_r + offset);
  REAL r_xy = x2 + y2;
  REAL h1 = 1 - z2/r_xy;
	
  REAL tmpx = h1*(x2-y2)*sq_r;
  REAL tmpy = -2*h1*x1*y1*sq_r;
  REAL tmpz = 2*z1*native_sqrt(r_xy)*sq_r;
		
  REAL r_2xy = native_sqrt(tmpx*tmpx + tmpy*tmpy);
  REAL r_2cxy = native_sqrt(cx*cx + cy*cy);
  REAL h2 = 1 - cz*tmpz / (r_2xy*r_2cxy);
 
  REAL tmp2x = (cx*tmpx - cy*tmpy) * h2;
  REAL tmp2y = (cy*tmpx + cx*tmpy) * h2;
  REAL tmp2z = r_2cxy*tmpz + r_2xy*cz;

   x1 = fac_eff*x1 - tmp2x;
   y1 = fac_eff*y1 - tmp2y;
   z1 = fac_eff*z1 - tmp2z;

// Below the hack that provides a divergent value of (x,y,z) to Mandelbulber
// although the plain Newton method does always converge

   REAL diffx = (x1 - fractal->transformCommon.vec111.x);
   REAL diffy = (y1 - fractal->transformCommon.vec111.y);
   REAL diffz = (z1 - fractal->transformCommon.vec111.z);

   sq_r = fractal->transformCommon.scale/(diffx*diffx + diffy*diffy + diffz*diffz + offset);
   z.x = diffx*sq_r;
   z.y = -diffy*sq_r;
   z.z = -diffz*sq_r;
	
   return z;	  
  }			 