# Environment setup - Packages needed, installed and loaded
list.of.packages <- c("sqldf", "dplyr")  # Para análisis de datos
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, library, character.only = T)

# Data directory creation
if (!dir.exists("./data")) { dir.create("./data")}

# Web data fetching and extraction
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/UCI_HAR_Dataset.zip", method = "curl")
unzip("./data/UCI_HAR_Dataset.zip", exdir = "./data")

# Original data reading
# General data
activlab <- read.csv("./data/UCI HAR Dataset/activity_labels.txt", header = F, sep = "")  # Activities codes and names
measlab <- read.csv("./data/UCI HAR Dataset/features.txt", header = F, sep = "")  # Measures codes and names
# Training set
trainsubj <- read.csv("./data/UCI HAR Dataset/train/subject_train.txt", header = F)  # Subject codes
trainactcod <- read.csv("./data/UCI HAR Dataset/train/y_train.txt", header = F)  # Activity codes
trainmeas <- read.csv("./data/UCI HAR Dataset/train/X_train.txt", header = F, sep = "")  # Measures
# Test set
testsubj <- read.csv("./data/UCI HAR Dataset/test/subject_test.txt", header = F)  # Subject codes
testactcod <- read.csv("./data/UCI HAR Dataset/test/y_test.txt", header = F)  # Activity codes
testmeas <- read.csv("./data/UCI HAR Dataset/test/X_test.txt", header = F, sep = "")  # Measures

	# Debug code
	# # Verifying that subjects ids from test data set and from train data set are mutually exclusive
	# t1 <- sqldf("select distinct V1 from testsubj order by 1")
	# t2 <- sqldf("select distinct V1 from trainsubj order by 1")
	# ny(t1 %in% t2)
	# # 	[1] FALSE
	# any(t2 %in% t1)
	# # 	[1] FALSE
	# rm(t1, t2)
	# # So we can concatenate both sets without subjects ids problems

# Labelling of data
colnames(testmeas) <- measlab$V2
colnames(trainmeas) <- measlab$V2
colnames(testactcod) <- "ActCode"
colnames(trainactcod) <- "ActCode"
colnames(testsubj) <- "SubjCode"
colnames(trainsubj) <- "SubjCode"

# Subsetting the measures data frame
# Look for the mean() and std() colnames (valid for both train and test dats sets)
meanlab <- grep("mean\\(\\)", colnames(testmeas), value = T)  # Column names with 'mean()' string
stdlab <- grep("std\\(\\)", colnames(testmeas), value = T) # Column names with 'std()' string
sellabs <- c(meanlab, stdlab) # Column names with 'mean()' or 'std()' string
sellabs <- sellabs[order(match(sellabs,colnames(testmeas)))]  # Reordering of column names according to the original order in data set
# Effective subsetting (measures corresponding to mean or std in trains and test data sets)
trainmeas <- trainmeas[,sellabs]
testmeas <- testmeas[,sellabs]

# Joining subjects, activities and measures
testset <- cbind(testactcod, testsubj, testmeas)
trainset <- cbind(trainactcod, trainsubj, trainmeas)

# Unique data set creation (activities, subkects and measures for test and training data sets)
dataset <- rbind(testset, trainset)

	# Debug code
	# # Reduced dataset for testing purposes
	# minidataset <- dataset[1:10, 1:10]
	# 
	# # Verifying there are no NA values in the data set
	# dim(dataset)
	# # 	[1] 10299    68
	# sum(is.na(dataset))
	# # 	[1] 0

# Naming the activities and renaming the variable name

	# Debug code
	# # Reduced dataset for testing purposes
	# minidataset$ActCode <- activlab$V2[match(minidataset$ActCode, activlab$V1)]
	# minidataset <- rename(minidataset, Activity = ActCode)

dataset$ActCode <- activlab$V2[match(dataset$ActCode, activlab$V1)]
dataset <- rename(dataset, Activity = ActCode)

# Re-labelling the data set by means of regexp
# Basically, preceedeing label names with 'MEAN' or 'STD' string and removing extra characters.

	# Debug code
	# # Reduced dataset for testing purposes
	# colnames(minidataset) <- sub("^(.+)-mean\\(\\)-{0,1}(.){0,1}$", "MEAN\\1\\2", colnames(minidataset), perl = T)
	# colnames(minidataset) <- sub("^(.+)-std\\(\\)-{0,1}(.){0,1}$", "STD\\1\\2", colnames(minidataset), perl = T)

colnames(dataset) <- sub("^(.+)-mean\\(\\)-{0,1}(.){0,1}$", "MEAN\\1\\2", colnames(dataset), perl = T)
colnames(dataset) <- sub("^(.+)-std\\(\\)-{0,1}(.){0,1}$", "STD\\1\\2", colnames(dataset), perl = T)

# New tidy data set (datasummary; tidy_summary.txt) with averages for each pair activity/subject

	# Debug code
	# # Reduced dataset for testing purposes
	# minidatagroup <- group_by(minidataset, Activity, SubjCode)
	# minidatasummary <- summarise_each(minidatagroup, funs(mean))

datagroup <- group_by(dataset, Activity, SubjCode)  # Grouping of the source data frame
datasummary <- summarise_each(datagroup, funs(mean))  # Tidy data frame from the previous grouping
write.table(datasummary, file = "./data/tidy_summary.csv", row.names = F)  # File creation
