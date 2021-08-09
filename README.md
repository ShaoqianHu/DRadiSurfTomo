Direct surface wave radial anisotropy tomography package (DSurfRTomo)

please refer to:

	Hu, S., H. Yao, and H. Huang (2020), Direct surface wave radial 
	anisotropy tomography in the crust of the eastern Himalayan 
	syntaxis. Journal of Geophysical Research: Solid Earth, 125, 
	e2019JB018257. https://doi.org/10.1029/2019JB018257

for details of the algorithm

The code is based on previous studies, especially on the implementation
of DSurfTomo:

	Fang, H., H. Yao, H. Zhang, Y-C Huang, and R. D. van der Hilst (2015)
	Direct inversion of surface wave dispersion for three-dimensional 
	shallow crustal structure based on ray tracing methodology and 
	application. Geophysical Journal International, 201, 1251-1263.

Please also refer to:

	Rawlinson, N. and M. Sambridge (2004) Wave front evolution in 
	strongly heterogeneous layered media using the fast marching method,
	Geophysical Journal International, 156(3), 631-647

for implementation of the fast marching method, and

	Herrmann, R. B. (2013) Computer programs in seismology: An evolving
	tool for instruction and research. Seismological Research Letter,
	84(6), 1081-1088

for implementation of the 1-D surface wave dispersion kernel.

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
1. check parallel computation can be used
2. add roughness computation
3. output Rayleigh/Love raypath at the final iteration
4. add some useful scripts in utils/
5. check noiselevel can be used in the synthetic tests

##############

