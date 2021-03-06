   program DRadiSurfTomo

   use lsmrModule, only:lsmr
   use lsmrblasInterface, only: dnrm2
   implicit none

   ! define variable
   ! file
   character inputfile*80
   character logfile*100
   character outmodel*100
   character outsyn*100
   logical ex ! if file exsit
   character dummy*40
   character datafileR*80
   character datafileL*80

   ! model
   integer nx,ny,nz ! dimension of model
   real goxd, gozd
   real dvxd, dvzd
   real, dimension(:), allocatable:: depz

   ! data
   integer nsrc, nrc
   integer kmax, kmaxRc, kmaxRg, kmaxLc, kmaxLg ! num of periods
   real*8,dimension(:), allocatable:: tRc, tRg, tLc, tLg ! periods

   ! inversion 
   real lambda1, lambda2 ! damp for different parameters, see note
   real weight1, weight2
   integer itn ! iteration for large matrix inversion
   integer iter, maxiter ! iteration number
   real minthk
   integer nout
   real sta1_lat, sta1_lon, sta2_lat, sta2_lon
   integer dall, dallR, dallL
   real,parameter:: pi=3.1415926535898
   integer checkstat
   real,dimension(:),allocatable:: dsyn, cbst, wt, dtres, datweight
   real,dimension(:),allocatable:: dsynR, dsynL
   real,dimension(:),allocatable:: distR, distL, obstR, obstL
   real,dimension(:),allocatable:: pvallR, pvallL, depRp
   real, dimension (:,:), allocatable :: scxfR,sczfR, scxfL, sczfL
   real, dimension (:,:,:), allocatable :: rcxfR,rczfR, rcxfL, rczfL
   integer,dimension(:,:),allocatable::wavetypeR,igrtR,nrc1R
   integer,dimension(:,:),allocatable::wavetypeL,igrtL,nrc1L
   integer,dimension(:),allocatable::nsrc1R, nsrc1L
   integer,dimension(:,:),allocatable::periodsR, periodsL
   real,dimension(:),allocatable::rwR, rwL, rw
   integer,dimension(:),allocatable::iwR, iwL,colR, colL, iw, col
   real,dimension(:),allocatable::dv,norm
   real,dimension(:,:,:),allocatable::vsf, gam
   real,dimension(:,:,:),allocatable::vsftrue, gamtrue
   integer veltp, wavetp
   integer ifsyn  
   real noiselevel
   real spfra
   real Minvel, Maxvel, Mingam, Maxgam
   real threshold0, threshold
   integer maxnar, maxvp
   integer writepath
   integer narR, narL, nar
   integer lenrw,leniw
   real atol,btol
   real conlim
   integer istop
   integer itnlim, localSize
   real acond, anorm, xnorm
   real damp, rnorm, arnorm
   real mean,std_devs
   integer m,n

   ! auxillary variable
   integer ii, jj, kk
   integer i, j, k
   real velvalue
   integer knum, knumo, err
   integer istep, istep1, istep2
   integer period
   character line*200
   character str1
   real dist1
   integer kmaxR, kmaxL
   integer nvx, nvy, nvz
   integer count3, count4
   real, parameter::coef=8.0
   real rough1, rough2

   ! open files 
   open(34,file='IterVel.out') 
   nout=36
   open(nout,file='lsmr.txt')

   ! output some information
   write(*,*)
   write(*,*),'                    DRadiSurfTomo (2021/08/08)' 
   write(*,*)

   ! read input file
   if (iargc()<1) then
      write(*,*) 'input file [DRadiSurfTomo.in(default)]'
      read(*,'(a)') inputfile
      if (len_trim(inputfile)<=1) then
         inputfile='DRadiSurfTomo.in'
      else
         inputfile=inputfile(1:len_trim(inputfile))
      endif
   else
         call getarg(1,inputfile)
   endif
   inquire(file=inputfile,exist=ex)
   if(.not. ex) stop 'unable to open the inputfile (*.in)'

   open(10,file=inputfile,status='old')
   read(10,'(a30)')dummy
   read(10,'(a30)')dummy
   read(10,'(a30)')dummy
   read(10,*)datafileR
   read(10,*)datafileL
   read(10,*)nx, ny, nz
   read(10,*)goxd,gozd
   read(10,*)dvxd,dvzd
   read(10,*)nsrc
   read(10,*)lambda1, lambda2, damp
   read(10,*)minthk
   read(10,*)Minvel, Maxvel
   read(10,*)Mingam, Maxgam
   read(10,*)maxiter
   read(10,*)spfra
   read(10,*)kmaxRc
       if(kmaxRc.gt.0) then
          allocate(tRc(kmaxRc),stat=checkstat)
          if (checkstat > 0) stop 'error allocating tRc'
          read(10,*)(tRc(i),i=1,kmaxRc)
          write(*,*) 'Rayleigh wave phase velocity used, periods:(s)'
          write(*,'(50f6.2)')(tRc(i),i=1,kmaxRc)
       endif
   read(10,*)kmaxRg
       if(kmaxRg.gt.0) then
          allocate(tRg(kmaxRg),stat=checkstat)
          if (checkstat > 0) stop 'error allocating tRg'
          read(10,*)(tRg(i),i=1,kmaxRg)
          write(*,*) 'Rayleigh wave group velocity used, periods:(s)'
          write(*,'(50f6.2)')(tRg(i),i=1,kmaxRg)
       endif
   read(10,*)kmaxLc
       if(kmaxLc.gt.0) then
          allocate(tLc(kmaxLc),stat=checkstat)
          if (checkstat > 0) stop 'error allocating tLc'
          read(10,*)(tLc(i),i=1,kmaxLc)
          write(*,*) 'Love wave phase velocity used, periods:(s)'
          write(*,'(50f6.2)')(tLc(i),i=1,kmaxLc)
       endif
   read(10,*)kmaxLg
       if(kmaxLg.gt.0) then
          allocate(tLg(kmaxLg),stat=checkstat)
          if (checkstat > 0) stop 'error allocating tLg'
          read(10,*)(tLg(i),i=1,kmaxLg)
          write(*,*) 'Love wave group velocity used, periods:(s)'
          write(*,'(50f6.2)')(tLg(i),i=1,kmaxLg)
       endif
   read(10,*)ifsyn
   read(10,*)noiselevel
   read(10,*)threshold0
   close(10)
   nvx=nx-2;
   nvy=ny-2;
   nvz=nz-1;
   nrc=nsrc
   kmax=kmaxRc+kmaxRg+kmaxLc+kmaxLg 
   kmaxR=kmaxRc+kmaxRg
   kmaxL=kmaxLc+kmaxLg

   ! read measurements 
   open(unit=87,file=datafileR,status='old') 
   allocate(scxfR(nsrc,kmaxR),sczfR(nsrc,kmaxR), stat=checkstat)
   allocate(scxfL(nsrc,kmaxL),sczfL(nsrc,kmaxL), stat=checkstat)
   if(checkstat>0)then
      write(*,*)'error allocate scxf and sczf'
   endif
   allocate(rcxfR(nrc,nsrc,kmaxR),rczfR(nrc,nsrc,kmaxR),stat=checkstat)
   allocate(rcxfL(nrc,nsrc,kmaxL),rczfL(nrc,nsrc,kmaxL),stat=checkstat)
   if(checkstat>0)then
      write(*,*)'error allocate rcxf and rczf'
   endif
   allocate(periodsR(nsrc,kmaxR),wavetypeR(nsrc,kmaxR),&
            nrc1R(nsrc,kmaxR),nsrc1R(kmaxR),&
            igrtR(nsrc,kmaxR),stat=checkstat)
   allocate(periodsL(nsrc,kmaxL),wavetypeL(nsrc,kmaxL),&
            nrc1L(nsrc,kmaxL),nsrc1L(kmaxL),&
            igrtL(nsrc,kmaxL),stat=checkstat)
   if(checkstat>0)then
      write(*,*)'error allocate periods, wavetype nrc1, nsrc1, igrt'
   endif
   allocate(obstR(nrc*nsrc*kmaxR),distR(nrc*nsrc*kmaxR),&
            stat=checkstat)
   allocate(obstL(nrc*nsrc*kmaxL),distL(nrc*nsrc*kmaxL),&
            stat=checkstat)
   if(checkstat>0)then
      write(*,*)'error allocate obst, dist '
   endif
   allocate(pvallR(nrc*nsrc*kmaxR),depRp(nrc*nsrc*kmax),&
            pvallL(nrc*nsrc*kmaxL), &
            stat=checkstat)
   if(checkstat>0)then
      write(*,*)'error allocate pvall, depRp'
   endif

   ! read Rayleigh wave
   istep=0
   istep1=0
   istep2=0
   dall=0
   knumo=12345
   knum=0
   do
     read(87,'(a)',iostat=err) line
     if(err.eq.0)then
       if(line(1:1).eq.'#')then
          read(line,*)str1,sta1_lat,sta1_lon,period,wavetp,veltp
          if(wavetp.eq.2.and.veltp.eq.0) knum=period
          if(wavetp.eq.2.and.veltp.eq.1) knum=kmaxRc+period
          if(knum.ne.knumo)then
             istep=0
             istep2=istep2+1
          endif
          istep=istep+1
          istep1=0
          sta1_lat=(90.0-sta1_lat)*pi/180.0
          sta1_lon=sta1_lon*pi/180.0
          scxfR(istep,knum)=sta1_lat
          sczfR(istep,knum)=sta1_lon
          periodsR(istep,knum)=period
          wavetypeR(istep,knum)=wavetp
          igrtR(istep,knum)=veltp
          nsrc1R(knum)=istep
          knumo=knum
       else
          read(line,*) sta2_lat,sta2_lon,velvalue
          istep1=istep1+1
          dall=dall+1
          sta2_lat=(90.0-sta2_lat)*pi/180.0
          sta2_lon=sta2_lon*pi/180.0
          rcxfR(istep1,istep,knum)=sta2_lat
          rczfR(istep1,istep,knum)=sta2_lon
          call delsph(sta1_lat,sta1_lon,sta2_lat,sta2_lon,dist1)
          distR(dall)=dist1
          obstR(dall)=dist1/velvalue
          pvallR(dall)=velvalue
          nrc1R(istep,knum)=istep1 
       endif
     else
       exit
     endif
   enddo
   close(87)
   dallR=dall
   write(*,'(a,i7)')'# Rayleigh wave measurements:', dallR

   ! read Love wave
   open(unit=97,file=datafileL,status='old') 
   istep=0
   istep1=0
   istep2=0
   dall=0
   knumo=12345
   knum=0
   do
     read(97,'(a)',iostat=err) line
     if(err.eq.0)then
       if(line(1:1).eq.'#')then
          read(line,*)str1,sta1_lat,sta1_lon,period,wavetp,veltp
          if(wavetp.eq.1.and.veltp.eq.0) knum=period
          if(wavetp.eq.1.and.veltp.eq.1) knum=kmaxLc+period
          if(knum.ne.knumo)then
             istep=0
             istep2=istep2+1
          endif
          istep=istep+1
          istep1=0
          sta1_lat=(90.0-sta1_lat)*pi/180.0
          sta1_lon=sta1_lon*pi/180.0
          scxfL(istep,knum)=sta1_lat
          sczfL(istep,knum)=sta1_lon
          periodsL(istep,knum)=period
          wavetypeL(istep,knum)=wavetp
          igrtL(istep,knum)=veltp
          nsrc1L(knum)=istep
          knumo=knum
       else
          read(line,*) sta2_lat,sta2_lon,velvalue
          istep1=istep1+1
          dall=dall+1
          sta2_lat=(90.0-sta2_lat)*pi/180.0
          sta2_lon=sta2_lon*pi/180.0
          rcxfL(istep1,istep,knum)=sta2_lat
          rczfL(istep1,istep,knum)=sta2_lon
          call delsph(sta1_lat,sta1_lon,sta2_lat,sta2_lon,dist1)
          distL(dall)=dist1
          obstL(dall)=dist1/velvalue
          pvallL(dall)=velvalue
          nrc1L(istep,knum)=istep1
       endif
     else
       exit
     endif
   enddo
   close(97)
   dallL=dall
   write(*,'(a,i7)')'# Love wave measurements    :', dallL
   dall=dallR+dallL

   ! allocate for inversion
   allocate(depz(nz),stat=checkstat)
   maxnar=spfra*dall*nx*ny*nz*2
   maxvp=(nx-2)*(ny-2)*(nz-1)*2
   allocate(dv(maxvp), stat=checkstat)
   allocate(norm(maxvp), stat=checkstat)
   allocate(vsf(nx,ny,nz), stat=checkstat)
   allocate(gam(nx,ny,nz), stat=checkstat)
   allocate(vsftrue(nx,ny,nz), stat=checkstat)
   allocate(gamtrue(nx,ny,nz), stat=checkstat)

   allocate(rwR(maxnar),stat=checkstat)
   allocate(rwL(maxnar),stat=checkstat)
   allocate(rw(maxnar),stat=checkstat)
   if(checkstat>0)then
      write(*,*)'error allocate rw'
   endif
   allocate(iwR(2*maxnar+1),stat=checkstat) 
   allocate(iwL(2*maxnar+1),stat=checkstat) 
   allocate(iw(2*maxnar+1),stat=checkstat) 
   if(checkstat>0)then
      write(*,*)'error allocate iw'
   endif
   allocate(colR(maxnar),stat=checkstat) 
   allocate(colL(maxnar),stat=checkstat) 
   allocate(col(maxnar),stat=checkstat) 
   if(checkstat>0)then
      write(*,*)'error allocate col'
   endif
   allocate(cbst(dall+maxvp),dsyn(dall),datweight(dall),wt(dall+maxvp),&
            dtres(dall+maxvp),stat=checkstat)  
   allocate(dsynR(dallR+maxvp),dsynL(dallL+maxvp),stat=checkstat)  

   write(*,'(a,i7)')'# Number wave measurements  :', dall

   ! read initial model
   open(10,file='MOD.Vsv',status='old')
   read(10,*)(depz(i),i=1,nz)
   do k=1,nz
      do j=1,ny
         read(10,*)(vsf(i,j,k),i=1,nx)
      enddo
   enddo
   close(10)
   open(20,file='MOD.gam',status='old') ! define gamma=vsh/vsv
   read(20,*)(depz(i),i=1,nz)
   do k=1,nz
      do j=1,ny
         read(20,*)(gam(i,j,k),i=1,nx)
      enddo
   enddo
   close(20)
   write(*,*)'grid points in depth direction: (km)'
   write(*,'(50f8.2)') depz

   ! checkerboard test
   if (ifsyn==1)then
       write(*,*)'checkerboard resolution test begin'
       vsftrue=vsf
       gamtrue=gam

       open(11,file='MOD.true.Vsv')
       do k=1,nz
          do j=1,ny
             read(11,*)(vsftrue(i,j,k),i=1,nx)
          enddo
       enddo
       close(11)
       open(22,file='MOD.true.gam')
       do k=1,nz
          do j=1,ny
             read(22,*)(gamtrue(i,j,k),i=1,nx)
          enddo
       enddo
       close(22)

       ! forward simulation
       call synRadAni(nx,ny,nz,maxvp,&
                      vsftrue,gamtrue,obstR, obstL, &
                      goxd,gozd,dvxd,dvzd, &
                      kmaxRc, kmaxRg, kmaxLc, kmaxLg, kmaxR, kmaxL, &
                      tRc, tRg, tLc, tLg, wavetypeR, wavetypeL, &
                      igrtR, igrtL, periodsR, periodsL, &
                      depz,minthk, &
                      scxfR, sczfR, rcxfR, rczfR, &
                      scxfL, sczfL, rcxfL, rczfL, &
                      nsrc1R, nsrc1L, nrc1R, nrc1L, &
                      nsrc, nrc, noiselevel)
   endif
   
   ! iterate until converge
   writepath = 0
   do iter=1,maxiter
      iwR = 0
      rwR = 0
      colR = 0
      iwL = 0
      rwL = 0
      colL = 0
 
      ! compute sensitivity matrix
      if (iter==maxiter) then
         writepath = 1
         ! open(40, file='raypath.out')
      endif
      write(*,'(a,i4)') '### Iteration :', iter
      write(*,*) 'computing sensitivity matrix ...'
      call CalRadAniG(nx, ny, nz, maxvp, vsf, gam, &
                      dsynR, dsynL, &
                      goxd, gozd, dvxd, dvzd, &
                      kmaxRc, kmaxRg, kmaxLc, kmaxLg, &
                      tRc, tRg, tLc, tLg, &
                      wavetypeR, wavetypeL, &
                      igrtR, igrtL, periodsR, periodsL, &
                      depz, minthk, &
                      scxfR, sczfR, scxfL, sczfL, &
                      rcxfR, rczfR, rcxfL, rczfL, &
                      nrc1R, nrc1L, nsrc1R, nsrc1L, &
                      kmaxR, kmaxL, nsrc, nrc, &
                      narR, narL, iwR, iwL, rwR, rwL, colR, colL, &
                      writepath, maxnar)

      do i=1,dallR
         cbst(i)=obstR(i)-dsynR(i)
      enddo
      do i=dallR+1,dallR+dallL
         cbst(i)=obstL(i-dallR)-dsynL(i-dallR)
      enddo
 
      threshold=threshold+(maxiter/2-iter)/3*0.5
      do i=1,dall
         ! compute weight for the data
         datweight(i)=1.0
         if(abs(cbst(i))>threshold) then
      !      datweight(i)=exp(-abs(cbst(i)-threshold))
             ! fortest
             datweight(i)=1
             ! end fortest
         endif
         cbst(i)=cbst(i)*datweight(i)
      enddo
      do i=1,narR ! weight the G matrix every row
         rwR(i)=rwR(i)*datweight(iwR(1+i))
      enddo
      do i=1,narL ! weight the G matrix every row
         rwL(i)=rwL(i)*datweight(iwL(1+i))
      enddo

      ! assemble (rwR, rwL) --> rw; (iwR, iwL) --> iw; (colR, colL) --> col
      ! rw, col, iw
      iwL(1)=narL
      iwR(1)=narR
      iw(1)=narR+narL*2
      nar=iw(1)
    
      do i=1,iwR(1)
         iw(i+1)=iwR(i+1)
         col(i)=colR(i)
         rw(i)=rwR(i)
      enddo
      do i=1,iwL(1)
         iw(i+iwR(1)+1)=iwL(i+1)+dallR
         col(i+iwR(1))=colL(i)
         iw(i+iwR(1)+1+iwL(1))=iwL(i+1)+dallR
         col(i+iwR(1)+iwL(1))=colL(i)+maxvp/2
         ii=mod(mod(colL(i),nvy*nvx),nvx)
         if (ii.eq.0) ii=nvx
         jj=mod((colL(i)-ii)/nvx,nvy)+1
         kk=(colL(i)-ii-(jj-1)*nvx)/nvx/nvy+1
         rw(i+iwR(1))=gam(ii+1,jj+1,kk)*rwL(i)
         rw(i+iwR(1)+iwL(1))=vsf(ii+1,jj+1,kk)*rwL(i)/coef
      enddo
 
      ! then add regularization term
      weight1=dnrm2(dallR,cbst(1:dallR),1)**2/dallR*lambda1
      weight2=dnrm2(dallL,cbst(dallR+1:dallR+dallL),1)**2/dallL*lambda2/coef
      
      ! smoothing lambda1
      count3=0
      do k=1,nvz
         do j=1,nvy
            do i=1,nvx
               if(i==1.or.i==nvx.or.j==1.or.j==nvy.or.k==1.or.k==nvz)then
                  count3=count3+1
                  col(nar+1)=(k-1)*nvy*nvx+(j-1)*nvx+i
                  rw(nar+1)=2.0*weight1
                  iw(1+nar+1)=dall+count3
                  cbst(dall+count3)=0.0
                  nar=nar+1
               else
                  count3=count3+1
                  col(nar+1)=(k-1)*nvy*nvx+(j-1)*nvx+i
                  rw(nar+1)=6.0*weight1
                  iw(1+nar+1)=dall+count3
                  rw(nar+2)=-1.0*weight1
                  iw(1+nar+2)=dall+count3
                  col(nar+2)=(k-1)*nvy*nvx+(j-1)*nvx+i-1
                  rw(nar+3)=-1.0*weight1
                  iw(1+nar+3)=dall+count3
                  col(nar+3)=(k-1)*nvy*nvx+(j-1)*nvx+i+1
                  rw(nar+4)=-1.0*weight1
                  iw(1+nar+4)=dall+count3
                  col(nar+4)=(k-1)*nvy*nvx+(j-2)*nvx+i
                  rw(nar+5)=-1.0*weight1
                  iw(1+nar+5)=dall+count3
                  col(nar+5)=(k-1)*nvy*nvx+j*nvx+i
                  rw(nar+6)=-1.0*weight1
                  iw(1+nar+6)=dall+count3
                  col(nar+6)=(k-2)*nvy*nvx+(j-1)*nvx+i
                  rw(nar+7)=-1.0*weight1
                  iw(1+nar+7)=dall+count3
                  col(nar+7)=k*nvy*nvx+(j-1)*nvx+i
                  cbst(dall+count3)=0
                  nar=nar+7
               endif
            enddo
         enddo
      enddo 

      ! smoothing lambda2
      count4=0
      do k=1,nvz
         do j=1,nvy
            do i=1,nvx
               if(i==1.or.i==nvx.or.j==1.or.j==nvy.or.k==1.or.k==nvz)then
                  count4=count4+1
                  col(nar+1)=(k-1)*nvy*nvx+(j-1)*nvx+i+maxvp/2
                  rw(nar+1)=2.0*weight2
                  iw(1+nar+1)=dall+count4
                  cbst(dall+count4)=0.0
                  nar=nar+1
               else
                  count4=count4+1
                  col(nar+1)=(k-1)*nvy*nvx+(j-1)*nvx+i+maxvp/2
                  rw(nar+1)=6.0*weight2
                  iw(1+nar+1)=dall+count4
                  rw(nar+2)=-1.0*weight2
                  iw(1+nar+2)=dall+count4
                  col(nar+2)=(k-1)*nvy*nvx+(j-1)*nvx+i-1+maxvp/2
                  rw(nar+3)=-1.0*weight2
                  iw(1+nar+3)=dall+count4
                  col(nar+3)=(k-1)*nvy*nvx+(j-1)*nvx+i+1+maxvp/2
                  rw(nar+4)=-1.0*weight2
                  iw(1+nar+4)=dall+count4
                  col(nar+4)=(k-1)*nvy*nvx+(j-2)*nvx+i+maxvp/2
                  rw(nar+5)=-1.0*weight2
                  iw(1+nar+5)=dall+count4
                  col(nar+5)=(k-1)*nvy*nvx+j*nvx+i+maxvp/2
                  rw(nar+6)=-1.0*weight2
                  iw(1+nar+6)=dall+count4
                  col(nar+6)=(k-2)*nvy*nvx+(j-1)*nvx+i+maxvp/2
                  rw(nar+7)=-1.0*weight2
                  iw(1+nar+7)=dall+count4
                  col(nar+7)=k*nvy*nvx+(j-1)*nvx+i+maxvp/2
                  cbst(dall+count4)=0
                  nar=nar+7
               endif
            enddo
         enddo
      enddo

      !
      m=dall+count3+count4
      n=maxvp

      iw(1)=nar
      do i=1,nar
         iw(1+nar+i)=col(i)
      enddo
      if (nar > maxnar) stop 'increase sparsity fraction (spfra)'

      ! call LSMR for inversion, we need iw, rw, cbst, 
      leniw=2*nar+1
      lenrw=nar
      dv=0
      atol=1e-3      
      btol=1e-3 
      conlim=1200
      itnlim=1000
      istop =0
      anorm =0.0
      acond =0.0
      arnorm=0.0
      xnorm =0.0     
      localSize=10
      !damp=0.0 ! see explanation of LSMR in lsmrModule.f90 

      call LSMR(m, n, leniw, lenrw, iw, rw, cbst, damp, &
                atol, btol, conlim, itnlim, localSize, nout, &
                dv, istop, itn, anorm, acond, rnorm, arnorm, xnorm)
      if(istop==3) print*,'istop = 3, large condition number'

      do i=1,dall
         cbst(i)=cbst(i)/datweight(i)
      enddo


      ! check the update
      ! and update Vsv and gamma
      do k=1,nvz
         do j=1,nvy
            do i=1,nvx
               if(dv((k-1)*nvx*nvy+(j-1)*nvx+i).ge. 0.500) then
                 dv((k-1)*nvx*nvy+(j-1)*nvx+i)=0.500
               endif
               if(dv((k-1)*nvx*nvy+(j-1)*nvx+i).le. -0.500) then
                 dv((k-1)*nvx*nvy+(j-1)*nvx+i)=-0.500
               endif
               vsf(i+1,j+1,k)=vsf(i+1,j+1,k)+dv((k-1)*nvx*nvy+(j-1)*nvx+i)
               if(vsf(i+1,j+1,k).lt.Minvel) vsf(i+1,j+1,k)=Minvel
               if(vsf(i+1,j+1,k).gt.Maxvel) vsf(i+1,j+1,k)=Maxvel
            enddo
         enddo
      enddo

      do k=1,nvz
         do j=1,nvy
            do i=1,nvx
               if(dv((k-1)*nvx*nvy+(j-1)*nvx+i+maxvp/2).ge. 0.10*coef) then
                 dv((k-1)*nvx*nvy+(j-1)*nvx+i+maxvp/2)=0.10*coef
               endif
               if(dv((k-1)*nvx*nvy+(j-1)*nvx+i+maxvp/2).le.-0.10*coef) then
                 dv((k-1)*nvx*nvy+(j-1)*nvx+i+maxvp/2)=-0.10*coef
               endif
               gam(i+1,j+1,k)=gam(i+1,j+1,k)+dv((k-1)*nvx*nvy+ &
                              (j-1)*nvx+i+maxvp/2)/coef
               if(gam(i+1,j+1,k).lt.Mingam) gam(i+1,j+1,k)=Mingam
               if(gam(i+1,j+1,k).gt.Maxgam) gam(i+1,j+1,k)=Maxgam
            enddo
         enddo
      enddo 

      ! output Vsv and gamma
      write(*,*)'output Vsv at iteration', iter
      write(outmodel,'(a,a,i3.3)')trim(inputfile),'Measure.dat.iter',iter
      open(64,file=outmodel)
      do k=1,nvz
         do j=1,nvy
            do i=1,nvx
               write(64,'(6f10.4)')gozd+(j-1)*dvzd, goxd-(i-1)*dvxd, depz(k), vsf(i+1,j+1,k), gam(i+1,j+1,k)
            enddo
         enddo
      enddo
      close(64)

      ! compute the Lm|_2 term (for L curve analysis)
      rough1=0.0
      do k=1,nvz
         do j=1,nvy
            do i=1,nvx
               if(k.ne.1)then
                  rough1=rough1+(vsf(i+2,j+1,k)+vsf(i+1,j+2,k)+ &
                     vsf(i+1,j+1,k+1)+vsf(i,j+1,k)+vsf(i+1,j,k)+ &
                     vsf(i+1,j+1,k-1)-6.0*vsf(i+1,j+1,k))**2
               else
                  rough1=rough1+(vsf(i+2,j+1,k)+vsf(i+1,j+2,k)+ &
                     vsf(i+1,j+1,k+1)+vsf(i,j+1,k)+vsf(i+1,j,k)+ &
                     -5.0*vsf(i+1,j+1,k))**2
               endif
            enddo
         enddo
      enddo
      rough1=sqrt(rough1)

      rough2=0.0
      do k=1,nvz
         do j=1,nvy
            do i=1,nvx
               if(k.ne.1)then
                  rough2=rough2+(gam(i+2,j+1,k)+gam(i+1,j+2,k)+ &
                     gam(i+1,j+1,k+1)+gam(i,j+1,k)+gam(i+1,j,k)+ &
                     gam(i+1,j+1,k-1)-6.0*gam(i+1,j+1,k))**2
               else
                  rough2=rough2+(gam(i+2,j+1,k)+gam(i+1,j+2,k)+ &
                     gam(i+1,j+1,k+1)+gam(i,j+1,k)+gam(i+1,j,k)+ &
                     -5.0*gam(i+1,j+1,k))**2
               endif
            enddo
         enddo
      enddo
      rough2=sqrt(rough2)

      ! output information for each iteration
      mean=sum(cbst(1:dall))/dall 
      std_devs=sqrt(sum(cbst(1:dall)**2)/dall-mean**2)
      write(*,'(i2,a)'), iter, 'th iteration ...'
      write(*,'(a,2f12.4)'), 'weight1 and weight2 are:            ', weight1, weight2
      write(*,'(a,f12.4,f12.4,f12.4)'), 'mean, std_devs and rms of &
           residual: ', mean*1000, 1000*std_devs, &
           dnrm2(dall,cbst,1)/sqrt(real(dall)) 
      write(*,'(a,f12.4,f12.4)'), 'Roughness of the model              ', rough1, rough2
      ! output to IterVel.out
      write(34,'(i2,a)'), iter, 'th iteration ...'
      write(34,'(a,2f12.4)'), 'weight1 and weight2 are:            ', weight1, weight2
      write(34,'(a,f12.4,f12.4,f12.4)'), 'mean, std_devs and rms of &
           residual: ', mean*1000, 1000*std_devs, &
           dnrm2(dall,cbst,1)/sqrt(real(dall)) 
      write(34,'(a,f12.4,f12.4)'), 'Roughness of the model              ', rough1, rough2
     
      ! output min and max variations 
      write(*,'(a,2f12.4)'),'min and max velocity variation      ',&
      minval(dv(1:maxvp/2)),maxval(dv(1:maxvp/2))
      write(*,'(a,2f12.4)'),'min and max gamma variation         ',&
      minval(dv(maxvp/2:maxvp))/coef,maxval(dv(maxvp/2:maxvp))/coef

   enddo ! end iteration

   ! post-inversion 
   ! output the final vsv and gamma
   write(*,*),'Program finished successfully'

   if(ifsyn==1) then
      open(65,file='RAmodel.real')
      write(outsyn,'(a,a)')trim(inputfile),'Syn.dat'
      open(63,file=outsyn)
      do k=1,nvz
         do j=1,nvy
            do i=1,nvx
               write(65,'(6f10.4)') gozd+(j-1)*dvzd,goxd-(i-1)*dvxd,depz(k),vsftrue(i+1,j+1,k), gamtrue(i+1,j+1,k)
               write(63,'(6f10.4)') gozd+(j-1)*dvzd,goxd-(i-1)*dvxd,depz(k),vsftrue(i+1,j+1,k), gamtrue(i+1,j+1,k)
            enddo
         enddo
      enddo
      close(65)
      close(63)
      write(*,*),'Output true model RAmodel.real'
      write(*,*),'Output inverted model to ', outsyn
   else
      write(outmodel,'(a,a)')trim(inputfile),'Measure.dat'
      open(64,file=outmodel)
      do k=1,nvz
         do j=1,nvy
            do i=1,nvx
               write(64,'(6f10.4)') gozd+(j-1)*dvzd, goxd-(i-1)*dvxd,depz(k), vsf(i+1,j+1,k), gam(i+1,j+1,k)
            enddo
         enddo
      enddo
      close(64)
   endif

   close(nout)
   close(34)
 
   ! deallocate variables
   deallocate(scxfR,sczfR, scxfL, sczfL)
   deallocate(rcxfR,rczfR, rcxfL, rczfL)
   deallocate(periodsR, periodsL)
   deallocate(wavetypeR,wavetypeL)
   deallocate(nrc1R,nrc1L)
   deallocate(nsrc1R,nsrc1L)
   deallocate(igrtR,igrtL)
   deallocate(obstR,obstL,distR, distL)
   deallocate(pvallR, pvallL,depRp)
   deallocate(depz)
   deallocate(dv,norm,vsf,gam,vsftrue,gamtrue)
   deallocate(rwR,iwR,colR,cbst,dsynR,datweight,wt,dtres)
   deallocate(rwL,iwL,colL,dsynL)
   if(kmaxRc.gt.0) then
     deallocate(tRc)
   endif
   if(kmaxRg.gt.0) then
     deallocate(tRg)
   endif
   if(kmaxLc.gt.0) then
     deallocate(tLc)
   endif
   if(kmaxLg.gt.0) then
     deallocate(tLg)
   endif


   end program
  


 
