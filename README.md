Getting and Cleaning Data : Project
========================================================

This script requires the folder with the data to be in the same directory.

Dependencies:

```r
library(reshape2)
```


### 1. Merge the training and test set to create one data set

Read the labels for the activities from activity_labels.txt.

```r
activity.labels <- read.table("UCI HAR Dataset/activity_labels.txt")
```


Read the labels for the features (i.e., the column names) from the features.txt file.

```r
features.labels <- read.table("UCI HAR Dataset/features.txt")
```


Read training data, training labels, and training subjects from the corresponding files.

```r
x.train <- read.table("UCI HAR Dataset/train/X_train.txt")
y.train <- read.table("UCI HAR Dataset/train/y_train.txt")
subjects.train <- read.table("UCI HAR Dataset/train/subject_train.txt")
```


Create a single data frame for the training data. 

```r
data.train <- cbind(subjects.train, y.train, x.train)
```

This data frame has 7352 rows and 563 columns.

Repeat the process for the test data.

```r
x.test <- read.table("UCI HAR Dataset/test/X_test.txt")
y.test <- read.table("UCI HAR Dataset/test/y_test.txt")
subjects.test <- read.table("UCI HAR Dataset/test/subject_test.txt")
data.test <- cbind(subjects.test, y.test, x.test)
```

This data frame has 2947 rows and 563 columns.

Create a single data frame from the train and test data

```r
data <- rbind(data.train, data.test)
```

This data frame has 10299 rows and 563 columns.

Assign column names to the data frame.

```r
colnames(data) <- c("subject", "activity", as.vector(features.labels$V2))
```


### 2. Extract only the measurements on the mean and standard deviation for each measurement. 

Keep only the columns whose name is "subject" or "activity", or contains "mean()" or "std()".

```r
data <- cbind(data[, c("subject", "activity")], data[, grepl("mean()", names(data), 
    fixed = T)], data[, grepl("std()", names(data), fixed = T)])
```

The data frame now has 10299 rows and 68 columns.

### 3. Use descriptive activity names to name the activities

Use the `cut` function to change the numeric activity labels with the textual ones (already read in the activity.labels data frame).

```r
data$activity <- cut(data$activity, 6, labels = activity.labels$V2)
```


### 4. Appropriately label the data set with descriptive activity names. 

Given that the variable names are really long, having them all lower case does not improve readbility. We use Camel Case instead.

We use the following rules to bring names in a readable form:
* Leading "t" is transformed to "time".
* Leading "f" is transformed to "frequency".
* Occurrences of "Acc", "Gyro", "Mag", "mean", "std" are changed to "Accelerometer", "Gyroscope", "Magnitude", "Mean", "Std" respectively.
* "-", "(", ")" are removed.

```r
names <- names(data)
names <- sub("^t", "time", names)
names <- sub("^f", "frequency", names)
names <- sub("Acc", "Accelerometer", names)
names <- sub("Gyro", "Gyroscope", names)
names <- sub("Mag", "Magnitude", names)
names <- sub("mean", "Mean", names)
names <- sub("std", "Std", names)
# remove -, (, )
names <- gsub("[-\\(\\)]", "", names)
colnames(data) <- names
```


### 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject.

We use the `melt` function from the `reshape2` package to transform the data into a long table using `subject` and `activity` as ids. 

```r
data.melt <- melt(data, id = c("subject", "activity"))
```

This table the following columns subject, activity, variable, value. The `variable` column contains the feature names.

Then we use `dcast` to group rows with the same `subject` and `activity`, and take the mean of 
each `variable` level (i.e., of each feature for the specific subject and activity).

```r
data.final <- dcast(data.melt, subject + activity ~ variable, mean)
```

The final data frame has 180 rows and 68 columns.
