library(sqldf)

df_snowWater <- read.csv('./snotelSnowWater.csv', header = TRUE)
df_maxTemp <- read.csv('./snotelMaxTemps.csv', header = TRUE)
df_minTemp <- read.csv('./snotelMinTemps.csv', header = TRUE)
df_observedAvalanches <- read.csv('./observedAvalanches.csv', header = TRUE)
df_snotelMapping <- read.csv('./regionToSnotelMap.csv', header = TRUE)

df_snotelData <- sqldf('SELECT df_snowWater.*, df_maxTemp.maxTemp, df_minTemp.minTemp
                        FROM df_snowWater
                        LEFT JOIN df_maxTemp, df_minTemp
                        ON df_snowWater.dataCard = df_maxTemp.dataCard AND df_snowWater.monthYear = df_maxTemp.monthYear AND
                        df_snowWater.day = df_maxTemp.day AND df_snowWater.day = df_minTemp.day AND df_snowWater.dataCard = df_minTemp.dataCard
                        AND df_snowWater.monthYear =df_minTemp.monthYear')

df_snotelData <- df_snotelData[df_snotelData$dataCard %in% df_snotelMapping$SnotelSite,]

df_snotelData$monthYear <- unlist(sapply(df_snotelData$monthYear, function(x) {
                                  if(nchar(as.character(x)) == 3) {
                                    return(paste("0",x, sep = ""))
                                  } else {
                                      return(x)
                                  }}))

df_snotelData$day <- unlist(sapply(df_snotelData$day, function(x) {
                                  if (nchar(as.character(x)) == 1) {
                                    return(paste("0",x,sep = ""))
                                  } else {
                                    return(x)
                                  }}))

fullDate <- paste(df_snotelData$day, df_snotelData$monthYear, sep = "")

df_snotelData$date <- as.Date(fullDate, format = '%d%m%y')

df_observedAvalanches <- sqldf('SELECT df_observedAvalanches.*, df_snotelMapping.SnotelSite 
                               FROM df_observedAvalanches 
                               LEFT JOIN df_snotelMapping 
                               ON df_observedAvalanches.Region = df_snotelMapping.Region')

df_observedAvalanches$correctDate <- sapply(df_observedAvalanches$Date, function(x) {
                                              if (grepl('\\.', x)) {
                                                newDate <- as.character(as.Date(x, format = '%b. %d, %Y'))
                                                return(newDate)
                                              } else {
                                                newDate <- as.character(as.Date(x, format = '%B %d, %Y'))
                                                return(newDate)
                                              }
                                            })

df_observedAvalanches$correctDate <- as.Date(df_observedAvalanches$correctDate)

df_finalData <- sqldf('SELECT df_snotelData.*, df_observedAvalanches.sawAvalanche
                      FROM df_snotelData
                      LEFT JOIN df_observedAvalanches
                      ON df_snotelData.date = df_observedAvalanches.correctDate AND df_snotelData.dataCard = df_observedAvalanches.SnotelSite')

df_finalData <- df_finalData[df_finalData$date >= as.Date('2014-11-01'),]
df_finalData <- df_finalData[df_finalData$inches > 0,]

df_noBadSnowWater <- df_snotelData[df_snotelData$inches != -999,]
df_noBadMinTemps <- df_snotelData[df_snotelData$minTemp != -999,]
df_noBadMaxTemps <- df_snotelData[df_snotelData$maxTemp != -999,]
