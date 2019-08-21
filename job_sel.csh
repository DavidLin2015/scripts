
set selJob = 1
set numJobs = 0
set toRead = 1
set jobId = 0
set var =

set oldModes = `stty -g`
set jobListFile = `mktemp`

######getJobList######
jobs > $jobListFile
set jobList = ()
foreach line ( "`cat $jobListFile`" )
    set jobList = ( $jobList:q "$line")
end
set numJobs = $#jobList
######################

while (1)
    #######printMenu######
    clear
    echo "                   ========================"
    echo "                   |     Job Selector     |"
    echo "                   ========================"
    echo ""

    if ($numJobs == 0) then
        echo "No jobs to select, press any key to exit..."
        stty raw -echo
        set var=`/home/utils/coreutils-8.22/bin/dd bs=1 count=1 status=none`
        stty "$oldModes"
        rm "$jobListFile"
        clear
        exit
    endif

    foreach i (`seq 1 1 $numJobs`)
            if ( $i == $selJob ) then
                echo -n "=> "
            else
                echo -n "   "
            endif
            echo -n "${jobList[$i]}"
            if ( $i == $selJob ) then
                echo -n " <="
            endif
            echo ""
    end
    ######################


    if ("$toRead" == "1") then
        stty raw -echo
        set var=`/home/utils/coreutils-8.22/bin/dd bs=1 count=1 status=none`
        stty "$oldModes"
        set nvar = `echo $var| od -An -t dC |  awk '{print $1}'` 
    endif
    set toRead = 1

    if ("$var" == "j") then
        if ( "$selJob" == $numJobs ) then
            set selJob = 1
        else
            @ selJob++
        endif
    else if ("$var" == "k") then
        if ( "$selJob" == 1 ) then
            set selJob = $numJobs
        else
            @ selJob--
        endif
    else if ("$var" == "f" || "$nvar" == 13) then
        set jobId=`echo -n "${jobList[$selJob]}" | awk '{print $1}' | grep -oP '\[\K\w+(?=\])'`
        fg %$jobId
    else if ("$var" == "b") then
        set jobId=`echo -n "${jobList[$selJob]}" | awk '{print $1}' | grep -oP '\[\K\w+(?=\])'`
        bg %$jobId
        set var = "r"
        set toRead = 0
        continue
    else if ("$var" == "K") then
        set jobId=`echo -n "${jobList[$selJob]}" | awk '{print $1}' | grep -oP '\[\K\w+(?=\])'`
        kill -9 %$jobId
        set newJobList=()
        foreach i (`seq 1 1 $numJobs`)
            if ( $i != $selJob ) then
                set newJobList = ( $newJobList:q "${jobList[$i]}")
            endif
        end
        set jobList=()
        foreach job ( $newJobList:q )
            set jobList = ( $jobList:q "$job" )
        end
        @ numJobs--

        if ($selJob >= $numJobs) then
            set selJob = $numJobs
        endif

    else if ("$var" == "r") then
        ######getJobList######
        jobs > $jobListFile
        set jobList = ()
        foreach line ( "`cat $jobListFile`" )
            set jobList = ( $jobList:q "$line")
        end
        set numJobs = $#jobList
        ######################
        if ($selJob >= $numJobs) then
            set selJob = $numJobs
        endif
        #######printMenu######
        clear
        echo "                   ========================"
        echo "                   |     Job Selector     |"
        echo "                   ========================"
        echo ""

        if ($numJobs == 0) then
            echo "No jobs to select, press any key to exit..."
            stty raw -echo
            set var=`/home/utils/coreutils-8.22/bin/dd bs=1 count=1 status=none`
            stty "$oldModes"
            rm "$jobListFile"
            clear
            exit
        endif

        foreach i (`seq 1 1 $numJobs`)
            if ( $i == $selJob ) then
                echo -n "=> "
            else
                echo -n "   "
            endif
            echo -n "${jobList[$i]}"
            if ( $i == $selJob ) then
                echo -n " <="
            endif
            echo ""
        end
        ######################
    else if ("$var" == "h") then
        clear
        echo "                   ========================"
        echo "                   |     Job Selector     |"
        echo "                   ========================"
        echo ""
        echo "Usage:"
        echo "UP/k        => move cursur up"
        echo "DOWN/j      => move cursur down"
        echo "K           => kill selected job"
        echo "f/ENTER     => fg   selected job"
        echo "b           => bg   selected job"
        echo "r           => refresh job list"
        echo "q           => quit"
        echo ""
        echo "(Press any key to continue)"
        stty raw -echo
        set var=`/home/utils/coreutils-8.22/bin/dd bs=1 count=1 status=none`
        stty "$oldModes"
    else if ("$var" == "q") then
        clear
        rm "$jobListFile"
        exit
    endif
    if ("$nvar" == 27) then
        stty raw -echo
        set var=`/home/utils/coreutils-8.22/bin/dd bs=1 count=1 status=none`
        set var=`/home/utils/coreutils-8.22/bin/dd bs=1 count=1 status=none`
        stty "$oldModes"
        if ("$var" == "A") then
            if ( "$selJob" == 1 ) then
                set selJob = $numJobs
            else
                @ selJob--
            endif
        else if ("$var" == "B") then
            if ( "$selJob" == $numJobs ) then
                set selJob = 1
            else
                @ selJob++
            endif
        endif
    endif
end
