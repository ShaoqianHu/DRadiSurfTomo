   subroutine CalRadAniG(nx, ny, nz, maxvp, vsf, gam, &
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
                         narR, narL, iwR, iwL, &
                         rwR, rwL, &
                         colR, colL, &
                         writepath, maxnar)


   implicit none
   integer nx, ny, nz, maxvp, kmaxRc, kmaxRg, kmaxLc, kmaxLg
   integer kmaxR, kmaxL
   real vsf(nx,ny,nz), gam(nx,ny,nz)
   real dsynR(*), dsynL(*) 
   real goxd, gozd, dvxd, dvzd
   real*8 tRc(*), tRg(*), tLc(*), tLg(*)
   integer wavetypeR(nsrc,kmaxR), wavetypeL(nsrc,kmaxL)
   integer igrtR(nsrc,kmaxR), igrtL(nsrc,kmaxL)
   integer periodsR(nsrc,kmaxR), periodsL(nsrc,kmaxL)
   real depz(nz)
   real minthk
   real scxfR(nsrc,kmaxR), sczfR(nsrc,kmaxR)
   real scxfL(nsrc,kmaxL), sczfL(nsrc,kmaxL)
   real rcxfR(nrc, nsrc, kmaxR), rczfR(nrc, nsrc, kmaxR)
   real rcxfL(nrc, nsrc, kmaxL), rczfL(nrc, nsrc, kmaxL)
   integer nrc1R(nsrc,kmaxR), nsrc1R(kmaxR)
   integer nrc1L(nsrc,kmaxL), nsrc1L(kmaxL)
   integer nsrc, nrc
   integer narR, narL
   integer iwR(*), iwL(*), colR(*), colL(*)
   real rwR(*), rwL(*)
   integer writepath
   integer maxnar

   ! auxillary variables
   integer i, j, k
   real,dimension(:,:,:),allocatable::vsv, vsh
   integer checkstat
   real*8,dimension(:),allocatable:: dum
   integer mmaxvp

   allocate(vsv(nx,ny,nz), vsh(nx,ny,nz),stat=checkstat)  

   do i=1,nx
      do j=1,ny
         do k=1,nz
            vsv(i,j,k)=vsf(i,j,k)
            vsh(i,j,k)=vsf(i,j,k)*gam(i,j,k)
         enddo
      enddo
   enddo
   mmaxvp=maxvp/2

   call CalSurfG(nx,ny,nz,mmaxvp,vsv,iwR,rwR,colR,dsynR,&
                 goxd,gozd,dvxd,dvzd,kmaxRc,kmaxRg,0,0,&
                 tRc,tRg,dum,dum,wavetypeR,igrtR,periodsR,depz,minthk,&
                 scxfR,sczfR,rcxfR,rczfR,nrc1R,nsrc1R,kmaxR,&
                 nsrc,nrc,narR,writepath)

   call CalSurfG(nx,ny,nz,mmaxvp,vsh,iwL,rwL,colL,dsynL,&
                 goxd,gozd,dvxd,dvzd,0,0,kmaxLc,kmaxLg,&
                 dum,dum,tLc,tLg,wavetypeL,igrtL,periodsL,depz,minthk,&
                 scxfL,sczfL,rcxfL,rczfL,nrc1L,nsrc1L,kmaxL,&
                 nsrc,nrc,narL,writepath)

   ! deallocate variables
   deallocate(vsv,vsh)

   end subroutine





