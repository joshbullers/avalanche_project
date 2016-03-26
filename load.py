# -*- coding: utf-8 -*-
"""
@author: joshbullers
"""

import glob
import pandas as pd


minTempPath =r'/Users/joshbullers/Desktop/Data Science/avalanche_project/snotelMinTemp'
maxTempPath =r'/Users/joshbullers/Desktop/Data Science/avalanche_project/snotelMaxTemp'
snowWaterPath =r'/Users/joshbullers/Desktop/Data Science/avalanche_project/snotelSnowWater'
maxTempFiles = glob.glob(maxTempPath + '/*.txt')
minTempFiles = glob.glob(minTempPath + '/*.txt')
snowWaterFiles = glob.glob(snowWaterPath + '/*.txt')

minTempList = []
maxTempList = []
snowWaterList = []

for filename in minTempFiles:
    minTempList.append(pd.read_csv(filename, delim_whitespace = True, header = None, skiprows = 10))

for filename in maxTempFiles:
    maxTempList.append(pd.read_csv(filename, delim_whitespace = True, header = None, skiprows = 10))

for filename in snowWaterFiles:
    snowWaterList.append(pd.read_csv(filename, delim_whitespace = True, header = None, skiprows = 10))
    
df_minTemp = pd.concat(minTempList, ignore_index = True)
df_maxTemp = pd.concat(maxTempList, ignore_index = True)
df_snowWater = pd.concat(snowWaterList, ignore_index = True)

df_minTemp.columns = ["dataCard", "month/year", "day", "minTemp"]
df_maxTemp.columns = ["dataCard", "month/year", "day", "maxTemp"]
df_snowWater.columns = ["dataCard", "month/year", "day", "inches"]

df_minTemp.to_csv("./snotelMinTemps.csv")
df_maxTemp.to_csv("./snotelMaxTemps.csv")
df_snowWater.to_csv("./snotelSnowWater.csv")
