## The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. ##
## The process will get the data for this Tidy Data excercise into a Narrow format instead of Wide format to 
## demonstrate capabilities around gather() (or melt) and spread() (or dcast)

##----- STEP 0: PRELIMINARY STEPS BEFORE LOAD THE DATA ----------------------##
## Library Declaration
library(RCurl)
library(dplyr)
library(data.table)
library(tidyr)
library(stringr)

## Download the file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fileUrl, destfile = "./HARuSP.zip", method="curl", mode="wb")

## Unzip the file
unzip("./HARuSP.zip", overwrite = TRUE)


##----- STEP 1: LOAD THE DATA FROM FILE -------------------------------------##
XTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
XTest <- read.table("./UCI HAR Dataset/test/X_test.txt")

features <- read.table("./UCI HAR Dataset/features.txt")

subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")

activityTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
activityTest <- read.table("./UCI HAR Dataset/test/y_test.txt")
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")

str(XTrain)
str(activityTrain)
str(subjectTrain)

str(XTest)
str(activityTest)
str(subjectTest)

str(features)
tail(features)
head(features)

str(activityLabels)





##----- STEP 2: SELECT MEAN AND STD VARIABLES --------------------------------##
##------AND ASSIGN VARIABLES NAMES ACROSS LOADED DATASETS --------------------##

## Assign Columns to other data sets
colnames(activityTrain) <- c("Activity_ID")
colnames(activityTest) <- c("Activity_ID")
colnames(activityLabels) <- c("Activity_ID", "Activity")
colnames(subjectTrain) <- c("Subject_ID")
colnames(subjectTest) <- c("Subject_ID")

length(unique(features$V2))

## Select Mean and Std Deviations variable names from the training and test data sets
## There are a number of duplicate variable names which is causing an
## issue if you try to assign the variable names first and then select the variables later
## Taking the following approach on selecting the variables 
## 1. filter the Variable names
## 2. clean Variable names 
## 3. Apply the filtered Variable list on the datasets 
## 4. Assign Variable names to the final datasets - total columns 66

## Get the indices of the required Variable names to filter the Variables
## Variables are filterd by mean() and std() ONLY and I left off meanFreq which brings down to 66 Variables.

## The final count is 66.
regexFilter <- c("(mean|std)\\(\\)")
meanStdColumns <- grep(regexFilter, features$V2, value = FALSE)
str(meanStdColumns)
## Get the Actual columns name to be assigned to the dataset after columns that are not required have been removed
meanStdColumnNames <- grep(regexFilter, features$V2, value = TRUE)
str(meanStdColumnNames)

## Cleaning up the Variable names. 
## 1. Converting '()-' to '_'
## 2. Converting '()' to '_NA'
## 3. Converting '-' to '_'
meanStdColumnNames <- gsub("\\(\\)-", "_", meanStdColumnNames)
str(meanStdColumnNames)
meanStdColumnNames <- gsub("\\(\\)", "_", meanStdColumnNames)
str(meanStdColumnNames)
meanStdColumnNames <- gsub("-", "_", meanStdColumnNames)
str(meanStdColumnNames)
meanStdColumnNames

## Pick out Mean and Std columns and Filter out the other columns from Training and Test datasets
XTrainMeanStd <- XTrain %>% select(meanStdColumns)
str(XTrainMeanStd)

XTestMeanStd <- XTest %>% select(meanStdColumns)
str(XTestMeanStd)

## Assign Filtered Columnn Names to the Training and Test datasets
colnames(XTrainMeanStd) <- meanStdColumnNames
colnames(XTestMeanStd ) <- meanStdColumnNames

str(XTrainMeanStd)
str(XTestMeanStd)




##----- STEP 3: BIND ACTIVITY AND SUBJECT DATA TO TRAINING AND TEST DATASETS -##
##----- ASSIGN MEANINGFUL LABEL TO ACTIVITY ----------------------------------##

## Bind Subject and Training Activity data to the Training and Test Datasets
## Assign Data Type before the Training and Test data can be merged
## Rearranging the Columns
XTrainMeanStdActivitySubject <- bind_cols(subjectTrain, activityTrain, XTrainMeanStd)
XTrainMeanStdActivitySubject <- XTrainMeanStdActivitySubject %>% 
    mutate(Data_Type = "Training") %>%
    select(Subject_ID:Activity_ID, Data_Type, tBodyAcc_mean_X:fBodyBodyGyroJerkMag_std_)
str(XTrainMeanStdActivitySubject)


## Bind Subject and Test Activity to the Test Data list
## Assign Data Type before the Training and Test data can be merged
XTestMeanStdActivitySubject <- bind_cols(subjectTest, activityTest, XTestMeanStd)
XTestMeanStdActivitySubject <- XTestMeanStdActivitySubject %>% 
    mutate(Data_Type = "Test") %>%
    select(Subject_ID:Activity_ID, Data_Type, tBodyAcc_mean_X:fBodyBodyGyroJerkMag_std_)
str(XTestMeanStdActivitySubject)



## Merge Activity to the Activity Lables to pull in the meaningful activity labels
XTrainMeanStdActivitySubject <- merge(XTrainMeanStdActivitySubject, activityLabels, by="Activity_ID")
str(XTrainMeanStdActivitySubject)

## Merge Activity to the Activity Lables to pull in the meaningful activity labels
XTestMeanStdActivitySubject <- merge(XTestMeanStdActivitySubject, activityLabels, by="Activity_ID")
str(XTestMeanStdActivitySubject)




##----- STEP 4: COMBINE BOTH TRAINING AND TEST DATASETS ----------------------##

## Merge both training and test into one data set
mergedData <- bind_rows(XTrainMeanStdActivitySubject, XTestMeanStdActivitySubject) 
str(mergedData)

## Adding an ID column with running sequence for Spread function below
idDf <- data.frame(ID = seq(along=mergedData$Activity_ID))
mergedData <- bind_cols(idDf, mergedData)
## Rearranging Columns a TOTAL of 71 Columns
mergedData <- select (mergedData, ID, Activity_ID, Subject_ID, Activity, Data_Type, tBodyAcc_mean_X:fBodyBodyGyroJerkMag_std_)
str(mergedData)




##----- STEP 5: MELT THE DATA AND SPLIT MEASUREMENT OUTCOME AND AXIS ---------##
##----- ASSIGN MEANINGFUL LABEL TO ACTIVITY ----------------------------------##

## Melt the data using the gather function from Tidyr
meltedData <- gather(mergedData, Feature_Measurement_Axis, Value, -(ID:Data_Type))
str(meltedData)

## seperate Measurement_Outcome_Axis and change Outcome, Axis and Data_Type to factors
meltedData <- separate(data = meltedData, col = Feature_Measurement_Axis, into = c("Feature", "Measurement", "Axis"))
meltedData$Measurement <- factor(meltedData$Measurement)
meltedData$Axis <- factor(meltedData$Axis)
meltedData$Data_Type <- factor(meltedData$Data_Type)
str(meltedData)

## Enhance the Measurement Variable by introducing a new Variable to capture Frequency and Time domains 
## as a seperate Variable and by removing the prefix t and f on the Measurement
meltedData <- meltedData %>% 
    mutate(Domain = as.factor(ifelse(str_detect(Feature, "^t"), "Time", ifelse(str_detect(Feature, "^f"), "Frequency", "")))) %>% 
    mutate(Feature = str_replace(Feature, "^t|^f", "")) 

str(meltedData)
unique(meltedData$Feature)




##----- STEP 6: THIS STEP SPREADS OR DCAST THE DATA TO CREATE MEAN AND STD VARIABLES -----------------------##

spreadData <- meltedData %>% 
    spread(Measurement, Value) %>%
    rename(Mean = mean, Standard_Deviation = std)
str(spreadData)
head(spreadData, 100)


## ----- STEP 7. CREATE A SECOND TIDY DATA SET TO GET THE AVG AND SAVE IT TO FILE --------------------------##
tidyData <- spreadData %>% 
    group_by(Activity, Subject_ID, Domain, Feature, Axis) %>%
    summarize(Avg_Mean = mean(Mean, na.rm = TRUE), Avg_Standard_Deviation = mean(Standard_Deviation, na.rm = TRUE)) %>%
    arrange(Activity, Subject_ID, desc(Domain), Feature, Axis) %>%
    rename(Subject = Subject_ID)

str(tidyData)
head(tidyData, 100)
write.table(tidyData, file="./data/TidyData-Avg.txt", row.names = FALSE)

unique(tidyData$Activity)
##---------------------------- END ------------------------------------------------------##

##CodeBook

library(memisc)

codeBookData <- within(tidyData, {
    
    description(Activity) <- "Activity Performed by the Subject"
    wording(Activity) <- "Various Activities include Walking, Walking Upstairs, Walking Down Stairs, Sitting, Standing and Laying"
    
    labels(Activity) <- c(
        "WALKING"               = 1,
        "WALKING_UPSTAIRS"      = 2,
        "WALKING_DOWNSTAIRS"    = 3,
        "SITTING"               = 4,
        "STANDING"              = 5,
        "LAYING"                = 6
        )
    
})

codebook(codeBookData)