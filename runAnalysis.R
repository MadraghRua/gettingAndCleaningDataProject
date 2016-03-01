# load up the libraries
library(dplyr)
library(data.table)
library(tidyr)

#grab the data from the net and save locally
#i'm not on a mac so not using curl on the download
#unzip the file
#prove you can access all the files from the zip archive
dir.create("./data")
fileURL6 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL6, destfile = "./data/Dataset.zip")
unzip(zipfile = "./data/Dataset.zip", exdir = "./data")
filePath <- file.path("./data", "UCI HAR Dataset")
files <- list.files(filePath, recursive = TRUE)
files

#set the filepath tp the UCI HAR Dataset folder
#read the files into tables
filePath <- "./data/UCI HAR Dataset"
dataSubjectTrain <- tbl_df(read.table(file.path(filePath, "train", "subject_train.txt")))
dataSubjectTest <- tbl_df(read.table(file.path(filePath, "test", "subject_test.txt")))
dataActivityTrain <- tbl_df(read.table(file.path(filePath, "train", "Y_train.txt")))
dataActivityTest <- tbl_df(read.table(file.path(filePath, "test", "Y_test.txt")))
dataTrain <- tbl_df(read.table(file.path(filePath, "train", "X_train.txt")))
dataTest <- tbl_df(read.table(file.path(filePath, "test", "X_test.txt")))

#start the combining of the data
#starting with Subject and Activity data sets
#combining will take place based by row binding and renaming variables "subject" and "activityNum"
combineDataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
setnames(combineDataSubject, "V1", "subject")
combineDataActivity <- rbind(dataActivityTrain, dataActivityTest)
setnames(combineDataActivity, "V1", "activityNum")
dataTable <- rbind(dataTrain, dataTest)

#Name variables by the features file
dataFeatures <- tbl_df(read.table(file.path(filePath, "features.txt")))
setnames(dataFeatures, names(dataFeatures), c("featureNum", "featureName"))
colnames(dataTable) <- dataFeatures$featureName

#get the column names for the activity lables
activityLabels <- tbl_df(read.table(file.path(filePath, "activity_labels.txt")))
setnames(activityLabels, names(activityLabels), c("activityNum", "activityName"))

#combine the data
combinedDataSubjectActivity <- cbind(combineDataSubject, combineDataActivity)
dataTable <- cbind(combinedDataSubjectActivity, dataTable)

#grabbing the mean and standard deviation measurements
#using a grep to grab this data
dataFeaturesMeanStd <- grep("mean\\(\\)|std\\(\\)",dataFeatures$featureName, value = TRUE)
dataFeaturesMeanStd <- union(c("subject", "activityNum"), dataFeaturesMeanStd)
dataTable <- subset(dataTable, select = dataFeaturesMeanStd)
View(dataTable)

#using activity names rather than numbers in the data set for the various activities
#the final head shows the names of the various activities
dataTable <- merge(activityLabels, dataTable, by="activityNum", all.x = TRUE)
dataTable$activityName <- as.character(dataTable$activityName)
dataTable$activityName <- as.character(dataTable$activityName)
dataAggregation <- aggregate(. ~ subject - activityName, data = dataTable, mean)
dataTable <- tbl_df(arrange(dataAggregation, subject, activityName))
head(str(dataTable),2)

#Labeling the data set with more descriptive names
#The final head here demonstrates how the m=names have now changed
names(dataTable) <- gsub("std()", "SD", names(dataTable))
names(dataTable) <- gsub("mean()", "MEAN", names(dataTable))
names(dataTable) <- gsub("^t", "time", names(dataTable))
names(dataTable) <- gsub("^f", "frequency", names(dataTable))
names(dataTable) <- gsub("Acc", "Accelerometer", names(dataTable))
names(dataTable) <- gsub("Gyro", "Gyroscope", names(dataTable))
names(dataTable) <- gsub("Mag", "Magnitude", names(dataTable))
names(dataTable) <- gsub("BodyBody", "Body", names(dataTable))
head(str(dataTable),6)

#Creating the table for export.
write.table(dataTable, "TidyData.txt", row.names = FALSE)

