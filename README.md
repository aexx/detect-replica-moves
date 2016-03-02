# reorg_Remote_Dir_detect_moves.sh

Script to reorganize remote directory (e.g. webdav) before synchronization 
 to avoid large file operation.

If you sync over low bandwith ( e.g. over webdav, smb, nfs)

And, you
   * have no database based sync tool like e.g. SuperFlexibleSynchronizer (which can detect file moves)
   * have reorganized the file structure for some reason. 

Then you will be faced with many file operations, moved files will be first deletet and then again copied to the remote side. 

This script is trying to detect the MOST(1) moved files and creates a file with several commands to adjust the remote directory and file tree.  

=> /dev/shm/REORGRemoteMoveScript.sh
 
It should run before synchronization with your preferred sync tool and does 

NOT replace the sync tool.

 USE THIS SCRIPT AT YOUR OWN RISK!

(1) MOST files means for safety will several files will be ignored:
     File with same(same beginning) names on every side will be ignored and 
      skipped. Also if the is only on remote side. All this skipped files 
      will then be handled by the sync tool you start




