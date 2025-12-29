  !lower and upper certain from:https://doi.org/10.2307/2530610
  !pval estimated as:https://doi.org/10.1136/bmj.d2304
  !which is just the approximation:https://doi.org/10.2307/2347681
  !benjamini-hochberg (doi.org/10.1186/s13059-019-1716-1)
  !and i should flip all these index for better speed but... 
      real*8 rpv(949400,54),spv(949400),tpv(949400)!<-debug,raw and sorted pv, BH pushes back into rpv
      real*8 pdf(949400,54),sub(54,54),su(54),dubya(54),dubyaa(54),dis(54)
      real*8 pubya(54),pubyaa(54),zedl,zedu,darL,darU
      real*8 b(2,54),pv(54),zz,amax,pt,pc,ey,ex
      integer ispv(949400),lbg(949400),rbg(949400),ist(949400),ind(949400),inout(949400)
      integer nl(54),Reason,imax,nlin!23 is hard set to this number of units/files/samples
      character(len=33) :: offenders(949400,54)!23 again 
      character(len=7) :: unk(949400)
      character(len=33) :: header(54)
      character(len=1) :: pm(54)
      character(len=62) :: arg
      character(len=62) :: path(4)
      logical :: file_exists
      nfls=48 !patch on this
      do i=1,1!iargc()
         call getarg(i, arg)
         path(i)=arg
      enddo
!      call getarg(i, arg)
!      read(arg,*)ipeak
      
      zedl=2.575d0
      zedu=-2.575d0
      inquire(file=path(1),EXIST=file_exists)
      if(file_exists .eqv. .true.)then
         open(12,file=path(1))      
      else
         write(*,*) 'your first file or path is incorrect'
         stop
      endif
      open(13,file='linescounts')
      do i=1,nfls
         read(13,*) nl(i)
      enddo
      close(13)
      open(99,file='offndrs.'//TRIM(path(1)))            
      !get n=18 from argument and allocate things
      read(12,*,IOSTAT=Reason) (header(j),j=1,nfls+6)!unprotected technically
      !silent in debug
      write(*,*) (header(j),j=1,nfls+6)!unprotected technically

      nlin=0
      i=1
12345 continue
      read(12,*,IOSTAT=Reason) unk(i), ist(i), ind(i), (pdf(i,j),j=1,nfls), inout(i), lbg(i), rbg(i)
      if(Reason.eq.0.and.index(unk(i),'_').gt.0)then
         write(*,*) 'we need to filter odd chr names'
         stop
      endif
      if(Reason.gt.0)then
         write(*,*) 'there was an error in input file ', path(1)
      elseif(Reason.eq.0)then !new peak is loaded
         nlin=nlin+1
         i=i+1
         go to 12345
      endif
      !adjust for header
!      ipeak=ipeak-1
      !compute the pval and sort them, BH them, then process data
      !raw pv:
      su=0d0
      dis=0d0
      b=0d0
      do i=1,nlin!ipeak,ipeak!nlin
         pv=1d0
         k=0
         pm='.'
         do j=2,nfls!compare all to j=1
            pt=pdf(i,1)+1d-13
            pc=pdf(i,j)+1d-13
            ex=pt*nl(1)
            ey=pc*nl(j)
            !ln(peak_i/peak_j) - zedl (1/peak_i -1/N_i +1/peak_j-1/N_j)^1/2
            !~ln(p_i/p_j) - zedl (1/p_i + 1/p_j)
            
            darL=log(pt/pc)-zedl*sqrt((1d0-pt)/ex + (1d0-pc)/ey)
            darU=log(pt/pc)-zedu*sqrt((1d0-pt)/ex + (1d0-pc)/ey)
            b(1,j)=exp(darL)
            b(2,j)=exp(darU)
            zz=(log(pt/pc))/((darU-darL)/2d0/zedl)
            rpv(i,j)=min(1d0,exp(-0.717*zz-0.416*zz*zz))
         enddo
      enddo
!for debug
!      do i=1,nlin
!         tpv(i)=rpv(i,2)
!      enddo
      !now sort the rpv into spv for BH application
      do j=2,nfls !this was 2 for debugs i guess?
         do l=1,nlin
         amax=-0.1d0
         imax=0
         do i=1,nlin
            if(amax.le.rpv(i,j))then
               amax=rpv(i,j)
               imax=i
            endif
         enddo!i
         rpv(imax,j)=-1d0!remove from sorting
         spv(l)=amax
         ispv(l)=imax
         enddo!l
         !the jth pair is sorted, BH:
         rpv(ispv(1),j)=spv(1)
         do l=nlin,1,-1!2,nlin
!            rpv(ispv(l),j)=min(spv(l-1),spv(l)*(dble(nlin)/dble(nlin-(l-1))))
            if(spv(l).lt..05*(nlin-l+1)/dble(nlin))then!is ok, 5% FDR is set by the .05 here.
               rpv(ispv(l),j)=0.001d0
            else
               rpv(ispv(l),j)=1d0
            endif
         enddo!push sort, l
      enddo!j
!debug
!      do i=nlin,1,-1
!      write(*,*) i, spv(i), nlin-i+1, .25*(nlin-i+1)/dble(nlin), tpv(ispv(i)), ispv(i)!rpv(i,2), tpv(i)
!      enddo
!      stop !sort BH test
      su=0d0
      dis=0d0
      b=0d0
     
      do i=1,nlin!ipeak,ipeak!nlin
         pv=1d0
         k=0
         pm='.'
         do j=2,nfls!compare all to j=1
            pt=pdf(i,1)+1d-13
            pc=pdf(i,j)+1d-13
!            ex=pt*nl(1)
!            ey=pc*nl(j)
            !ln(peak_i/peak_j) - zedl (1/peak_i -1/N_i +1/peak_j-1/N_j)^1/2
            !~ln(p_i/p_j) - zedl (1/p_i + 1/p_j)            
!            darL=log(pt/pc)-zedl*sqrt((1d0-pt)/ex + (1d0-pc)/ey)
!            darU=log(pt/pc)-zedu*sqrt((1d0-pt)/ex + (1d0-pc)/ey)
!            b(1,j)=exp(darL)
!            b(2,j)=exp(darU)
!            zz=(log(pt/pc))/((darU-darL)/2d0/zedl)
            pv(j)=rpv(i,j)!exp(-0.717*zz-0.416*zz*zz)
!            if(pt.eq.0d0.or.pc.eq.0d0)pv(j)=1d0
            !could write pv and pt/pc for a scatter plot
            if(pv(j).lt.0.01d0)then
               k=k+1
               offenders(i,k)=header(j+3)
               if(pc.gt.0d0)then
                  if(pt/pc.gt.1d0)then
                     pm(k)='+'
                  elseif(pt/pc.lt.1d0)then
                     pm(k)='-'
                  endif
               endif
            else
               pdf(i,j)=pdf(i,1)/500d0
            endif
            !            write(*,*) TRIM(header(1+3)), exp(darL), pt/pc, exp(darU), TRIM(header(j+3)), max(pv(j),0.05d0)
         enddo
         !now detect which intervals are non-overlapping w.r.t. reps
!         write(*,*) TRIM(unk(i)), ist(i), ind(i), (max(pv(j),0.01d0),j=1,nfls), inout(i), lbg(i), rbg(i)
         write(*,*) TRIM(unk(i)), ist(i), ind(i), (pdf(i,j),j=1,nfls), inout(i), lbg(i), rbg(i)         
         if(k.gt.0)then
         write(99,*) TRIM(unk(i)), ist(i), ind(i), (pm(j),TRIM(offenders(i,j)),',',j=1,k), inout(i)
         endif
      enddo
      close(99)
      close(12)
      end program
