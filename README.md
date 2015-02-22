#Getting And Cleaning Data Course Project
#### The purpose of this project is to demonstrate the ability to collect, work with, and clean a data set. The process will read Human Activity Recognition Using Smartphones Dataset from downloaded and unziped for this Tidy Data exercise. The Tidy data has been worked into a Narrow form instead of Wide form to demonstrate capabilities around gather() (or melt) and spread()  and to provide more control on analyzing the data

- - -

## Step 0.
* Loads necessary Libraries
* Downloads the file
* Unzips the file

## Step 1.
* Load Train, Test, Activity, Activity Labels, Subject data files into Datasets

## Step 2.
* Cleanse the Feature Information and filters only the Standard Deviation and Mean Columns across Feature Components
* Assign Column Names to the above corresponding Datasets

## Step 3.
* Column Bind Activity and Subject data to Training and Test datasets to get a complete dataset
* Merge the Activity lables into the bound Datasets

## Step 4.
* Combine both the Training and Test Datasets into one complete Dataset
* Assign a ID variable to help us in the spread process below
* Rearrange the variables to have the non fixed value variables earliar in the list

## Step 5.
* Column headers are values, not variable names. Melt the Columns into observational rows as Feature, Measurement and Axis
* Multiple variables are stored in one column. Cleanse the Feature or Component information to extract "t" and "f" into a seperate variable as "Time" and "Frequency"

## Step 6.
* Variables are stored in both rows and columns. Spread the Measurement back into columns to show it as Mean and Standard Deviation

## Step 7.
* Create a second Tidy data that will provide averages for each variable for each activity and each subject and write it to a file




