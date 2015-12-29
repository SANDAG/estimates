The python script query SQL Server Reporting Services to generate an estimate profile
for all of the geography zones of a single geography type for a single year.

retrieve_ssrs_estimates.py [estimate_year] [geography_type] [user] [password]

[estimate_year] = The estimate year for the requested profiles
[geography_type] = Integer geography type from data_cafe
[win_user] = login to reach the reporting server
[win_user_password] = password to reach the reporting server

** Valid Geography Types **
college
cpa
cwa
elementary
jurisdiction
msa
region
sdcouncil
secondary
sra
supervisorial
tract
unified
zip