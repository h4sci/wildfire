# -*- coding: utf-8 -*-
"""
Created on Tue Mar  9 17:46:42 2021

@author: scstepha
"""
#For this script to work
    #install the copernicus API 210311_copernicus python api (see 210311_copernicus python api, https://confluence.ecmwf.int/display/CKB/How+to+install+and+use+CDS+API+on+Windows, https://cds.climate.copernicus.eu/api-how-to)
        #pip install cdsapi (for this to work I needed to add PATH-value in Systemsteuerung)
    #have an account at copernicus
    #copy cds api-key and put it i user-folder in a .cdsapirc-file
    
import cdsapi
import os

os.chdir('P:/Wildfire/Raw_Data/Copernicus')
os.getcwd()
###############

c = cdsapi.Client()

daylist_req=['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31']
monthlist_req=['01','02','03','04','05','06','07','08','09','10','11','12']
yearlist_req=['2016', '2017']
timelist_req=['00:00', '06:00', '12:00', '18:00']
dataset_req='reanalysis-era5-land'
variablelist_req=['10m_u_component_of_wind', '10m_v_component_of_wind']
variablegroup='wind'

for y in yearlist_req:
    for m in monthlist_req:
        c.retrieve(
            dataset_req,
            {
                'format': 'netcdf',
                'variable': variablelist_req,
                'year': [y], 
                'month': [m],
                'day': daylist_req,
                'time': timelist_req,
            },
            "'"+y+"_"+m+"_"+dataset_req+"_"+variablegroup+".nc'")
 #reanalysis-era5-land: 2021-03-09 18:09:44 	2021-03-09 18:15:56 	0:06:11 	155.6 MB
