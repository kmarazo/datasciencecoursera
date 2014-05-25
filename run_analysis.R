# This script requires the folder with the data to be in the same directory.

# 1. Merge the training and test set to create one data set
# Read activity labels
activity.labels <- read.table("UCI HAR Dataset/activity_labels.txt")

# Read feature labels
features.labels <- read.table("UCI HAR Dataset/features.txt")

# Read training data, labels, subject
x.train <- read.table("UCI HAR Dataset/train/X_train.txt")
y.train <- read.table("UCI HAR Dataset/train/y_train.txt")
subjects.train <- read.table("UCI HAR Dataset/train/subject_train.txt")
# Create a single data frame for the training data
data.train <- cbind(subjects.train, y.train, x.train)

# Read test data
x.test <- read.table("UCI HAR Dataset/test/X_test.txt")
y.test <- read.table("UCI HAR Dataset/test/y_test.txt")
subjects.test <- read.table("UCI HAR Dataset/test/subject_test.txt")
# Create a single data frame for the test data
data.test <- cbind(subjects.test, y.test, x.test)

# Create a single data frame from the train and test data
data <- rbind(data.train, data.test)

# assign column names to data
colnames(data) <- c("subject", "activity", as.vector(features.labels$V2))

# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
# Keep only the columns whose name is "subject" or "activity", or contains "mean()" or "std()"
data <- cbind(data[,c("subject", "activity")], data[,grepl("mean()", names(data), fixed=T)], data[,grepl("std()", names(data), fixed=T)])

# 3. Use descriptive activity names to name the activities
data$activity <- cut(data$activity, 6, labels=activity.labels$V2)

# 4. Appropriately label the data set with descriptive activity names. 
# Given that the variable names are really long, having them all lower case does not improve readbility. Use Camel Case instead
names <- names(data)
# rules for changing column names
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

# 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject.
library(reshape2)
data.melt <- melt(data, id=c("subject", "activity"))
data.final <- dcast(data.melt, subject + activity ~ variable, mean)

# write the final data frame to a file
write.table(data.final, file = "GettingAndCleaningDataAssingmentFinalOutput.txt", quote = TRUE, sep = " ", col.names=T, row.names=F)
