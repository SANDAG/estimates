/*##############
LOAD TO AGE_SEX_ETHNICITY
##############*/
INSERT INTO demographic_warehouse.fact.age_sex_ethnicity (datasource_id,yr,mgra_id,age_group_id,sex_id,ethnicity_id,population)
SELECT
  ds.datasource_id
  ,estimates_year as yr
  ,1300000 + mgra as mgra_id
  ,age.age_group_id
  ,CASE SUBSTRING(cohort, 4,1)
    WHEN 'f' THEN 1
    ELSE 2
  END as sex_id
  ,ethnicity as ethnicity_id
  ,pop as population
FROM
(SELECT [estimates_year]
      ,[mgra]
      ,[ethnicity]
      ,[popm_0to4]
      ,[popm_5to9]
      ,[popm_10to14]
      ,[popm_15to17]
      ,[popm_18to19]
      ,[popm_20to24]
      ,[popm_25to29]
      ,[popm_30to34]
      ,[popm_35to39]
      ,[popm_40to44]
      ,[popm_45to49]
      ,[popm_50to54]
      ,[popm_55to59]
      ,[popm_60to61]
      ,[popm_62to64]
      ,[popm_65to69]
      ,[popm_70to74]
      ,[popm_75to79]
      ,[popm_80to84]
      ,[popm_85plus]
      ,[popf_0to4]
      ,[popf_5to9]
      ,[popf_10to14]
      ,[popf_15to17]
      ,[popf_18to19]
      ,[popf_20to24]
      ,[popf_25to29]
      ,[popf_30to34]
      ,[popf_35to39]
      ,[popf_40to44]
      ,[popf_45to49]
      ,[popf_50to54]
      ,[popf_55to59]
      ,[popf_60to61]
      ,[popf_62to64]
      ,[popf_65to69]
      ,[popf_70to74]
      ,[popf_75to79]
      ,[popf_80to84]
      ,[popf_85plus]
  FROM [estimates].[concep].[detailed_pop_tab_mgra]
  WHERE ethnicity <> 0) upvt
  UNPIVOT (pop for cohort IN ([popm_0to4]
      ,[popm_5to9]
      ,[popm_10to14]
      ,[popm_15to17]
      ,[popm_18to19]
      ,[popm_20to24]
      ,[popm_25to29]
      ,[popm_30to34]
      ,[popm_35to39]
      ,[popm_40to44]
      ,[popm_45to49]
      ,[popm_50to54]
      ,[popm_55to59]
      ,[popm_60to61]
      ,[popm_62to64]
      ,[popm_65to69]
      ,[popm_70to74]
      ,[popm_75to79]
      ,[popm_80to84]
      ,[popm_85plus]
      ,[popf_0to4]
      ,[popf_5to9]
      ,[popf_10to14]
      ,[popf_15to17]
      ,[popf_18to19]
      ,[popf_20to24]
      ,[popf_25to29]
      ,[popf_30to34]
      ,[popf_35to39]
      ,[popf_40to44]
      ,[popf_45to49]
      ,[popf_50to54]
      ,[popf_55to59]
      ,[popf_60to61]
      ,[popf_62to64]
      ,[popf_65to69]
      ,[popf_70to74]
      ,[popf_75to79]
      ,[popf_80to84]
      ,[popf_85plus])) as cohort
JOIN (SELECT age_group_id, CASE lower_bound WHEN 85 THEN '85plus' ELSE CONCAT(lower_bound, 'to', upper_bound) END as age_group_desc FROM demographic_warehouse.dim.age_group) age ON RIGHT(cohort, LEN(cohort) - 5) = age.age_group_desc
JOIN (SELECT datasource_id, yr FROM demographic_warehouse.dim.datasource WHERE vintage = 2015 and datasource_type_id = 2) ds ON cohort.estimates_year = ds.yr


INSERT INTO demographic_warehouse.fact.age (datasource_id,yr,mgra_id,age_group_id,population)
SELECT
  ds.datasource_id
  ,ase.yr
  ,ase.mgra_id
  ,ase.age_group_id
  ,sum(population) population
FROM
  demographic_warehouse.fact.age_sex_ethnicity ase
  JOIN demographic_warehouse.dim.datasource ds ON ase.datasource_id = ds.datasource_id
WHERE
  ds.vintage = 2015 and ds.datasource_type_id = 2
GROUP BY
  ds.datasource_id
  ,ase.yr
  ,ase.mgra_id
  ,ase.age_group_id 
GO

INSERT INTO demographic_warehouse.fact.ethnicity(datasource_id, yr, mgra_id,ethnicity_id,population)
SELECT
  ds.datasource_id
  ,ase.yr
  ,ase.mgra_id
  ,ase.ethnicity_id
  ,sum(population) population
FROM
  demographic_warehouse.fact.age_sex_ethnicity ase
  JOIN demographic_warehouse.dim.datasource ds ON ase.datasource_id = ds.datasource_id
WHERE
  ds.vintage = 2015 and ds.datasource_type_id = 2
GROUP BY
  ds.datasource_id
  ,ase.yr
  ,ase.mgra_id
  ,ase.ethnicity_id
GO

INSERT INTO demographic_warehouse.fact.sex(datasource_id, yr, mgra_id, sex_id, population)
SELECT
  ds.datasource_id
  ,ase.yr
  ,ase.mgra_id
  ,ase.sex_id
  ,sum(population) population
FROM
  demographic_warehouse.fact.age_sex_ethnicity ase
  JOIN demographic_warehouse.dim.datasource ds ON ase.datasource_id = ds.datasource_id
WHERE
  ds.vintage = 2015 and ds.datasource_type_id = 2
GROUP BY
  ds.datasource_id
  ,ase.yr
  ,ase.mgra_id
  ,ase.sex_id
GO


/*##############################
INSERT INCOME
################################*/
INSERT INTO demographic_warehouse.fact.household_income (datasource_id, yr, mgra_id, income_group_id, households)
SELECT
  datasource_id
  ,yr
  ,mgra_id
  ,CAST(RIGHT(inc_group, len(inc_group) - 1) as int) + 10 as income_group_id
  ,households
FROM
(SELECT
  ds.datasource_id as datasource_id
  ,estimates_year as yr
  ,1300000 + mgra as mgra_id
  ,[i1]
  ,[i2]
  ,[i3]
  ,[i4]
  ,[i5]
  ,[i6]
  ,[i7]
  ,[i8]
  ,[i9]
  ,[i10]
  FROM [estimates].[concep].[income_estimates_mgra] i
  JOIN (SELECT datasource_id, yr FROM demographic_warehouse.dim.datasource WHERE vintage = 2015 and datasource_type_id = 2) ds ON i.estimates_year = ds.yr) unpvt
  UNPIVOT (households for inc_group IN ([i1],[i2],[i3],[i4],[i5],[i6],[i7],[i8],[i9],[i10])) inc

  
 /*##############################
Housing by Structure Type
################################*/
  INSERT INTO demographic_warehouse.fact.housing (datasource_id,yr,mgra_id,structure_type_id,units,occupied,vacancy)
SELECT
  hs.datasource_id
  ,hs.yr
  ,hs.mgra_id
  ,hs.structure_type_id
  ,hs.units
  ,hh.hh occupied
  ,CASE
    WHEN hs.units > 0 THEN 1.0 - CAST(hh.hh as float) / CAST(hs.units as float)
	ELSE 0
  END vacancy
FROM 
(SELECT
  datasource_id
  ,yr
  ,mgra_id
  ,CASE structure_type
    WHEN 'hs_sf' THEN 1
    WHEN 'hs_sfmu' THEN  2
    WHEN 'hs_mf' THEN 3
    ELSE 4
  END structure_type_id
  ,units
FROM
(SELECT 
  ds.datasource_id
  ,popest.estimates_year as yr
  ,1300000 + [mgra] as mgra_id
      ,[hs_sf]
      ,[hs_sfmu]
      ,[hs_mf]
      ,[hs_mh]
  FROM [estimates].[concep].[popest_mgra] popest
  JOIN (SELECT datasource_id, yr FROM demographic_warehouse.dim.datasource WHERE vintage = 2015 and datasource_type_id = 2) ds ON popest.estimates_year = ds.yr) unpvt
  UNPIVOT (units for structure_type in ([hs_sf],[hs_sfmu],[hs_mf],[hs_mh])) hs) hs
JOIN
(
SELECT
  datasource_id
  ,yr
  ,mgra_id
  ,CASE structure_type
    WHEN 'hh_sf' THEN 1
    WHEN 'hh_sfmu' THEN  2
    WHEN 'hh_mf' THEN 3
    ELSE 4
  END structure_type_id
  ,hh
FROM
(SELECT 
  ds.datasource_id
  ,popest.estimates_year as yr
  ,1300000 + [mgra] as mgra_id
  ,[hh_sf]
  ,[hh_sfmu]
  ,[hh_mf]
  ,[hh_mh]
  FROM [estimates].[concep].[popest_mgra] popest
  JOIN (SELECT datasource_id, yr FROM demographic_warehouse.dim.datasource WHERE vintage = 2015 and datasource_type_id = 2) ds ON popest.estimates_year = ds.yr) unpvt
  UNPIVOT (hh for structure_type in ([hh_sf],[hh_sfmu],[hh_mf],[hh_mh])) hh) hh ON hs.datasource_id = hh.datasource_id AND hs.mgra_id = hh.mgra_id AND hs.structure_type_id = hh.structure_type_id

/*##############################
Population by Housing Type
################################*/
  INSERT INTO demographic_warehouse.fact.population (datasource_id,yr,mgra_id,housing_type_id,population)
SELECT
  datasource_id
  ,yr
  ,mgra_id
  ,CASE housing_type
    WHEN 'hhp' THEN 1
    WHEN 'gq_mil' THEN 2
    WHEN 'gq_civ_college' THEN 3
    WHEN 'gq_civ_other' THEN 4
  END as housing_type_id
  ,pop
FROM
(SELECT
  ds.datasource_id datasource_id
  ,popest.estimates_year yr
  ,1300000 + popest.mgra mgra_id
  ,popest.hhp
  ,popest.gq_mil
  ,popest.gq_civ_college
  ,popest.gq_civ_other
FROM estimates.concep.popest_mgra popest
JOIN (SELECT datasource_id, yr FROM demographic_warehouse.dim.datasource WHERE vintage = 2015 and datasource_type_id = 2) ds ON popest.estimates_year = ds.yr) unpvt
UNPIVOT (pop FOR housing_type IN (hhp,gq_mil,gq_civ_college,gq_civ_other)) pop