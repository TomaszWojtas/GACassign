url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, "dataset.zip")
unzip("dataset.zip")
setwd("UCI HAR Dataset")
library(data.table)
library(dplyr)

## 1
##reading data from files
testlab <- read.table("test/y_test.txt", col.names="label")
testsub <- read.table("test/subject_test.txt", col.names = "subject")
testdata <- read.table("test/X_test.txt")

trainlab <- read.table("train/y_train.txt", col.names = "label")
trainsub <- read.table("train/subject_train.txt", col.names = "subject")
traindata <- read.table("train/X_train.txt")

##binding data in one file
data <- rbind(cbind(testsub, testlab, testdata),
              cbind(trainsub, trainlab, traindata))
dim(data) ##just for check if dimensions are ok

## 2
features <- read.table("features.txt", strip.white = TRUE, 
                       stringsAsFactors = FALSE)
featuresmeanstd <- features[grep("mean\\(\\)|std\\(\\)",
                                 features$V2), ]
datameanstd <- data[,c(1,2, featuresmeanstd$V1+2)]

##3
data$label <- as.character(data$label)
labels <- read.table("activity_labels.txt", header=FALSE)
for(i in 1:6)
{
        data$label[data$label==i] <- as.character(labels[i,2])
}

##4
correctnames <- c("subject", "label", featuresmeanstd$V2)
correctnames <- tolower(gsub("[^[:alpha:]]", "", correctnames))
colnames(datameanstd) <- correctnames
names(datameanstd)
dim(datameanstd)

##5
tidydata <- aggregate(datameanstd[,3:ncol(datameanstd)],
                      by=list(subject = datameanstd$subject,
                              label=datameanstd$label), mean)

##savind data
write.table(format(tidydata, scientific=T), "Tidy.txt",
            row.names=F, col.names = F, quote=2)
