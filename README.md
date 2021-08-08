Direct surface wave radial anisotropy tomography package (DSurfRTomo)

please refer to:

	Hu, S., H. Yao, and H. Huang (2020), Direct surface wave radial 
	anisotropy tomography in the crust of the eastern Himalayan 
	syntaxis. Journal of Geophysical Research: Solid Earth, 125, 
	e2019JB018257. https://doi.org/10.1029/2019JB018257

for details of the algorithm

The dispersion data (ALLR.dat for Rayleigh wave 
and ALLT.dat for Love wave), resulting model (DSurfRTomo.inMeasurement.dat) 
in the crust of the eastern Himalayan syntaxis is provided in example/

#############

2019/05/18
The code may still need some modification  

##############

output (default DRadiSurfTomo.inMeasure.dat) is in the format
	: lon lat dep vsv gamma

To compute average shear wave velocity (vs) and radial anisotropy (xi),
use the following equaitons:

1.	vs=vsv*(1+gamma)/2.0

2.	xi=2*(gamma-1)/(gamma+1)*100%


##############

2021/08/08
1. parallel computation can be used
2. add roughness computation
3. output Rayleigh/Love raypath at the final iteration
4. add some useful scripts in utils/
5. check the noiselevel can be used in the synthetic tests

##############

