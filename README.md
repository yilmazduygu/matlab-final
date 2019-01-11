# matlab-final

A code that would read through Med-PC generated operant chamber data files and generate plots. 

The link to the data folder:
https://drive.google.com/drive/folders/17h_HmLMhMz-97-MRaQo_ZDv4IyUN0bY9?usp=sharing
(This link should work with a rutgers domain email address)


The functions are separated now. 
The essential files:
  + readFR8txt.m
  + readCleanSave.m
  + graphFR8data.m
  + the folder containing the .txt files

Call the functions in this order:
>> readCleanSave(myFolder,matFileName);
>> graphFR8data(matFileName,figure1(OPTIONAL),figure2(OPTIONAL));

Example script:
>> readCleanSave('/Users/Duygu/Google Drive/Sem III/Scientific Programming in Matlab/my codes for the course/Final project/Data files','analyzeFR8')
>> graphFR8data('analyzeFR8')
