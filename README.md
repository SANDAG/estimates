The python script query SQL Server Reporting Services to generate an estimate profile
for all of the geography zones of a single geography type for a single year.

retrieve_ssrs_estimates.py [estimate_year] [geography_type] [geography_type_label] [final estimate?] [win_user] [win_user_password]

[estimate_year] = The estimate year for the requested profiles
[geography_type] = Integer geography type from data_cafe
[geography_type_label] = Used in naming the output PDFs
[final_estimate] = true / false; whether these are final profiles or just preliminary. This will affect some of the labels.
[win_user] = SANDAG windows login to reach the reporting server
[win_user_password] = SANDAG windows password to reach the reporting server

The batch (estimate_generator.bat) can be used as template to batch multiple geography types.
