      real*8 isiq,iscor,area,pdfIP,ameans,ameans2,axe,thresh
      real*8 sumtk,sumin,pv,darL,darU,zz,ex,ey
      integer ilft, irght,ilft2,irght2,Reason,ReasonIP,nlines,nN
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
         if(i.lt.3)then
            call getarg(i, arg)
            path(i)=arg
         else
            call getarg(i, arg)
            read(arg,*)sigmas!now holds depth count
         endif
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
      open(14,file='peaks.'//TRIM(path(1)))      
43215 continue
      read(13,*,IOSTAT=ReasonIP) rchr, ameans, ameans2, nlines
      if(ReasonIP.gt.0)then
         write(*,*) 'there was an error in input file ', path(2), ReasonIP
         stop
      elseif(ReasonIP.eq.0)then !track is loaded
         axe=0d0
         edge=ameans!       0.03d0*axm!normal  0.05
!         thresh=ameans+sigmas*sqrt(ameans2-ameans**2)!  0.04d0*axm!normal 0.15
         sumtk=0d0
         sumin=0d0
         !accumulate integral over edge, for pdf and mean (which is perfect input)
         !then check if lower-CI is met, if so it is a peak.
         itrack=0
         !BEGIN
         nl=0
23456    continue
         read(12,*,IOSTAT=Reason) unkIP, ilftIP, irghtIP, pdfIP !initiator read
         
         if(Reason.eq.0.and.index(unk,'_').gt.0)then
            write(*,*) 'we need to filter odd chr names'
            stop
         endif
         if(Reason.gt.0)then
            write(*,*) 'there was an error in input file ', path(1)
         elseif(Reason.eq.0)then !track is loaded
            if(unkIP.eq.rchr)then!sanity check here
               if(pdfIP.ge.edge.and.itrack.eq.0)then
                  itrack=1
                  istart=ilftIP
               endif
               if(itrack.eq.1.and.pdfIP.ge.edge)then!stop tracking at timeofvanishing
                  if(pdfIP.gt.axe)then!find the maximum
                     axe=pdfIP
                     ilbig=ilftIP
                     irbig=irghtIP
                  endif
                  iend=irghtIP !set this, it will be the end
                  sumtk=sumtk+pdfIP
                  sumin=sumin+ameans
               endif
               if(itrack.eq.1.and.pdfIP.lt.edge)then
                  pt=sumtk
                  pc=sumin
                  ex=pt*sigmas
                  ey=pc*sigmas
                  darL=log(pt/pc)-2.575d0*sqrt((1d0-pt)/ex + (1d0-pc)/ey)
                  darU=log(pt/pc)+2.575d0*sqrt((1d0-pt)/ex + (1d0-pc)/ey)
                  zz=(log(pt/pc))/((darU-darL)/2d0/2.575d0)
                  pv=exp(-0.717*zz-0.416*zz*zz)
                  if(pv.lt.0.01d0)then
!                  if(axe.ge.thresh)then!check lower-CI here, not threshold
                  write(14,*) rchr, istart, iend, axe, ilbig, irbig
                  endif
                  axe=0d0
                  itrack=0
                  sumtk=0d0
                  sumin=0d0
               !else
!                  nl=nl+1
!                  if(nl.lt.nlines)go to 23456
               endif
               nl=nl+1
               if(nl.lt.nlines)go to 23456               
            endif
         endif
         if(itrack.eq.1)then
            pt=sumtk
            pc=sumin
            ex=pt*sigmas
            ey=pc*sigmas
            darL=log(pt/pc)-2.575d0*sqrt((1d0-pt)/ex + (1d0-pc)/ey)
            darU=log(pt/pc)+2.575d0*sqrt((1d0-pt)/ex + (1d0-pc)/ey)
            zz=(log(pt/pc))/((darU-darL)/2d0/2.575d0)
            pv=exp(-0.717*zz-0.416*zz*zz)
            if(pv.lt.0.01d0)then
!            if(axe.ge.thresh)then
            write(14,*) rchr, ilftIP, irghtIP, axe, ilbig, irbig
            endif
            itrack=0
            axe=0d0!redundant i know
            nl=0
         endif!close this chr out
         nl=0
         itrack=0!redundant i know
         go to 43215
      endif
      close(14)
      end program
