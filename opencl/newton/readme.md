# Custom OpenCL formulas related to the 3D, and 4D Newton fractal

## Current references:
- FF org - Revisiting the 3D Newton (original introduction of the principle):   
   https://fractalforums.org/fractal-mathematics-and-new-theories/28/revisiting-the-3d-newton/1026
- FF org - Terra Newtonia (picture thread that also contains params):   
   https://fractalforums.org/image-threads/25/terra-newtonia/3963
- dA - Gallery Terra Newtonia (images; some with params):   
   https://www.deviantart.com/gannjondal/gallery/77446093/terra-newtonia

## Formula naming:
- `gnj` is my 3-digit identifier (for `gannjondal`)   
- `RealPowNewt` = (3D) Newton fractal formula using triplex numbers, and a free power parameter of type floating point  
- `Pow3Newton` = (3D) Newton fractal formula using triplex numbers for z^`3` ONLY which uses cartesian coordinates. Hence it avoids sin/cos/atan/power etc, and should hence be faster than the RealPow versions   
- `_01, _02 etc` The logic behind fractal formulas makes it not that easy (well, for me) to ensure backward compatibility.   
   I will try to keep an eye to that topic in future, so that there will not be too many of those \_xy variants.   
   Also there is not (and will not be) any formula `packages` that may have an own versioning.   
   Hence please consider that you may not be able to use a \_02 variant within params originally written with a \_01 of the same type   

**One-character identifiers:**   
- `E` stands for _easy to use_:  It is for z^n-`1`=0 only, and uses `1` as the one-and-only fix solution.   
  **Start with Julia = 0/0/0 for a clean Newton bulb**  
- `P` stands for _pretransform_:  The formula _can_ be used as stand-alone formula.   
   However different values of a solution of the Newton-Raphson method, as well as the `c` in `z^n+c` don't introduce anything new (at least not without much on effort), and makes configuration difficult.   
   Nevertheless the older varaiants that allow these settings are still useful mainly as pretransforms:  The combination of inversion, and power allow to introduce great variations of distortions.     
- `C` stands for _correct multiplication of c_:   
  In earlier versions of MB3D JIT formulas I did not take the effort to correctly multiply c.   
  As there is no older version for MB2 this is for compatibility across the several fractal programs   

**Numbering/Versioning:**     
- `_##`:  The number at the end is just the version:   
  The logic behind fractal formulas makes it not that easy (well, for me) to ensure backward compatibility.   
  Therefore it's most useful to keep old versions somehow, other than usual in software development.   
  Also there is not (and will not be) any formula packages that may have an own versioning.   
  Hence please consider that you may not be able to use a \_02 variant within params originally written with a \_01 of the same type.   
  
  I will try to keep an eye to that topic in future, so that there will not be too many of those \_xy variants.   

## Documentation:   
Copied over from the formula doc of gnj_RealPowNewtE_01.cl - the variables in other formulas do slightly differ - please check the individual formulas for details, although I may improve the documentation for some older formulas later (well, I hope)...
   
```
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
           Try values between about 2 and 0 (in hybrids also negative values; start with |value|<=1).

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
       + First of all: To get a useful 3D image it is necessary to define an 'inside', and an 'outside' region   
       + The common DE mechanisms of MB2, and MB3D need a DIVERGENT iteration value (here z)
       + It is of course necessary to have a variable (here q) that is used for the actual Newton iteration
       + In MB3D (and maybe also in MB2) it is not possible to keep another triplex value than z between the iterations.

       Therefore it is necessary to have a z that diverges - AND it must be possible to always calculate q from z uniquely (mathematically: There must be a one-to-one relation between q, and z).
       Furthermore I decided that the area that converges to one specific value (below 'solution') is taken as 'outside'. The other areas are 'inside'.   
       Of course that way you see only the outer surface of the 'inside' area, but it turned out that with some tweaks it's possible to see ... more of the transition area.

       Below algorithm fullfills all above conditions - Each iteration looks like:
       a)  Extract q[n] as q[n] = 1/z[n] + solution
       b)  Run the Newton method calculation which provdes a new q[n+1]
       c)  Calculate z[n+1] as z[n+1] = 1/(q[n+1]-solution), and hand it over to the fractal program

       To have a classical Newton star one would need to skip the very first inversion.
       But I decided to keep that first inversion -
       It transforms the formula to a finite object - so to speak a Newton bulb.
       And this object is of course much more handleable than the classical infinite star - in fact I see that as a benefit which has been introduced without any cost....
*/
```
