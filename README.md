---
title: "Readme for run_analysis.R"
author: "Bharath"
date: "July 26, 2015"
output: html_document
---
##							                    README
### Assumptions:
    The script assumes that the data is present in the "UCI HAR Dataset" directory in the working          directory
### Working:
1. Read the required data using the read.table()

    ```{r}
    features<-read.table("./UCI HAR Dataset/features.txt")
    activities<-read.table("./UCI HAR Dataset/activity_labels.txt")
    xtrain<-read.table("./UCI HAR Dataset/train/x_train.txt")
    ytrain<-read.table("./UCI HAR Dataset/train/y_train.txt")
    subtrain<-read.table("./UCI HAR Dataset/train/subject_train.txt")
    ytest<-read.table("./UCI HAR Dataset/test/y_test.txt")
    xtest<-read.table("./UCI HAR Dataset/test/x_test.txt")
    subtest<-read.table("./UCI HAR Dataset/test/subject_test.txt")
    ```
2. Merge the train and test data sets for each of the 3 types of files(x_,y_,subject_) containing data of measurements, activities, subjects. This is done using the rbind command

    ```{r}
    xmerged<-rbind(xtest,xtrain)
    ymerged<-rbind(ytest,ytrain)
    submerged<-rbind(subtest,subtrain)
    ```
3. Extract only measurements pertaining to mean and standard deviation.Note that the features.txt has the labels we need.We use the grep command to find the list of columns and pass that to the data set

    ```{r}
    colToSelect<-features[grep("std|mean[^F]",features$V2),]
    filtxmerged<-xmerged[,colToSelect$V1]
    ```
4. Clean the labels to rid them of "," "-" ")" "(". Then set the labels to the measurements data set.

    ```{r}
    colToSelect$V2<-gsub(",|-|\\(|\\)","",(colToSelect$V2))
    colnames(filtxmerged)<-colToSelect$V2
    ```
5. For activities, replace the activity number with the activity name. We use lapply for this.
   Note that the number<->activity name info is found in activity_labels.txt.

    ```{r}
    actVector<-as.character(activities$V2)
    ymerged$V1<-lapply(ymerged$V1,function(x) {actVector[x]})
    ```
6. Merge the subject, activities, measurements data sets using cbind
   Ensure that labels of the newly bound subject and activities columns are set properly

    ```{r}
    mergeddata<-cbind(as.numeric(submerged$V1),as.character(ymerged$V1),filtxmerged)
    names(mergeddata)[1]<-"subject"
    names(mergeddata)[2]<-"activity"
    ```
7. Order the data by subject and activity using order()

    ```{r}
    mergeddata<-mergeddata[order(mergeddata$subject,mergeddata$activity),]
    ```
8. Tidy the data using melt and dcast. We compute the average of each variable against subject+activity combination.

    ```{r}
    meltdata<-melt(mergeddata,id=c("subject","activity"))
    tidydata<-dcast(meltdata,subject+activity~variable,mean)
    ```
9. Write the result to a text file using write.table.

    ```{r}
    write.table(tidydata,"./tidy_data.txt",row.names = FALSE)
    ```