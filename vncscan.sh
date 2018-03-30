#!/bin/bash


scanstart=1
scanstop=255
dirpath="/Users/fredrikdernebo/Dropbox/Privat/ScreenSharing/"
count=0
nodefine=0
fileexist=0
notopen=0
filename="not defined"

network=$1
dirname=$2

if [[ $network == "" ]]
then
  echo "Usage  "
  exit
fi

function createfile {
    #echo '\nCreating file '$dirpath$dirname'/'$filename
    #echo $filename
    echo -n 'C'
    echo "#!/bin/bash" > $dirpath$dirname/$filename
    echo "open vnc://"$hostname > $dirpath$dirname/$filename
    chmod +x $dirpath$dirname/$filename
    count=$((count+1))

}



function scanrange {
  echo 'Scanning range '$network$scanstart' to '$network$scanstop
  for scan in `seq $scanstart $scanstop`;
  do
    hostname=`host $network$scan|cut -d" " -f5`
    hostname=${hostname%?};
    #echo $network$scan $hostname
    if [[ $hostname == *"NXDOMAI"* ]];
    then
      hostname="notdefined"
      #echo $network$scan': Hostname not defined'
      echo -n '.'
      filename=$hostname'.command'
    else
      filename=$hostname'.command'
    fi

    if [ -e "$dirpath$dirname/$filename" ]
    then
      #echo "File '$filename' exists - Skipping"
      fileexist=$((fileexist+1))
      echo -n 'E'
      #echo $filename
    else
      if [[ $hostname == "notdefined" ]]
      then
        #echo 'Hostname '$network$scan' not defined - Skipping.'
        nodefine=$((nodefine+1))
      else
        #result=`sudo nmap -sS -p 5900 $network$scan|grep 5900|cut -d" " -f2`
        nc -z -G 1 $network$scan 5900 &> /dev/null && result="open" || result="not open"
        if [[ $result == 'open' ]];
        then
          #echo 'Scanning '$network$scan '('$hostname'): Creating VNC-file - '$result
          createfile
        else
          #echo 'Scanning '$network$scan '('$hostname'): No info or port closed -'$result
          #echo 'Scanning '$network$scan' ('$hostname')'
          notopen=$((notopen+1))
        fi
      fi

    fi
  done
}

function checkdir {
  echo "Checking for directory"
  if [ -d $dirpath$dirname ];
  then
      echo "Directory exists"
  else
      echo "Creating directory"
      mkdir $dirpath$dirname
  fi

}
### Main
checkdir
scanrange
echo
echo 'Added '$count' VNC-files to directory '$dirname'.'
echo `expr $scanstop - $scanstart + 1`' hosts scanned.'
echo $nodefine' hosts were not defined.'
echo $fileexist' files already existed.'
echo $notopen' hosts were defined but port not open.'

#echo "Current VNC-files:"
#ls -1 $dirpath$dirname/*.command
