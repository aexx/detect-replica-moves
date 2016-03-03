# reorg_Remote_Dir_detect_moves.sh

Shell-Script detects moved files and reorganizes before synchronization local / remote directory (e.g. webdav) to avoid large file operation.

**If you sync** over low bandwith ( e.g. over webdav, smb, nfs)   
**And**
   * you have reorganized the file structure for some reason...
   * you have no database based sync tool like e.g. SuperFlexibleSynchronizer (which can detect file moves) or you can not use it because you reorganized before let it create the database...

Then you will be **faced with many file operations, moved files will be first deletet and then again copied** to the remote side.   
The script ` reorg_Remote_Dir_detect_moves.sh ` itself does not change your directories!  
It is trying to detect the **_most(1)_** moved files and then **creates a new temporary shell-script with several commands** to adjust the remote directory and file tree:  
` /dev/shm/REORGRemoteMoveScript.sh `   
This script should run **before synchronization with your preferred sync tool** and 
does **NOT** replace the sync tool.  
_PLEASE check the script CAREFULLY if changes are OK. Use this script at your own risk!_    
  
  
**_(1) most_** files means **for safety** several files will be ignored:
   * files with same(same beginning) names on every side and also
   * files which are only on the remote side
 
will be ignored and skipped.   
All this skipped files will then be handled by your preferred sync tool.


So maybe my script is useful for someone. If so **(to make it more clear)** there are three steps:

 1. Run the shell script  [reorg_Remote_Dir_detect_moves.sh
][1]
 2. This will create the temporary shell-script `/dev/shm/REORGRemoteMoveScript.sh` => **run this to do the moves** (will be fast on mounted webdav)
 3. Run your **preferred sync tool** (e.g. `rsync, unison` ...)

  [1]: https://github.com/aexx/reorg_Remote_Dir_detect_moves.sh
