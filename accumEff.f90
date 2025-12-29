      real*8 isiq,iscor,area,pdfIP
      integer ilft, irght,ilft2,irght2,Reason,ReasonIP,ReasonIN
      integer ilbig,irbig
      character(len=7) :: unk,rchr,unkIP,unkIN
      character(len=7) :: unk2,rchr2
      character(len=44) :: siq!for hmm annos
      character(len=62) :: arg
      character(len=62) :: path(4)
      logical :: file_exists
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
      inquire(file=path(2),EXIST=file_exists)
      if(file_exists .eqv. .true.)then
         open(13,file=path(2))      
      else
         write(*,*) 'your first file or path is incorrect'
         stop
      endif

      ibounds=0
      iused=0!flag to detect usage of last read-line
      !BEGIN
      open(99,file='blocks.'//TRIM(path(2)))            
      ilftInit=1!always initiate at 1, each chr
      read(12,*,IOSTAT=Reason) unk, ilft, irght, isiq, ilbig, irbig
      imlast=0
      read(13,*,IOSTAT=ReasonIP) unkIP, ilftIP, irghtIP, pdfIP !initiator read
23456 continue
      sumIP=0d0!interval
      sumIPp=0d0!preInterval
      if(Reason.eq.0.and.index(unk,'_').gt.0)then
         write(*,*) 'we need to filter odd chr names'
         stop
      endif
      if(Reason.gt.0)then
         write(*,*) 'there was an error in input file ', path(1)
      elseif(Reason.eq.0)then !new peak is loaded


12345    continue
         if(ReasonIP.eq.0)then 
            if(unkIP==unk)then!did we hit new chr in IP or in preanno? former should be impossible
               if(ilftInit.lt.irghtIP.and.ilftIP.lt.ilft)then
                  sumIPp=sumIPp+pdfIP
                  read(13,*,IOSTAT=ReasonIP) unkIP, ilftIP, irghtIP, pdfIP !initiator read
                  imlast=1
                  go to 12345
               endif
               if(ilft.le.irghtIP.and.ilftIP.le.irght)then!manage peak interval
                  sumIP=sumIP+pdfIP
                  read(13,*,IOSTAT=ReasonIP) unkIP, ilftIP, irghtIP, pdfIP !initiator read
                  imlast=2
                  go to 12345
               endif
               if(ilftIP.gt.irght)then!time to reload a new peak interval
                  write(99,*) unk, ilftInit+1, ilft-1, sumIPp, 0, -11, -11
                  write(99,*) unk, ilft, irght, sumIP, 1, ilbig, irbig
                  ilftInit=irght
                  read(12,*,IOSTAT=Reason) unk, ilft, irght, isiq, ilbig, irbig
                  imlast=3
                  go to 23456
               endif
            else!the chr don't match, peak line must have moved to new chr, so run it out 
               write(*,*) unkIP, ' was last read IP'
               write(*,*) unk, ' was last read peak'
               write(*,*) imlast
               if(imlast.ne.3)then!peaks is behind IP now, this assumes no iteration - 
                  write(*,*) unk, ilftInit+1, ilft-1, sumIPp, 0, -11, -11                  
                  write(*,*) unk, ilft, irght, sumIP, 1, ilbig, irbig
                  write(99,*) unk, ilftInit+1, ilft-1, sumIPp, 0, -11, -11
                  write(99,*) unk, ilft, irght, sumIP, 1, ilbig, irbig
                  ilftInit=1!looking to reset - 
                  read(12,*,IOSTAT=Reason) unk, ilft, irght, isiq, ilbig, irbig
                  if(Reason.eq.0)write(*,*) unk, ilft, irght, isiq, ilbig, irbig
                  go to 23456
               endif
               if(unkIP/='chrM')then
               rchr=unkIP
               ilftInit=ilftIP
               irghtInit=irghtIP
               endif
               write(*,*) unk, unkIP, ilftIP, irghtIP
87654          continue
               if(unkIP/='chrM')then
                  sumIPp=sumIPp+pdfIP
               endif
               read(13,*,IOSTAT=ReasonIP) unkIP, ilftIP, irghtIP, pdfIP !initiator read
               if(reasonIP.eq.0)then
                  if(unkIP/=unk)then
                     if(unkIP/='chrM')then
                        irghtInit=irghtIP                     
                     endif
                        go to 87654
                  endif
                  if(unkIP==unk)then!don't write this to preven mismatch line in databases
!                     write(99,*) rchr, ilftInit, irghtInit, sumIPp, 0, -11, -11
                     ilftInit=1
                     go to 12345
                  endif
               endif
            endif
         elseif(ReasonIP.lt.0)then !replace this logic with a second external function
            write(99,*) unk, ilftInit+1, ilft-1, 0d0, 0, -11, -11
            write(99,*) unk, ilft, irght, 0d0, 1, ilbig, irbig
            read(12,*,IOSTAT=Reason) unk, ilft, irght, isiq, ilbig, irbig
            go to 23456
         endif!reasonIP ok
      endif!reason ok
      close(99)
    end program
