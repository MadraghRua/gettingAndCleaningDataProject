# gettingAndCleaningDataProject
Instructions

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.
Review criterialess 

    The submitted data set is tidy.
    The Github repo contains the required scripts.
    GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.
    The README that explains the analysis files is clear and understandable.
    The work submitted for this project is the work of the student who submitted it.

Getting and Cleaning Data Course Project

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

    Merges the training and the test sets to create one data set.
    Extracts only the measurements on the mean and standard deviation for each measurement.
    Uses descriptive activity names to name the activities in the data set
    Appropriately labels the data set with descriptive variable names.
    From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Loading Up Libraries

    library(dplyr)
    library(data.table)
    library(tidyr)

Loading up Data

    dir.create("./data")
    fileURL6 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL6, destfile = "./data/Dataset.zip")
    unzip(zipfile = "./data/Dataset.zip", exdir = "./data")
    filePath <- file.path("./data", "UCI HAR Dataset")
    files <- list.files(filePath, recursive = TRUE)
    files

Getting file data into tables

    filePath <- "./data/UCI HAR Dataset"
    dataSubjectTrain <- tbl_df(read.table(file.path(filePath, "train", "subject_train.txt")))
    dataSubjectTest <- tbl_df(read.table(file.path(filePath, "test", "subject_test.txt")))
    dataActivityTrain <- tbl_df(read.table(file.path(filePath, "train", "Y_train.txt")))
    dataActivityTest <- tbl_df(read.table(file.path(filePath, "test", "Y_test.txt")))
    dataTrain <- tbl_df(read.table(file.path(filePath, "train", "X_train.txt")))
    dataTest <- tbl_df(read.table(file.path(filePath, "test", "X_test.txt")))
    
Combining tables

    combineDataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
    setnames(combineDataSubject, "V1", "subject")
    combineDataActivity <- rbind(dataActivityTrain, dataActivityTest)
    setnames(combineDataActivity, "V1", "activityNum")
    dataTable <- rbind(dataTrain, dataTest)

Correcting labels to more human readable features from the features.txt file

    dataFeatures <- tbl_df(read.table(file.path(filePath, "features.txt")))
    setnames(dataFeatures, names(dataFeatures), c("featureNum", "featureName"))
    colnames(dataTable) <- dataFeatures$featureName
    
    activityLabels <- tbl_df(read.table(file.path(filePath, "activity_labels.txt")))
    setnames(activityLabels, names(activityLabels), c("activityNum", "activityName"))
    
    combinedDataSubjectActivity <- cbind(combineDataSubject, combineDataActivity)
    dataTable <- cbind(combinedDataSubjectActivity, dataTable)

Grabbing the mean and standard deviation data from the combined data sets

    dataFeaturesMeanStd <- grep("mean\\(\\)|std\\(\\)",dataFeatures$featureName, value = TRUE)
    dataFeaturesMeanStd <- union(c("subject", "activityNum"), dataFeaturesMeanStd)
    dataTable <- subset(dataTable, select = dataFeaturesMeanStd)
    view(dataTable)

Using activity names rather than numbers in the data set for the various activities
the final head shows the names of the various activities

    dataTable <- merge(activityLabels, dataTable, by="activityNum", all.x = TRUE)
    dataTable$activityName <- as.character(dataTable$activityName)
    dataTable$activityName <- as.character(dataTable$activityName)
    dataAggregation <- aggregate(. ~ subject - activityName, data = dataTable, mean)
    dataTable <- tbl_df(arrange(dataAggregation, subject, activityName))
    head(str(dataTable),2)

Labeling the data set with more descriptive names
The final head here demonstrates how the m=names have now changed

    names(dataTable) <- gsub("std()", "SD", names(dataTable))
    names(dataTable) <- gsub("mean()", "MEAN", names(dataTable))
    names(dataTable) <- gsub("^t", "time", names(dataTable))
    names(dataTable) <- gsub("^f", "frequency", names(dataTable))
    names(dataTable) <- gsub("Acc", "Accelerometer", names(dataTable))
    names(dataTable) <- gsub("Gyro", "Gyroscope", names(dataTable))
    names(dataTable) <- gsub("Mag", "Magnitude", names(dataTable))
    names(dataTable) <- gsub("BodyBody", "Body", names(dataTable))
    head(str(dataTable),6)

Creating the table for export.

    write.table(dataTable, "TidyData.txt", row.names = FALSE)
    



