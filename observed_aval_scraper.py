# -*- coding: utf-8 -*-
"""
@author: joshbullers
"""
from bs4 import BeautifulSoup
from urllib2 import urlopen
import pandas as pd
import re

baseUrl = "https://www.nwac.us/observations/"

def createAvalLists(dates):
    avalList =[]
    for count, date in enumerate(dates):
        avalList[count][0] = date
    
    return avalList
    
def extractCleanInfo(theList, regEx):
    for count, item in enumerate(theList):
        searchVal = re.search(regEx, item)
        if searchVal:
            theList[count] = searchVal.group(1)
        else:
            theList[count] = None
    return theList

html = urlopen(baseUrl).read()
soup = BeautifulSoup(html, "lxml")
dates = [str(h3.text) for h3 in soup.findAll("div", "observation-datetime")]
regions = [str(p) for p in soup.findAll("p", "observation-info")]
sitingStatus = [str(p) for p in soup.findAll("div", "observation-info")]

cleanDates = extractCleanInfo(dates, '(.*),')
cleanRegions = extractCleanInfo(regions, 'Region: <b>(.*?)<\/b>')
cleanSitings = extractCleanInfo(sitingStatus, 'Did you see any avalanches\? <b>(.*?)<\/b>')

observedAvalanches = pd.DataFrame({'Date': cleanDates, 'Region': cleanRegions, 'sawAvalanche': cleanSitings})
observedAvalanches = observedAvalanches.dropna()
observedAvalanches = observedAvalanches[observedAvalanches.sawAvalanche != 'No']

observedAvalanches.to_csv('./observedAvalanches.csv')