#!/bin/bash
#
################################################################################
#title       :reorg_Remote_Dir_detect_moves.sh
#description :script to reorganize remote directory
#author      :aexx (alex schilling)
#date        :2016-03-02
#usage       :reorg_Remote_Dir_detect_moves.sh SOURCE-Dir DESTINATION-Dir
################################################################################
# Script to reorganize a remote directory (e.g. webdav) before synchronization 
#  to avoid large file operation.
# If you sync over low bandwith ( e.g. over webdav, smb, nfs)
#    And, you
#    * have no database based sync tool like e.g. SuperFlexibleSynchronizer 
#      (which can detect file moves)
#    * have reorganized the file structure for some reason 
#  Then you will be faced with many file operations, moved files will be first 
#   deletet and then again copied to the remote side.
#  This script is trying to detect the MOST(1) moved files and creates a file 
#   with several commands to adjust the remote directory and file tree.
#   => /dev/shm/REORGRemoteMoveScript.sh
#  It should run before synchronization with your preferred sync tool and does 
#   NOT replace the sync tool.
#
#  USE THIS SCRIPT AT YOUR OWN RISK!
#
# (1) MOST files means for safety several files will be ignored:
#      Files with same(same beginning) names on every side will be ignored 
#       and skipped. Also if the file is only on the remote side. 
#      All this skipped files will then be handled by the sync tool you start
################################################################################

IFS=$'\n'
r="\033[31m"
gr="\033[37m"
n="\033[m\017"

PCNT=$(ps aux |grep -v grep |grep -c $0)
[ $PCNT -ne 2 ] && echo -e "\n${r}EXIT => Script already running!\n ${n}"
[ $PCNT -ne 2 ] && exit 1
if [ $# -lt 2 ]
  then
  echo -e "\n\n${r}EXIT! \nSyntax: ${n} $0 SOURCE-Directory DESTINATION-Directory\n"
  exit 1
fi

SOURCE=$1
SOURCEPATH=$(dirname $SOURCE)/
SOURCEDIR=$(basename $SOURCE)/
DESTINATION=$2
DESTREMOTEPATH=$(dirname $DESTINATION)/
DESTREMOTEDIR=$(basename $DESTINATION)/

[ $SOURCEDIR != $DESTREMOTEDIR ] && echo -e "\n\n${r}Caution! SOURCE-Directory and DESTINATION-Directory have different names.
${n} Usually this makes no sense in sync scenarios. Please CHECK! \n But if you have that case ... Edit $0 to get rid of this.\n" 
[ $SOURCEDIR != $DESTREMOTEDIR ] && exit 1
[ -w /dev/shm/ ] && WDIR=/dev/shm  # working directory
[ -w /dev/shm/ ] || echo -e "\n${r}EXIT: ${n}working directory $WDIR does not work, change in script: $0 \n" 
[ -w /dev/shm/ ] || exit 1

LOCALPathList=$WDIR/LOCALPathList
REMOTEPathList=$WDIR/REMOTEPathList
ALLRemoteList=$WDIR/ALLRemoteList
UNIQRemoteList=$WDIR/UNIQRemoteList
REORGRemoteMoveScript=$WDIR/REORGRemoteMoveScript.sh
LOGFILE=$WDIR/reorg_Remote_Dir_detect_moves.log

echo -e "-----START--- reorg_Remote_Dir_detect_moves.log $(date +%Y-%m-%d_%H%M) -------------" >> $LOGFILE
echo -e "${r}\n\nSOURCEPATH=$SOURCEPATH
SOURCEDIR=$SOURCEDIR
DESTREMOTEPATH=$DESTREMOTEPATH
DESTREMOTEDIR=$DESTREMOTEDIR\n${n}" |tee -a $LOGFILE

echo -en "find SOURCEDIR ... "
cd $SOURCEPATH && time find ${SOURCEDIR} > $LOCALPathList
echo -en "find DESTREMOTEDIR -type f ... "
cd $DESTREMOTEPATH && time find ${DESTREMOTEDIR} -type f > $REMOTEPathList

#echo -en "find DESTREMOTEDIR -type f -exec basename ... This can take a while ..."
#cd $DESTREMOTEPATH && time find ${DESTREMOTEDIR} -type f -exec basename {} \;  > $ALLRemoteList
echo -en "for ... in ... basename ... "
rm -f $ALLRemoteList ; time for PFAD in `cat $REMOTEPathList`
do 
 basename $PFAD >> $ALLRemoteList
done
echo -en "cat $ALLRemoteList|sort|uniq ... "
time cat $ALLRemoteList|sort |uniq > $UNIQRemoteList
sed -i -e 's/ /\\ /g' $UNIQRemoteList

echo -e "\n\nChange to REMOTEDIR: cd $DESTREMOTEPATH => pwd "
cd $DESTREMOTEPATH ;pwd ;echo ;sleep 2 
echo "cd $DESTREMOTEPATH " > $REORGRemoteMoveScript
#echo;head $UNIQRemoteList ;echo "...";tail $UNIQRemoteList ;echo;sleep 2 # for debug

echo -e "${n}\nDescription:
FiOR: => FILE only Remote => skipping
PaML: => Pattern (Filename) found more than once LOCAL
PaMR: => Pattern (Filename) found more than once REMOTE
Dot . => PATHS on both sides are equal => nothing to do \n"

#cat $UNIQRemoteList|while read file
sleep 2
for file in `cat $UNIQRemoteList`
do 
 #sleep 1 # for debug
 #echo -en "${gr}FILE=$file  "
 #echo -en "LOCALPATH=$LOCALPATH " # for debug
 LOCALPATH=$(grep $file $LOCALPathList) 
 [ -z "$LOCALPATH" ] && echo -e "${n}  => FILE only Remote => skipping ${gr}" >> $LOGFILE
 [ -z "$LOCALPATH" ] && echo -en "${gr} FiOR "
 [ -z "$LOCALPATH" ] && continue
 CNT=$(grep -c $file $LOCALPathList) 
 [ $CNT = 1 ] || echo -e "${n}  => Pattern (Filename) found more than once LOCAL => skipping ${gr}" >> $LOGFILE
 [ $CNT = 1 ] || echo -en "${gr} PaML " 
 [ $CNT = 1 ] || continue
 LOCALDIR=$(dirname $LOCALPATH)
 CNT=$(grep -c $file $REMOTEPathList)
 [ $CNT = 1 ] || echo -e "${n}  => Pattern (Filename) found more than once REMOTE => skipping ${gr}" >> $LOGFILE
 [ $CNT = 1 ] || echo -en "${gr} PaMR " 
 [ $CNT = 1 ] || continue
 REMOTEP=$(grep $file $REMOTEPathList) 
 REMOTEDIR=$(dirname $REMOTEP)
 # echo -en "  => LOCALDIR=$LOCALDIR  => REMOTEDIR=$REMOTEDIR => " # for debug
 [ $LOCALDIR = $REMOTEDIR ] && echo -e "${gr}  PATHS on both sides are equal => nothing to do  " >> $LOGFILE
 [ $LOCALDIR = $REMOTEDIR ] && echo -en "${gr}."
 [ $LOCALDIR = $REMOTEDIR ] && continue
 [ -d $LOCALDIR ] || ( grep -q "mkdir -vp $LOCALDIR " $REORGRemoteMoveScript || echo -en "\n${n} REMOTEDIR not existing => create directory ${gr}" )
 [ -d $LOCALDIR ] || ( grep -q "mkdir -vp $LOCALDIR " $REORGRemoteMoveScript || echo "mkdir -vp $LOCALDIR " >> $REORGRemoteMoveScript )
 echo -en "\n${n}COMMAND: mv -iv ${REMOTEDIR}/$file ${LOCALDIR}/ ${gr}"
 echo -e "mv -iv ${REMOTEDIR}/$file ${LOCALDIR}/ " >> $REORGRemoteMoveScript
done
echo -e "\n${n}------------- reorg_Remote_Dir_detect_moves.log $(date +%Y-%m-%d_%H%M) -----END-----" >> $LOGFILE

echo -e "${n}\n\n\nDescription:
FiOR: => FILE only Remote => skipping
PaML: => Pattern (Filename) found more than once LOCAL
PaMR: => Pattern (Filename) found more than once REMOTE
Dot . => PATHS on both sides are equal => nothing to do

${r}See also LOG-File: $LOGFILE

Script:${n} cat $REORGRemoteMoveScript  # To execute: bash $REORGRemoteMoveScript \n\n ${r}
 PLEASE check the script CAREFULLY if changes are OK.
 USE THIS SCRIPT AT YOUR OWN RISK! ${n} \n\n"


