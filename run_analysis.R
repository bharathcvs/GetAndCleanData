library(reshape2)
##1. Reading data from files
features<-read.table("./UCI HAR Dataset/features.txt")
activities<-read.table("./UCI HAR Dataset/activity_labels.txt")
xtrain<-read.table("./UCI HAR Dataset/train/x_train.txt")
ytrain<-read.table("./UCI HAR Dataset/train/y_train.txt")
subtrain<-read.table("./UCI HAR Dataset/train/subject_train.txt")
ytest<-read.table("./UCI HAR Dataset/test/y_test.txt")
xtest<-read.table("./UCI HAR Dataset/test/x_test.txt")
subtest<-read.table("./UCI HAR Dataset/test/subject_test.txt")
##2. Merge train and test data sets
xmerged<-rbind(xtest,xtrain)
ymerged<-rbind(ytest,ytrain)
submerged<-rbind(subtest,subtrain)
##3. Extract only mean and standard deviation from the measurements
colToSelect<-features[grep("std|mean[^F]",features$V2),]
filtxmerged<-xmerged[,colToSelect$V1]
##4. set labels for the measurements for the selected columns. remove ",", "-","(",")" from the labels
colToSelect$V2<-gsub(",|-|\\(|\\)","",(colToSelect$V2))
colnames(filtxmerged)<-colToSelect$V2
##5. for activities, replace the number with the activity name
actVector<-as.character(activities$V2)
ymerged$V1<-lapply(ymerged$V1,function(x) {actVector[x]})
##6. merge the measurements data frame with the subject and activity
mergeddata<-cbind(as.numeric(submerged$V1),as.character(ymerged$V1),filtxmerged)
names(mergeddata)[1]<-"subject"
names(mergeddata)[2]<-"activity"
##7.Order the data by subject and activity
mergeddata<-mergeddata[order(mergeddata$subject,mergeddata$activity),]
##8. tidy the data and compute the mean of measurements vs subject and activity
meltdata<-melt(mergeddata,id=c("subject","activity"))
tidydata<-dcast(meltdata,subject+activity~variable,mean)
##9 write the result to a text file
write.table(tidydata,"./tidy_data.txt",row.names = FALSE)