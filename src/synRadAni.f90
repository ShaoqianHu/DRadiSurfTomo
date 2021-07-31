   subroutine synRadAni( nx, ny, nz, maxvp,&
                         vsftrue, gamtrue, obstR, obstL,&
                         goxd,gozd,dvxd,dvzd, &
                         kmaxRc,kmaxRg,kmaxLc,kmaxLg,kmaxR, kmaxL,&
                         tRc,tRg,tLc,tLg,wavetypeR, wavetypeL, &
                         igrtR, igrtL, periodsR ,periodsL, &
                         depz,minthk,&
                         scxfR,sczfR,rcxfR,rczfR, &
                         scxfL,sczfL,rcxfL,rczfL, &
                         nsrc1R, nsrc1L,nrc1R, nrc1L, &
                         nsrc,nrc,noiselevel )

   implicit none
   integer nx, ny, nz, maxvp, kmaxRc, kmaxRg, kmaxLc, kmaxLg
   integer kmaxR, kmaxL
   real vsftrue(nx,ny,nz), gamtrue(nx,ny,nz)
   real obstR(*), obstL(*)
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
   real noiselevel
   integer nrc1R(nsrc,kmaxR), nsrc1R(kmaxR)
   integer nrc1L(nsrc,kmaxL), nsrc1L(kmaxL)
   integer nsrc, nrc   
   ! auxillary variable
   integer i, j, k  
   real,dimension(:,:,:),allocatable::vsv, vsh
   integer checkstat
   real*8,dimension(:),allocatable:: dum
   integer mmaxvp

   allocate(vsv(nx,ny,nz), vsh(nx,ny,nz),stat=checkstat) 

   ! obtain vsv, vsh
   do i=1,nx
      do j=1,ny
         do k=1,nz
            vsv(i,j,k)=vsftrue(i,j,k)
            vsh(i,j,k)=vsftrue(i,j,k)*gamtrue(i,j,k)
         enddo
      enddo
   enddo
   mmaxvp=maxvp/2

   call synthetic(nx,ny,nz,mmaxvp,vsv,obstR,&
                  goxd,gozd,dvxd,dvzd,kmaxRc,kmaxRg,0,0,&
                  tRc,tRg,dum,dum,wavetypeR,igrtR,periodsR,depz,minthk,&
                  scxfR,sczfR,rcxfR,rczfR,nrc1R,nsrc1R,kmaxR,&
                  nsrc,nrc,noiselevel)

   call synthetic(nx,ny,nz,mmaxvp,vsh,obstL,&
                  goxd,gozd,dvxd,dvzd,0,0,kmaxLc,kmaxLg,&
                  dum,dum,tLc,tLg,wavetypeL,igrtL,periodsL,depz,minthk,&
                  scxfL,sczfL,rcxfL,rczfL,nrc1L,nsrc1L,kmaxL,&
                  nsrc,nrc,noiselevel)

   ! deallocate variables
   deallocate(vsv,vsh) 
 
   end subroutine




