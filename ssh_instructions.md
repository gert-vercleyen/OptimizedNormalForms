# How to ssh into Dirac 
This info comes from (https://www.math.purdue.edu/~zhan1966/research/dirac/dirac_document.html).

First log in to banach:
```
ssh username@banach.math.purdue.edu
```
and then connect to one of the 4 Dirac nodes:
```
ssh dirac-n
```
where n is the number of the node.

To check whether someone is already using Dirac you can evaluate 
```
who
```
in the terminal. 

# How to copy files between your local computer to Dirac
To copy a file from B to A while logged into B: 
```
scp /path/to/file username@A:/path/to/destination
```
Note: this is on linux. I'm not sure to what extend Putty on Windows uses the same commands.

