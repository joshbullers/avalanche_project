df_fullData <- read.csv('./finalWeather.csv', header = TRUE)
df_fullData$date <- as.Date(df_fullData$date, format = '%m/%d/%y')

df_noSample <- df_fullData[as.character(df_fullData$sawAvalanche) == "No",]
df_yesSample <- df_fullData[as.character(df_fullData$sawAvalanche) == "Yes",]
df_noSample <- df_noSample[complete.cases(df_noSample),]
df_yesSample <- df_yesSample[complete.cases(df_yesSample),]

calcPriorDayAverages <- function(df, days) {
  highName <- sprintf("%sDayHighMaxTemp", days)
  lowName <- sprintf("%sDayLowMinTemp", days)
  snowGain <- sprintf("%sDaySnowChange", days)
  
  for (count in 1:nrow(df)) {
    currentSite <- df[count, "dataCard"]
    priorDayDate <- df[count, "date"] - days
    miniDf <- df_fullData[df_fullData$date < df[count,"date"] & df_fullData$date >= priorDayDate & df_fullData$dataCard == currentSite,]
  
    # Calcs from 3day dataframe
    df[count, c(highName)] <- max(miniDf$maxTemp)
    df[count, c(lowName)] <- min(miniDf$minTemp)
    df[count, c(snowGain)] <- as.numeric(miniDf[nrow(miniDf), "inches"]) - as.numeric(miniDf[1,"inches"])
  }
  return(df)
}

priorDayNums <- function(df) {
  
}

# No sample calculations
noMeanMaxTemp <- mean(as.numeric(df_noSample$maxTemp))
noMeanMinTemp <- mean(as.numeric(df_noSample$minTemp))
noMeanSnowWaterDepth <- mean(as.numeric(df_noSample$inches))

df_noSample <- calcPriorDayAverages(df_noSample, 3)
df_noSample <- calcPriorDayAverages(df_noSample, 7)

# Yes sample calculations
yesMeanMaxTemp <- mean(as.numeric(df_yesSample$maxTemp))
yesMeanMinTemp <- mean(as.numeric(df_yesSample$minTemp))
yesMeanSnowWaterDepth <- mean(as.numeric(df_yesSample$inches))

df_yesSample <- calcPriorDayAverages(df_yesSample, 3)
df_yesSample <- calcPriorDayAverages(df_yesSample, 7)