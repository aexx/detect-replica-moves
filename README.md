# reorg_Remote_Dir_detect_moves.sh

Shell-Script to reorganize a remote directory (e.g. webdav) before synchronization 
 to avoid large file operation.

**If you sync** over low bandwith ( e.g. over webdav, smb, nfs)

**And**, you
   * have no database based sync tool like e.g. SuperFlexibleSynchronizer (which can detect file moves)
   * have reorganized the file structure for some reason. 

Then you will be faced with many file operations, moved files will be first deletet and then again copied to the remote side. 

The script `reorg_Remote_Dir_detect_moves.sh` does not change your directories!  
It is trying to detect the **_MOST(1)_** moved files and then **creates a new temporary shell-script with several commands** to adjust  
the remote directory and file tree:  
`=> /dev/shm/REORGRemoteMoveScript.sh`
 
This script should run **before synchronization with your preferred sync tool** and 
does **NOT** replace the sync tool.

 **USE THIS SCRIPT AT YOUR OWN RISK!**



**_(1) MOST_** files means for safety several files will be ignored:  
Files with same(same beginning) names on every side will be ignored and skipped. Also files which are only on remote side.

All this skipped files will then be handled by the sync tool you start.




