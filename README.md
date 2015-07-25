## run_analysis.R script

### Main purpose and credits

This script loads a data set from the web and processes it in order to obtain a tidy data set with summary (averages) values.

*VHerreros, 20150723*

### Details

All data (source and output) are stored within a 'data' subdirectory beneath the R working directory.

In its first five lines the script installs (if not installed) the required R packages and loads them into memory. These are sqldf and dplyr.

The output is an ASCII file that can be read through the following R code:
```
address <- "https://s3.amazonaws.com/coursera-uploads/user-0168fb3fc2d3349c292b36df/975114/asst-3/edba3d30316d11e59a288f763e37a239.csv"
address <- sub("^https", "http", address)
data <- read.table(url(address), header = TRUE)
View(data)
```
The resulting data set has adopted the following conventions regarding variable names and contents:

- Activity contains one of the six activities to be performed.
- SubjCode are the IDs for the different persons performing the experiment.
- All but the first two variables contain average values obtained form the grouping of the different source measures by activity and subject.
- All but the first two variables are named according to the measure from the source data set they derive from:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- If their name starts with 'MEAN' they are the average of original mean values. 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- If their name starts with 'MSTD' they are the average of original standard devation values. 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- The rest of the variable name states for the type of averaged measurement. 

More details about naming and content of variables can be found in CodeBook.pdf file in this repository.

The output data is a tidy data text file that follows the following basic principles:
	
- Each variable forms a column.
- Each observation forms a row.
- The file stores data about one kind of observation (averages of mean and standard deviation of measurements depending on activity performed and subject performing it).
- More details can be read in the <a href=https://class.coursera.org/getdata-030/forum/thread?thread_id=107>Tidy Data and the Assignment</a> thread from Coursera's Getting and cleaning data course.
