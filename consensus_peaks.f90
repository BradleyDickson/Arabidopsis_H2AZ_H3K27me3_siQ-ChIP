      real*8 res(3,80000),res2(3,80000),res3(3,80000)
      integer istr(80000),ind(80000),i2str(80000),i2nd(80000),i3str(80000)
      integer i3nd(80000),Reason,ReasonA,ReasonB,counts
!      integer ilft, irght, iscore,ilft2,irght2,Reason,ReasonA,isiq      
      character(len=7) :: nchr(80000),isgn(80000),jsgn(80000)
      character(len=7) :: n2chr(80000),i2sgn(80000),j2sgn(80000)
      character(len=7) :: n3chr(80000),i3sgn(80000),j3sgn(80000)            
      character(len=62) :: arg
      character(len=62) :: path(3)
      logical :: file_exists
      inot=0
      iwrote=0
      do i=1,iargc()
         call getarg(i, arg)
            path(i)=arg
      enddo
      inquire(file=path(1),EXIST=file_exists)
      if(file_exists .eqv. .true.)then
         open(12,file=path(1))      
      else
         write(*,*) 'your first file or path is incorrect'
         stop
      endif
      inquire(file=path(2),EXIST=file_exists)
      if(file_exists .eqv. .true.)then
         open(13,file=path(2))      
      else
         write(*,*) 'your second file or path is incorrect'
         stop
      endif
      inquire(file=path(3),EXIST=file_exists)
      if(file_exists .eqv. .true.)then
         open(14,file=path(3))      
      else
         write(*,*) 'your second file or path is incorrect'
         stop
      endif
      

      iln=0
 5553 continue
      iln=iln+1
      read(12,*,IOSTAT=Reason) nchr(iln), istr(iln), ind(iln), (res(j,iln),j=1,3)
      if(Reason.gt.0)then
         write(*,*) 'there was an error in input file ', path(1), Reason
      elseif(Reason.eq.0)then 
         go to 5553
      endif
      iln=iln-1

      

      jln=0
 5554 continue
      jln=jln+1
      read(13,*,IOSTAT=ReasonA) n2chr(jln), i2str(jln), i2nd(jln), (res2(j,jln),j=1,3)
      if(ReasonA.gt.0)then
         write(*,*) 'there was an error in input file ', path(2), ReasonA
      elseif(ReasonA.eq.0)then 
         go to 5554
      endif
      jln=jln-1


      kln=0
5555  continue
      kln=kln+1
      read(14,*,IOSTAT=ReasonB) n3chr(kln), i3str(kln), i3nd(kln), (res3(j,kln),j=1,3)
      if(ReasonB.gt.0)then
         write(*,*) 'there was an error in input file ', path(3), ReasonB
      elseif(ReasonB.eq.0)then 
         go to 5555
      endif
      kln=kln-1
      close(12)
      close(13)
      close(14)
      
      !      write(*,*) iln, jln
      nstep=200!look forward 5
      nstep=2000!seems needs to be larger for h2az-hta case
      jlast=1
      do i=1,iln!this is very slow but is clear
         sum=0d0
         count=0d0         
         weight=0d0
         do j=max(1,i-nstep),min(jln,i+nstep)!assume some similarity because or repeats
            do k=max(1,i-nstep),min(kln,i+nstep)
               if(nchr(i).eq.n2chr(j).and.nchr(j).eq.n3chr(k))then
                  if(istr(i).lt.i2nd(j).and.ind(i).gt.i2str(j))then!first two interesct
                     ileft=min(istr(i),i2str(j))
                     irght=max(ind(i),i2nd(j))
                     if(i3str(k).lt.irght.and.i3nd(k).gt.ileft)then
                        ileft=min(i3str(k),ileft)
                        irght=max(i3nd(k),irght)                       
                        do l=1,3
                           sum=sum+(res(l,i)+res2(l,j)+res3(l,k))
                        enddo
                        weight=weight+9d0                        
                        count=count+1d0
                        istr(i)=-1
                        ind(i)=-1
                        !need to check ahead one or two in file-i
                        do ii=min(iln,i+1),min(iln,i+3)
                           if(nchr(ii).eq.n2chr(j))then
                              if(istr(ii).lt.irght.and.ind(ii).gt.ileft)then
!                                 write(*,*) 'in here ', nchr(ii), istr(ii), ind(ii)
                                 ileft=min(istr(ii),ileft)
                                 irght=max(ind(ii),irght)                       
                                 do l=1,3
                                    sum=sum+res(l,ii)
                                 enddo
                                 weight=weight+3d0!don't update count here right
                                 istr(ii)=-1
                                 ind(ii)=-1!block out
                              endif
                           endif
                        enddo
                     endif
                  endif
               endif
            enddo
         enddo
         
         !if matches were found, write the interval
         if(count.ne.0d0)then
         write(*,*) ' ', TRIM(nchr(i)), ileft, irght, sum/count/weight, count!(res(l,i), l=1,3), (res2(l,j), l=1,3), (res3(l,k), l=1,3)
         endif
      enddo
    end program
