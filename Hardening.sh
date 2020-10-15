#!/bin/bash
var=
SID="$(env | grep ORACLE_SID|sed 's/ORACLE_SID=//g')"
HOST=$(hostname)
#INST="$(ls -ltr /sapmnt/$SID/profile/$SID*$HOST | awk '{print $9}')"
HINP=/orascripts/Hardening/Hard.txt
HOUT=/orascripts/Hardening/output.txt
DEFL=/sapmnt/$SID/profile/DEFAULT.PFL
INST=/sapmnt/$SID/profile/V01_DVEBMGS10_dadca0000028
ORAPRF=/orascripts/Hardening/sqlout.txt
cat /dev/null > ${HOUT}
while read line
do
        if [[ -z $line ]]
        then
		echo "END" >> $HOUT
                continue
        elif [[ ${line:0:4} == '@@@@' ]]
        then
                echo ${line:4} >> $HOUT
                var=${line:4}
                echo "Parameter^ Recommended^ DEF^ INST" >> $HOUT

        else

                case $var in
                        Profile)
                                #cat $INST | grep ${line%% *} |cut -d= -f2
                                #echo ${line%% *}
                                result=
                                for i in $DEFL $INST
                                do
                                        if [[ "$(cat $i | grep ${line%% *}| grep -v '^#')" ]]; then
                                        #       echo "Match Found"
                                                found=`cat $i | grep ${line%% *} |grep -v '^#' | cut -d= -f2`
                                                result=$result^$found
                                        else
                                        #       echo "Match Not Found"
                                                found=N/A
                                                result=$result^$found
                                        fi

                                done
                                rec="$(cut -d'=' -f2 <<< ${line})"
                                echo ${line%% *} $rec  $result
				echo ${line%% *}^ $rec  $result >> $HOUT

                        ;;
                        Oracle)
					result=
                                for i in $ORAPRF
                                do
                                        if [[ "$(cat $i | grep -w ${line%% *}| awk '{print $3}')" ]]; then
                                        #       echo "Match Found"
                                                found=`cat $i | grep -w ${line%% *} | awk '{print $3}'`
                                                result=$result^$found
                                        else
                                        #       echo "Match Not Found"
                                                found=N/A
                                                result=$result^$found
                                        fi

                                done
                                rec="$(cut -d'=' -f2 <<< ${line})"
                                echo ${line%% *}^ $rec  $result 
                                echo ${line%% *}^ $rec  $result >> $HOUT
                                ;;
			Hana)
				echo $line
				;;
                        *)
                                echo "Hello"
                                ;;
                esac

        fi
done <$HINP
