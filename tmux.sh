#!/home/utils/bash-4.3/bin/bash

function create_client_windows {
    client_name=$1
    $tmux new-window -n $client_name
    $tmux send-keys  'exec bash' Enter
    $tmux send-keys  'sshlsf' Enter
    $tmux send-keys  'exec bash' Enter
    $tmux send-keys  "sdev $client_name" Enter
    $tmux send-keys  'vec' Enter
    sleep 1

    $tmux new-window -n ${client_name}_run
    $tmux send-keys  'exec bash' Enter
    $tmux send-keys  'sshlsf' Enter
    $tmux send-keys  'exec bash' Enter
    $tmux send-keys  "sdev $client_name" Enter
    $tmux send-keys  'qa' Enter
    sleep 1
}
echo "Running ..."

tmux=/home/utils/tmux-2.6/bin/tmux

$tmux new -s David -d

session=David
window=${session}:0

$tmux send-keys -t "$window" 'exec bash' Enter
$tmux send-keys -t "$window" 'sshlsf' Enter
$tmux send-keys -t "$window" 'exec bash' Enter
$tmux rename-window -t "$window" David

########## JET ##########
create_client_windows "jet"
create_client_windows "jet2"
create_client_windows "jet3"

########## PRGM ##########
create_client_windows "prgm"
create_client_windows "prgm2"

########## ATE ##########
#create_client_windows "ate"

########## VERSE ##########
create_client_windows "verse"

########## PENDING ##########
create_client_windows "pending"

########## TEST ##########
create_client_windows "test"
create_client_windows "test2"
create_client_windows "test3"
