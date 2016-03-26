# -*- coding: utf-8 -*-
"""
@author: joshbullers

The purpose of this scraper is to extract the data from html tables
on the nwac accident reports site.
"""

from bs4 import BeautifulSoup
from urllib2 import urlopen
import pandas as pd
import re

baseUrl = "https://www.nwac.us/accidents/accident-reports/"

def getTableHeaders(url):
    html = urlopen(url).read()
    soup = BeautifulSoup(html, "lxml")
    headers = [str(th.string) for th in soup.findAll("th")]
    return headers[0:4]

def getTableData(url):
    tableData = []    
    
    html = urlopen(url).read()
    soup = BeautifulSoup(html, "lxml")
    
    for table in soup.findAll("table"):
        for tr in table.findAll("tr"):
            tds = [str(td) for td in tr.findAll("td")]
            tableData.append(tds)
    
    return tableData

def cleanData(theList):
    for index, row in enumerate(theList):
        for index2, item in enumerate(row):
            theList[index][index2] = re.sub('<(.*?)>', '', item)
            
    return theList



rawHeaders = getTableHeaders(baseUrl)
tableData = getTableData(baseUrl)

cleanedData = cleanData(tableData)       

avalDF = pd.DataFrame(cleanedData)
avalDF = avalDF.drop(4, axis = 1)
avalDF.columns = rawHeaders
avalDF = avalDF.dropna()

avalDF.to_csv('./recordedAvalanches.csv')