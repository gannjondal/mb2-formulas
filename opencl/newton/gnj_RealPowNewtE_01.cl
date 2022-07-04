//3D Newton calculation for z^n-1=0

/* Comments, param explanations

   SUMMARY:
     3D Newton made from the bulb formula.
     Normal triplex algebra. 

   MADE BY:
     Gannjondal

   PARAMETERS:
      Power_:
        Default = 3
        The power of the polynom
         (x,y,z)^power - 1 = 0
        to be solved
     
      Fake_Bailout, Fake_Bailout2 --> fractal->transformCommon.scale1/2:
        Default = 1 / 1
        ORIGINAL INTENTION:
          At least in the first MB3D versions of the formula higher R bailout values introduced a VERY bad quality (or even unwanted artifacts).
          In some hybrids it is however necessary to increase the value of 'R Bailout' on the formula window to avoid unwanted cuts etc.
          In this case you may set Fake_Bailout to 'R bailout'/4 as a start value.
        MEANWHILE:
          It turned out that changing this value can lead to completely different structures.
          I don't have a simple suggestion - you may use samples that exist especially on ff.org (image thread 'Terra Newtonia')
        USAGE:  
          Changing the value of both params in parallel scales the complete object.
          You may use the _Scaling transfrom on 3Da tab as a pretransform to scale the object back.
          Fake_Bailout - used BEFORE the transformation
          Fake_Bailout2 - used AFTER the transformation
     
      Fac_Phi, Fac_Theta --> fractal->transformCommon.scaleA0/1:
         Default = 1.0 for both
         EXPLANATION:
           With this params you can vary the radial angles when calculating the power of the triplex z.
           The params are multiplied to the calculated angles.
           I also had tried addition params - but the results were ugly (cuts etc).
           Hence it chnges the angle parts of the power calculation, but in a very smooth way.
         USAGE:  
           Try values between 2 and 0 (in hybrids also negative values).
         
      Trans (REAL4) --> fractal->transformCommon.additionConstant0000:
         Default = (0,0,0)
         Parameter to set translation before an iteration - and the according backwards transformation afterwards
         HINT:  Only the first 3 params are used; 
                The param should be of type REAL3, but MB2 denies
         
      Inversion_Factor --> fractal->transformCommon.invert0:
        Default = -1.0
        ORIGINAL INTENTION: 
           -1 -> triplex inversion
           +1 -> sphere inversion
        MEANWHILE:
          It turned out that both are equivalent for symmetry reasons.
          However, it's worth to play with values of |Inversion_Factor| != 1
        USAGE:
          Don't change it too much - Try values between -0.75, and -1.5

    COMMENTS, EXPLANATIONS:
     - Naming:
       gnj_RealPowNewtE_xx.cl - The 'E' stands for 'easy to be used' -- 
       This variant is for q^k-1=0 ONLY (other c in q^k-c=0 won't make a real difference)
       
     - The formula defines all points as 'outside' that converge to the solution 1 of the above equation.
       The solution value is not configurable anymore - for the same reason as above.
       As a pretransform it may be useful to have a variable "solution" value to have a customizable inversion point. -
       But that may be done in another formula - inside a normal iteration such a param mainly adds ugly distortions.

     - Meaning of the identifiers in below explanations:
       + z stands for the variable that is visible to the fractal program, and that is used for bailout check, 
         calculation of the distance estimation etc etc
       + q stands for the variable that is used for the calculation of the Newton method
       
     - Explanation of the "trick".
       It was necessary to keep the following conditions in mind:
       + The common DE mechanisms of MB2, and MB3D need a DIVERGENT iteration value (here z)
       + It is of course necessary to have a variable (here q) that is used for the actual Newton iteration
       + In MB3D (and maybe also in MB2) it is not possible to keep another triplex value than z between the iterations.
       
       Therefore it is necessary to have a z that diverges AND it must be possible to always calculate q from z uniquely (mathematically: There must be a one-to-one relation between q, and z).
	   
       Below algorithm fullfills all above conditions - Each iteration looks like:
       a)  Extract q[n] as q[n] = 1/z[n] + solution
       b)  Run the Newton method calculation which provdes a new q[n+1]
       c)  Calculate z[n+1] as z[n+1] = 1/(q[n+1]-solution), and hand it over to the fractal program
      
       To have a classical Newton star one would need to skip the very first inversion.
       But I decided to keep that first inversion - 
	   It transforms the formula to a finite object - so to speak a Newton bulb.
       And this object is of course much more handleable than the classical infinite star - in fact I see that as a benefit which has been introduced without any cost....
*/

REAL4 CustomIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
    
/* Default values
   .RStop = 16
   
   .Double Fac_Phi = 1.0
   .Double Fac_Theta = 1.0
   .Double Fake_Bailout = 1.0
   .Double Fake_Bailout2 = 1.0
   .Double Inversion_Factor = -1.0
   .Double fractal->bulb.power = 3
   .Double Trans_x = 0.0
   .Double Trans_y = 0.0
   .Double Trans_z = 0.0
*/

// Definitions, preparation operations
   REAL offset = 1E-10;
   REAL Solution_x = 1.0;
   REAL Solution_y = 0.0;
   REAL Solution_z = 0.0;

   REAL pow_eff = 1 - fractal->bulb.power;
   REAL fac_eff = (fractal->bulb.power - 1)/fractal->bulb.power;
   
   REAL4 trans = fractal->transformCommon.additionConstant0000;
   // REAL3 trans = fractal->transformCommon.additionConstant000;  --> MB2 claims that a float 4 cannot be used to instantiate a float3; no idea why ?!?
   REAL Fake_Bailout = fractal->transformCommon.scale1;
   REAL Fake_Bailout2 = fractal->transformCommon.scale2;
   REAL Inversion_Factor = fractal->transformCommon.invert0;
   REAL Fac_Phi = fractal->transformCommon.scaleA0;
   REAL Fac_Theta = fractal->transformCommon.scaleA1;

   z.x += trans.x;
   z.y += trans.y;
   z.z += trans.z;
   
// Converting the diverging (x,y,z) back to the variable
// that can be used for the (converging) Newton method calculation
   REAL sq_r = Fake_Bailout/(z.x*z.x + z.y*z.y + z.z*z.z + offset);
   z.x = z.x*sq_r + Solution_x;
   z.y = Inversion_Factor*z.y*sq_r + Solution_y;
   z.z = Inversion_Factor*z.z*sq_r + Solution_z;

// Calculate the inverse power of t=(x,y,z),
// and use it for the Newton method calculations for t^power + c = 0
// i.e. t(n+1) = (power-1)*t(n)/power - c/(power*t(n)^(power-1))
   sq_r = z.x*z.x + z.y*z.y + z.z*z.z;
   REAL r = sqrt(sq_r);

   REAL phi = Fac_Phi*asin(z.z/r);
   REAL theta = Fac_Theta*atan2(z.y,z.x);

   REAL r_pow= native_powr(r, pow_eff);
   REAL phi_pow = phi*pow_eff;
   REAL theta_pow = theta*pow_eff;

   REAL sth = native_sin(theta_pow);
   REAL cth = native_cos(theta_pow);
   REAL sph = native_sin(phi_pow);
   REAL cph = native_cos(phi_pow);

   REAL r_norm = r_pow/fractal->bulb.power ;

   REAL tmpx = cph*cth*r_norm;
   REAL tmpy = cph*sth*r_norm;
   REAL tmpz = -sph*r_norm;

/*Multiply c and 1/(power*t(n)^(power-1))
    Commented out to simplify the usage.
    The subsequent calculations have been corrected accordingly.
    Old calculation:
       rcxy = sqrt(cx*cx + cy*cy);
       rzxy = sqrt(tmpx*tmpx + tmpy*tmpy);
     
       h = 1.0 - cz*tmpz/(rcxy*rzxy);
     
       tmpx = (cx*tmpx - cy*tmpy)*h;
       tmpy = (cy*tmpx + cx*tmpy)*h;
       tmpz = (rcxy*tmpz + rzxy*cz);
*/

//Bring everything together   
   z.x = fac_eff*z.x + tmpx;
   z.y = fac_eff*z.y + tmpy;
   z.z = fac_eff*z.z - tmpz;

// Below the hack that provides a divergent value of (x,y,z) to MB2
// although the plain Newton method does always converge
   REAL diffx = (z.x-Solution_x);
   REAL diffy = (z.y-Solution_y);
   REAL diffz = (z.z-Solution_z);

   sq_r = Fake_Bailout2/(diffx*diffx + diffy*diffy + diffz*diffz + offset);
   z.x = diffx*sq_r;
   z.y = Inversion_Factor*diffy*sq_r;
   z.z = Inversion_Factor*diffz*sq_r;
   
   z.x -= trans.x;
   z.y -= trans.y;
   z.z -= trans.z;
   
    if (fractal->analyticDE.enabled)
    {
        aux->DE = aux->DE * fractal->analyticDE.scale1 + fractal->analyticDE.offset1;
    }
   
   return z;
}