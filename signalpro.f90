      real*8 isiq,iscor,area,pdfIP,ameans,ameans2
      integer ilft, irght,ilft2,irght2,Reason,ReasonIP,nlines
      character(len=7) :: unk,rchr,unkIP,unkIN
      character(len=7) :: unk2,rchr2
      character(len=44) :: siq!for hmm annos
      character(len=62) :: arg
      character(len=62) :: path(4)
      logical :: file_exists

      ameans=0d0
      ameans2=0d0
      nlines=0
      inot=0
      iwrote=0
!-preanno IP IN, alpha
!IN and IP are normcov as NormCovIP_$tag.bed, pass this in after it is created in runcrunch
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
      rchr='chr1' !<initial chromosome, should really be left implicit
      ibounds=0
      iused=0!flag to detect usage of last read-line
      !BEGIN
      open(88,file='sgnls.'//TRIM(path(1)))
      ilftInit=1!always initiate at 1, each chr
!      read(12,*,IOSTAT=Reason) unk, ilft, irght, iscor
23456 continue
      read(12,*,IOSTAT=Reason) unkIP, ilftIP, irghtIP, pdfIP !initiator read

      sumIP=0d0!interval
      sumIPp=0d0!preInterval
      if(Reason.eq.0.and.index(unk,'_').gt.0)then
         write(*,*) 'we need to filter odd chr names'
         stop
      endif
      if(Reason.gt.0)then
         write(*,*) 'there was an error in input file ', path(1)
      elseif(Reason.eq.0)then !track is loaded
         if(unkIP.eq.rchr)then
            ameans=ameans+pdfIP
            ameans2=ameans2+pdfIP*pdfIP
            nlines=nlines+1
            go to 23456
         else
            write(88,*) rchr, ameans/dble(nlines), ameans2/dble(nlines), nlines
            nlines=0
            ameans=0d0
            ameans2=0d0
            rchr=unkIP
            ameans=ameans+pdfIP
            ameans2=ameans2+pdfIP*pdfIP
            nlines=nlines+1
            go to 23456
         endif
      endif
      write(88,*) rchr, ameans/dble(nlines), ameans2/dble(nlines), nlines!last
      close(88)
    end program
