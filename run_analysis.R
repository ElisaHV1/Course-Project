##Peer-grade Assignment: course project for the Getting and Cleaning Data Coursera course. 
  
##The run_analysis.R script does the following:

#1. Merges the training and the test sets to create one data set.
#2. Extracts only the measurements on the mean and standard deviation for each measurement.
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names.
#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


##First, we need to download the dataset

filename <- "assignmentdata.zip"
if (!file.exists(filename)){
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl, filename, method="curl")
}

##Since the dataset is in zip format, we need to unzip it
if (!file.exists("UCI HAR Dataset")){
  unzip(filename)
}

#checking that the unzip files that have been saved on the "UCI HAR Dataset" folder
list.files("UCI HAR Dataset")
list.files("UCI HAR Dataset/test")
list.files("UCI HAR Dataset/train")
list.files("UCI HAR Dataset/test/Inertial Signals")
list.files("UCI HAR Dataset/train/Inertial Signals")


##Once the files have been downloaded, we need to load the "activity labels" data, and then tag both columns
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE) 
class(activity_labels[,2])
activity_labels[,2] <- as.character(activity_labels[,2])  
colnames(activity_labels) <- c("activity_id","activity_type") 

##We do the same thing for the "features" data
features <- read.table("UCI HAR Dataset/features.txt", header = FALSE)
features[,2] <- as.character(features[,2])

# Now, we need to create a variable that contains the features of interest. In other words, we need to extract the measurements on the mean and standard deviation for each measurement

features_ofinterest <- grep(".*mean.*|.*std.*", features[,2])
features_ofinterest.names <- features[features_ofinterest,2]

#Then, we will start with the "train" dataset, tagging as needed before merging the entire dataset
xtrain <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)[features_ofinterest]
colnames(xtrain) = features_ofinterest.names
ytrain <- read.table("UCI HAR Dataset/train/Y_train.txt", header = FALSE)
colnames(ytrain) = "activityID"
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
colnames(subject_train) = "subjectID"

#We do the same thing for the "test" data
xtest <- read.table("UCI HAR Dataset/test/X_test.txt")[features_ofinterest]
colnames(xtest) = features_ofinterest.names
ytest <- read.table("UCI HAR Dataset/test/Y_test.txt")
colnames(ytest) = "activityID"
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
colnames(subject_test) = "subjectID"

#As we already load an tag the activity and subject data, we will merge both the "train" and the "test" data
train_data <- cbind(ytrain, subject_train, xtrain)
test_data  <- cbind(ytest, subject_test, xtest)

##Now, everything is set up for merging both datasets
datasetmerged <- rbind(train_data, test_data)

#In order to name the activities in the dataset, we use the factor function
datasetmerged$activityID <- factor(datasetmerged$activityID, levels = activity_labels[,1], labels = activity_labels[,2])

#In this part, we create a second tidy dataset with the average of each variable for each activity and each subject
#Also, we need to install the "reshape" package

install.packages("reshape")
library(reshape)

# Using "melt", we will obtaining a long-format data. For this reason, we need to transform data into a wide-format later on.
tidydataset_1 <- melt(datasetmerged, id = c("subjectID", "activityID"))
tidydataset.mean <- cast(tidydataset_1, subjectID + activityID ~variable, mean)

#Writing the output in a text file
write.table(tidydataset.mean, "tidy.txt", row.names = FALSE)

#checking the result
tidydataset.mean <- read.delim("tidy.txt", header=FALSE)

