      real*8 pdf(949400,54),sub(54,54),su(54),dubya(54),dubyaa(54),dis(54)
      real*8 pubya(54),pubyaa(54)
      integer lbg(949400),rbg(949400),ist(949400),ind(949400),inout(949400)
      integer Reason,nlin
      character(len=7) :: unk(949400)
      character(len=33) :: header(54)
      character(len=62) :: arg
      character(len=62) :: path(4)
      logical :: file_exists
      nfls=48 !patch on this
      do i=1,1!iargc()
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
      !get n=18 from argument and allocate things
      read(12,*,IOSTAT=Reason) (header(j),j=1,nfls+6)!unprotected technically
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
!      write(*,*) nlin
      su=0d0
      dis=0d0
      do j=1,nfls
         do i=1,nlin
            if(pdf(i,1)/pdf(i,j).lt.490)then
            dis(j)=dis(j)+dabs(pdf(i,1)-pdf(i,j))!(pdf(i,1)-pdf(i,j))**2
            endif
            su(j)=su(j)+pdf(i,j)
         enddo
         su(j)=su(j)/dble(nlin)!su = 1 for all of these, though, before division
      enddo

!      sub=0d0
!      do j=1,nfls
!         do k=1,nfls
!            do i=1,nlin
!               sub(j,k)=sub(j,k)+(pdf(i,j)-su(j))*(pdf(i,k)-su(k))
!            enddo
!         enddo
!      enddo

      do i=1,nfls
         write(*,*) i, dis(i), header(i+3)
      enddo
      stop
      !---ACTUALLY END HERE---------------------------------------------------
      sub=sub/dble(nlin-1)
      write(34,*) (header(i+3),i=1,11)
      do i=1,11
         write(34,*) (sub(i,j), j=1,11)
      enddo
      dubya=0d0
      dot=0d0
      do i=1,11
         dubya(i)=sub(i,1)
         dot=dot+dubya(i)**2
      enddo
      dot = sqrt(dot)
      dubya=dubya/dot
      dubyaa=0d0
      do it=1,20
         do i=1,11
            sum=0d0
            do j=1,11
               sum=sum+sub(i,j)*dubya(j)
            enddo
            dubyaa(i)=sum
         enddo
         dot=0d0
         do i=1,14
            dot=dot+dubya(i)*dubyaa(i)
         enddo
         write(*,*) it, dot, ' status'
         dot=0d0
         do i=1,14
            dot=dot+dubyaa(i)**2
         enddo
         write(*,*) sqrt(dot), 'eign'
         dubyaa=dubyaa/sqrt(dot)
         do i=1,14
            write(*,*)i, dubyaa(i)
         enddo
         dubya=dubyaa
      enddo!it
      !(Fast algorithms for sparse principal component analysis based on rayleigh quotient iteration)
      !sig_+ = sig - (x^T sig x)xx^T 
      !      do i=1,14
!         do j=1,14
      sus=0d0
      do i=1,14
         sum=0d0
         do j=1,14
            sum=sum+sub(i,j)*dubya(j)
         enddo
         sus=sus+sum*dubya(i)
         sup=sup+dubya(i)**2
      enddo
      write(*,*) sus*sup
      do i=1,14
         sub(i,i)=sub(i,i)-sus*sup
      enddo

      !ok, bad form,i know... 33 lines to make another vector
      pubya=0d0
      dot=0d0
      do i=1,14
         pubya(i)=sub(i,3)
         dot=dot+pubya(i)**2
      enddo
      dot = sqrt(dot)
      pubya=pubya/dot
      pubyaa=0d0
      do it=1,20
         do i=1,14
            sum=0d0
            do j=1,14
               sum=sum+sub(i,j)*pubya(j)
            enddo
            pubyaa(i)=sum
         enddo
         dot=0d0
         do i=1,14
            dot=dot+pubya(i)*pubyaa(i)
         enddo
         write(*,*) it, dot, ' status'
         dot=0d0
         do i=1,14
            dot=dot+pubyaa(i)**2
         enddo
         write(*,*) sqrt(dot), 'eign'
         pubyaa=pubyaa/sqrt(dot)
         do i=1,14
            write(*,*)i, pubyaa(i)
         enddo
         pubya=pubyaa
      enddo!it
      dot=0d0
      do i=1,14
         dot=dot+dubya(i)*pubya(i)
      enddo
      write(*,*) dot

    end program
