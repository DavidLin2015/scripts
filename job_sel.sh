#!/home/utils/bash-4.3/bin/bash

selJob=0
numJobs=0
jobId=0
toRead=1

function getJobId {
    echo -n ${jobList[$selJob]} | awk '{print $1}' | grep -oP '\[\K\w+(?=\])'
}
function printHeader {
    echo "                   ========================"
    echo "                   |     Job Selector     |"
    echo "                   ========================"
    echo ""
}
function printMenu {
    clear
    printHeader
    for (( i=0; i < ${#jobList[@]}; ++i )); do
        if [ "$i" -eq $selJob ]; then
            echo -n "=> "
        else
            echo -n "   "
        fi
        echo -n "${jobList[$i]}"
        if [ "$i" -eq $selJob ]; then
            echo -n "<="
        fi
        echo ""
    done
}
function printHelp {
    clear
    printHeader
    echo "Usage:"
    echo "UP/k        => move cursur up"
    echo "DOWN/j      => move cursur down"
    echo "K           => kill selected job"
    echo "f           => fg   selected job"
    echo "b           => bg   selected job"
    echo "SPACE/ENTER => fg   selected job and quit selector"
    echo "r           => refresh job list"
    echo "q           => quit"
    echo ""
    echo "(Press any key to continue)"
    read -n1 -s var
    return
}
function selUp {
    if [ "$selJob" -eq 0 ]; then
        selJob=$(( numJobs-1 ))
    else
        ((selJob--))
    fi
}
function selDown {
    if [ "$selJob" -eq $((numJobs-1)) ]; then
        selJob=0
    else
        ((selJob++))
    fi
}
function killJob {
    jobId=$(getJobId)
    kill -9 "%${jobId}"
    unset jobList[$selJob]
    jobList=( "${jobList[@]}" )
    numJobs=${#jobList[@]}
    if [ $numJobs == 0 ]; then
        return
    fi
    if [ $selJob -ge $numJobs ]; then
        selJob=$(( numJobs-1 ))
    fi
}
function fgJob {
    jobId=$(getJobId)
    fg "%${jobId}"
}
function bgJob {
    jobId=$(getJobId)
    bg "%${jobId}"
}
function refreshList {
    getJobList
    if [ $numJobs == 0 ]; then
        return
    fi
    if [ $selJob -ge $numJobs ]; then
        selJob=$(( numJobs-1 ))
    fi
    #printMenu
}
function getJobList {
    #jobs | awk '{printf  $1"|"$2"|";for(i=3;i<=NF;++i)printf $i" ";print ""}' | column -t -s "|"
    mapfile -t jobList < <(jobs | awk '{printf  $1"@"$2"@";for(i=3;i<=NF;++i)printf $i" ";print ""}' | column -t -s "@")
    numJobs=${#jobList[@]}
}
function mainLoop {
    printMenu
    if [ "${#jobList[@]}" -eq 0 ]; then
        echo "No jobs to select, press any key to exit..."
        read -n1 -s var
        return
    fi
    if [ $toRead -eq 1 ]; then
        read -n1 -s var
    fi
    toRead=1

    if [ "$var" = "j" ]; then
        selDown
    elif [ "$var" = "k" ]; then
        selUp
    elif [ "$var" = "K" ]; then
        killJob
        printMenu
    elif [ -z "$var" ]; then
        fgJob
        return
    elif [ "$var" = "f" ]; then
        fgJob
        refreshList
    elif [ "$var" = "b"  ]; then
        bgJob
        refreshList
    elif [ $var = "r" ]; then
        refreshList
    elif [ "$var" = "q"  ]; then
        return
    elif [ "$var" = "h"  ]; then
        printHelp
    fi


    if [ "$var" = "["  ]; then
        read -n1 -s var
        if [ "$var" = "A"  ]; then
            selUp
        elif [ "$var" = "B" ]; then
            selDown
        else
            toRead=0
            continue
        fi
    fi
    mainLoop
}

#TODO cleanup variables and functions when INT received
function cleanUp {
    echo cleanup
    unset var selJob numJobs jobId toRead
    unset -f getJobId printHeader printMenu printHelp selUp selDown killJob fgJob bgJob refreshList getJobList mainLoop cleanUp
    trap - RETURN
    #return
}

#trap cleanUp RETURN

#RUN
getJobList
#printMenu
mainLoop

