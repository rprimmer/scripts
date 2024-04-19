#! /bin/sh

# Display process tree 

ps -ef | awk '\
BEGIN {\
ppid_list=" ";\
pid_list=" ";\
while (getline==1) {\
	if (  (lookfor=="") || \
		  (lookfor!="" && index($0,lookfor)!=0) ) {\
		user=$1;\
		ppid=$3;\
		pid=$2;\
		command=substr($0,48,200);\
		pid_list=pid_list pid " ";\
		pid_arr[pid]="("user","command")";\
		if (index(ppid_list," "ppid" ")==0) {\
			pid_tree[ppid,0]=1;     \
			ppid_list=ppid_list ppid " ";\
			}\
		pid_tree[ppid,pid_tree[ppid,0]]=pid;\
		pid_tree[ppid,0]=pid_tree[ppid,0]+1;\
		}\
	}\
\
print_pid(1,"","");\
}\
\
function print_pid(pid,prefixme,prefixothers,i)\
{\
print prefixme pid " - " pid_arr[pid];\
if (index(ppid_list," "pid" ")!=0) {\
	for (i=1;i<pid_tree[pid,0]-1;i++) {\
		if (int(pid_tree[pid,i])!=int(pid)) { \
			print_pid(pid_tree[pid,i],prefixothers "!__",prefixothers "!  ");\
			}\
		}\
	if (int(pid_tree[pid,pid_tree[pid,0]-1])!=int(pid)) {\
		print_pid(pid_tree[pid,pid_tree[pid,0]-1],prefixothers " \\_",prefixothers "   ");\
		}\
	}\
}\
' lookfor="$1"
