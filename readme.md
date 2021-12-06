# Formulas, and samples for the Mandelbulber 2 program
   
## Intention, notes:
**This repository is mainly intended for publish formulas (currently custom OpenCL only), and related samples for the program Mandelbulber 2.**   

Please find Mandelbulber 2 at https://github.com/buddhi1980/mandelbulber2   
Its documentation:  https://github.com/buddhi1980/mandelbulber_doc   

Originally these `ABC-formulas` repositories were mainly intended to publish my own formulas, and related samples for the several fractal programs I use.   
This was mainly since I found that I need a central place for my formulas rather to have them scattered across the fractal forums, deviantart etc.   
Also I made the experience in earlier days in Ultrafractal that versioning 'by hand' is really a nightmare - I know, that should be self-eveident for any 'real' developer, but I don't see me as true developer, and hence I felt into that trap...   
   
However, while thinking about the way to build such a central repository I came to the conlusion that I would like to follow more the common open source approach, and to publish the formulas in a way that everyone can contribute.   
Therefore - Please feel free to contribute, ask for changes / corrections / improvements, to add your comments, and questions etc.   
     
In any case this repostiory will **not** be used for formulas for the official Mandelbulber 2 distribution.   
Morover: As far as I know there is not (yet?) such a repository for custom OpenCls (Please correct me if I should be wrong).   
Hence it may well be that this repository could be used as a central place for that kind of files.   
The current idea is to identify the original formula author by a specific prefix (in my case gnj_). This is the way how formula authors are identified in Ultrafractal (and to a certain extend also in MB3D JITs).   

## Usage:
To use this formulas you should be familiar with the programm Mandelbulber 2, and here especially with the custom OpenCL feature which exist (as far as I remember) since MB2 v2.23. - See the above link of the MB2 repository for more info.   
    
There is no specific way to import custom OpenCL (.cl) files. You just need to select the fractal type `Custom OpenCL formula`, and to paste the formula to the window that is shown once this formula type is used.   

This repository will also contain .fract files that contain parameters. Custom OpenCL formulas are included in these files in a compacted way. Hence this is an alternative for sharing custom OpenCL code.   
   
**Important note:**   
You will need a graphic card that supports OpenCL.   
However, I never got the feature running on integrated Intel CPU graphics. Theoretically it should support OpenCL, and also MB2 accepted the choice - but as soon as I wanted to run something using OpenCL (internal, or custom) the system did behave ... unpredictable (and no, it's not the known issue with Windows, and the timeout of the graphics driver).    

## Folders:
- The folder /opencl will contain opencl files (and potentially sample data) independent from any publishing elsewhere.   
  Any possible development will happen here.   
  As of now the directory is structured by using subdirectories for formulas of a certain mathematical topic (like /opencl/newton for everything around 3D/4D Newton fractals)   
- The folder /published-samples will contain opencl formulas, and other related data published elsewhere (currently at fractalforums.org only).   
  The files will not be changed (beyond any possible improvements of non-functional parts like documentation etc).   
  Even corrections would result in new files for compatibility with the existing threads.   
  
## Disclaimer:
The formulas have been tested on my box (currently a Windows 10 with an old AMD 280X card) - and sometimes nowhere else.   
I know that OpenCL code is highly dependent from the hardware, especially there are differences in impementation between the hardware producers.   
But I neither have the capacity, nor the intention to test them somewhere else than on my normal boxes.   
Hence I cannot provide any warranty for this code. -    
Please however do not hesitate to share your experiences, or to add code that helps to run it on other hardware.   
As of now I'm publishing all of my formulas under the LGPL license (see the according license file if you really should like that stuff)...   

My formulas need Mandelbulber 2 \>=v2.23 to run - they cannot run independently.   
Of course this program is using own disclaimers, and licenses.   
Hence please check the according notes in the MB2 repository if needed.   