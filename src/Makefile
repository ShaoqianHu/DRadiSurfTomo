CMD = DRadiSurfTomo
OUTFOLD=../bin
FC = gfortran
FFLAGS  = -O3 -ffixed-line-length-none -ffloat-store\
           -W  -fbounds-check -m64 -mcmodel=medium
F90SRCS = lsmrDataModule.f90 lsmrblasInterface.f90\
          lsmrblas.f90 lsmrModule.f90 delsph.f90\
          aprod.f90 gaussian.f90 main.f90 synRadAni.f90 CalRadAniG.f90
FSRCS =  surfdisp96.f

OBJS = $(F90SRCS:%.f90=%.o) $(FSRCS:%.f=%.o) CalSurfG.o

all:$(CMD)

$(CMD):$(OBJS)
	$(FC) $^ -fopenmp -o $(OUTFOLD)/$@

%.o: %.f90
	$(FC) $(FFLAGS) -fopenmp -c $(@F:.o=.f90) -o $@
%.o: %.f
	$(FC) $(FFLAGS) -fopenmp -c $(@F:.o=.f) -o $@

clean:
	rm -f *.o $(OUTFOLD)/$(CMD) *.mod
