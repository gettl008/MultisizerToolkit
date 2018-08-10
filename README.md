# MultisizerToolkit
This toolkit is meant to be a collection of tools useful for working with count/size data generated by the Multisizer4 Coulter counter.

Prerequisites:
R

To download this toolkit, in your command line terminal type...
```
git clone https://github.com/gettl008/MultisizerToolkit
```

The main program "multisizer2csv" converts .#m4 files to diameter binned csv files that can be analyzed in your favorite statistics program. This should work with any flavor of Unix(Mac)/Linux.
To install:
1. Move into this program's bin directory
```
cd <PATH>/multisizer2csv/bin
```
2. All files in this directory's bin need to be in your $PATH variable. Easiest way to do this...
```
sudo cp ./* /usr/local/bin/
```
  Alternatively, you can temporarily add this directory to your PATH.
 ```
 export PATH=<PATH>/multisizer2csv/bin:$PATH
 ```
  To permenantly add this to your path this line must be added to your configuration profile.
  With Mac:
 ```
 nano ~/.bash_profile
 ```
  With Linux:
 ```
 nano ~/.bashrc
 ```
  For both add the line:
 ```
 export PATH=<PATH>/multisizer2csv/bin:$PATH
 ```
 
To run and see options:
	> multisizer2csv.sh -h
  
The Multisizer Toolkit also includes a local R package called "mstools".
To install, in R type:
```
install.packages("<PATH>/mstools")
```
To load:
```
library(mstools)
```

  
