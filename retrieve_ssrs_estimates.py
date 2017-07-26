import os
import pymssql
import sys
import urllib2

from ntlm import HTTPNtlmAuthHandler
from time import strftime

if len(sys.argv) != 5:
    sys.exit("Must provide year, geotype, user, and password")

year = sys.argv[1] 
geotype = sys.argv[2]

#Windows username and password to access report server
user = sys.argv[3]
password = sys.argv[4]

#Database User Name and Password
db_server = 'sql2014a8'
db_name = 'demographic_warehouse'
db_user = user
db_password = password
 

output_path = 'estimates_{0}_{1}'.format(year, strftime('%Y_%m_%d'))

if not (os.access(output_path, os.F_OK)):
    os.mkdir(os.getcwd() + '/' + output_path)

if not (os.access(output_path + '/' + geotype, os.F_OK)):
    os.mkdir(os.getcwd() + '/' + output_path + '/' + geotype)

conn = pymssql.connect(host=db_server, user=db_user, password=db_password, database=db_name)
cur = conn.cursor()

geo_sql = "SELECT RTRIM(m.geozone),ds.datasource_id FROM demographic_warehouse.dim.datasource ds INNER JOIN dim.mgra m ON ds.series = m.series WHERE ds.datasource_type_id = 2 and is_active = 1 and publish_year = 2016 and m.geotype = '{0}' and RTRIM(geozone) is not null GROUP BY m.geozone, ds.datasource_id".format(geotype)

cur.execute(geo_sql)

for row in cur:

    url = 'http://sql2014a8/ReportServer?%2festimates%2fEstimate+Profile_sr13_sql2014a8&GEOTYPE={0}&GEOZONE={1}&DATASOURCE_ID={2}&YEAR={3}&rs:Format=PDF'.format(geotype, urllib2.quote(row[0]), row[1], year)
    
    print url
    
    passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
    passman.add_password(None, url, user, password)

    auth_NLTM = HTTPNtlmAuthHandler.HTTPNtlmAuthHandler(passman)

    opener = urllib2.build_opener(auth_NLTM)

    urllib2.install_opener(opener)

    pagehandle = urllib2.urlopen(url)

    outpath = '{0}\\{1}\\sandag_estimate_{2}_{3}_{4}.pdf'.format(output_path, geotype, year,geotype, row[0].replace('%20',' '))
    print outpath
    
    localFile = open(outpath, 'wb')
    localFile.write(pagehandle.read())
    localFile.close()