## detect-replica-moves

### script: reorg_Remote_Dir_detect_moves.sh

... tries to find files that have been moved and generates the necessary mv commands before the actual synchronization should take place.

If you sync local / remote directory over low bandwith ( e.g. over webdav, smb, nfs)   
and
   * you have reorganized the file structure on the local directory for some reason...
   * you have no database based sync tool like e.g. SuperFlexibleSynchronizer (which can detect file moves) or you can not use it because you reorganized before let it create the database...

Then you will be faced with many file operations, **moved files will be first deleted and then again copied** to the remote side.   
The script `reorg_Remote_Dir_detect_moves.sh `is trying to detect the **_most(1)_** moved files and then **creates a new temporary shell-script:** `/dev/shm/REORGRemoteMoveScript.sh `.
The created script includes the *move (mv)* commands to adjust the remote directory and file tree. Since I only take care of the file names the script is no perfect solution.

This should run **before synchronization with your preferred sync tool** and is **not intended to replace** the sync tool.  
_PLEASE check the script CAREFULLY if the move commands are OK. Use this script at your own risk!_    
  
  
**_(1) most_** files means, **for safety** several files will be ignored:  
Files ...
   * ... with same(same beginning) names which exist more than once on one side  
     and also
   * ... which are only on the remote side
 
will be ignored and skipped.   
All this skipped files will then be handled by your preferred sync tool (e.g. rsync, unison ...), which you have to use after running the temporary shell-script.
So maybe my script is useful for someone. If so **(to make it more clear)** there are three steps:

 1. Run the shell script  [reorg_Remote_Dir_detect_moves.sh
][1]
 2. This will create the temporary shell-script `/dev/shm/REORGRemoteMoveScript.sh` => **run this to do the moves** (will be fast on mounted webdav)
 3. Run your **preferred sync tool** (e.g. `rsync, unison` ...)

  [1]: https://github.com/aexx/reorg_Remote_Dir_detect_moves.sh
