import os
import pymssql
import sys
import urllib2

from ntlm import HTTPNtlmAuthHandler
from time import strftime

if len(sys.argv) != 5:
    sys.exit("Must provide datasource_id, geotype, user, and password")

datasource_id = sys.argv[1] 
geotype = sys.argv[2]

#Windows username and password to access report server
user = sys.argv[3]
password = sys.argv[4]

#Database User Name and Password
db_server = 'sql2014a8'
db_name = 'demographic_warehouse'
db_user = user
db_password = password
 

output_path = 'estimates_{0}_{1}'.format(datasource_id, strftime('%Y_%m_%d'))

if not (os.access(output_path, os.F_OK)):
    os.mkdir(os.getcwd() + '/' + output_path)
    os.mkdir(os.getcwd() + '/' + output_path + '/' + geotype)

conn = pymssql.connect(host=db_server, user=db_user, password=db_password, database=db_name)
cur = conn.cursor()

geo_sql = "SELECT lower(REPLACE(RTRIM(mgra.geozone), ' ', '%20')), ds.yr, ds.datasource_id FROM demographic_warehouse.dim.datasource ds JOIN demographic_warehouse.dim.mgra mgra ON ds.series = mgra.series WHERE ds.yr = {0} and mgra.geotype = '{1}' and ds.datasource_type_id = 2 and vintage = 2015 GROUP BY mgra.geozone, ds.yr, ds.datasource_id".format(datasource_id, geotype)

cur.execute(geo_sql)

for row in cur:
    url = 'http://sql2014a8/ReportServer?%2festimates%2fEstimate+Profile_sr13_sql2014a8&GEOTYPE={0}&GEOZONE={1}&DATASOURCE_ID={2}&rs:Format=PDF'.format(geotype, row[0], row[2])
    
    print url
    
    passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
    passman.add_password(None, url, user, password)

    auth_NLTM = HTTPNtlmAuthHandler.HTTPNtlmAuthHandler(passman)

    opener = urllib2.build_opener(auth_NLTM)

    urllib2.install_opener(opener)

    pagehandle = urllib2.urlopen(url)

    localFile = open('{0}\\sandag_estimate_{1}_{2}_{3}.pdf'.format(output_path, row[1],geotype, row[0].replace('%20',' ')), 'wb')
    localFile.write(pagehandle.read())
    localFile.close()