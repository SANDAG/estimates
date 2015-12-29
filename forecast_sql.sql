DECLARE @GEOZONE as nvarchar(15) = 'zip';
DECLARE @DATASOURCE_ID as smallint = 13;

WITH ppop as
(SELECT geozone, yr, gq_college + gq_other + gq_mil + hh as pop, hh as hhp, gq_college + gq_other + gq_mil as gq, gq_college + gq_other as gq_civ, gq_mil FROM
(SELECT
m.geozone
,p.yr
,h.short_name
,sum(p.population) pop
FROM
fact.population p
JOIN dim.housing_type h ON p.housing_type_id = h.housing_type_id
JOIN dim.mgra m ON p.mgra_id = m.mgra_id
WHERE
p.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
GROUP BY
m.geozone
,p.yr
,h.short_name) pop_table PIVOT
(AVG(pop) for short_name IN ([hh],[gq_other],[gq_mil],[gq_college])) ppop),

hs as (
SELECT geozone, yr, sf+mf+mh as hs,sf as hs_sf, mf as hs_mf, mh as hs_mh FROM
(SELECT
  m.geozone
  ,h.yr
  ,s.short_name
  ,sum(h.units) units
FROM
  fact.housing h
  JOIN dim.mgra m ON h.mgra_id = m.mgra_id
  JOIN dim.structure_type s ON h.structure_type_id = s.structure_type_id
WHERE
  h.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
GROUP BY
  m.geozone,h.yr,s.short_name) units_table pivot
(AVG(units) FOR short_name IN ([sf],[mf],[mh])) hunits),
hh as (
SELECT geozone, yr, sf+mf+mh as hh,sf as hh_sf, mf as hh_mf, mh as hh_mh FROM
(SELECT
  m.geozone
  ,h.yr
  ,s.short_name
  ,sum(h.occupied) hh
FROM
  fact.housing h
  JOIN dim.mgra m ON h.mgra_id = m.mgra_id
  JOIN dim.structure_type s ON h.structure_type_id = s.structure_type_id
WHERE
  h.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
GROUP BY
  m.geozone,h.yr,s.short_name) hh_table pivot
(AVG(hh) FOR short_name IN ([sf],[mf],[mh])) hh),

tot_jobs as (
SELECT
  m.geozone
  ,j.yr
  ,sum(j.jobs) emp
FROM fact.jobs j
JOIN dim.mgra m ON j.mgra_id = m.mgra_id
JOIN dim.employment_type e on j.employment_type_id = e.employment_type_id
WHERE datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
GROUP BY   m.geozone,j.yr
),
civ_jobs as (
SELECT
  m.geozone
  ,j.yr
  ,sum(j.jobs) emp_civ
FROM fact.jobs j
JOIN dim.mgra m ON j.mgra_id = m.mgra_id
JOIN dim.employment_type e on j.employment_type_id = e.employment_type_id
WHERE datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE and e.civilian = 1
GROUP BY   m.geozone,j.yr),
mil_jobs as (
SELECT
  m.geozone
  ,j.yr
  ,sum(j.jobs) emp_mil
FROM fact.jobs j
JOIN dim.mgra m ON j.mgra_id = m.mgra_id
JOIN dim.employment_type e on j.employment_type_id = e.employment_type_id
WHERE datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE and e.civilian = 0
GROUP BY   m.geozone,j.yr),
income as
(
SELECT
geozone
,yr
,[1] as i1
,[2] as i2
,[3] as i3
,[4] as i4
,[5] as i5
,[6] as i6
,[7] as i7
,[8] as i8
,[9] as i9
,[10] as i10
 FROM 
(SELECT
  m.geozone
  ,i.yr
  ,CASE (i.income_group_id % 10)
  WHEN 0 THEN 10
  ELSE (i.income_group_id % 10)
  END income_group
  ,sum(i.households) hh
FROM 
  fact.household_income i
  JOIN dim.mgra m ON i.mgra_id = m.mgra_id
  WHERE i.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
  GROUP BY m.geozone,i.yr, i.income_group_id) income_tbl PIVOT
  (AVG(hh) FOR income_group IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10])) as pivot_tbl
),
med_inc AS
(
  SELECT geozone, yr, median_inc FROM [app].[fn_median_income] (@DATASOURCE_ID, @GEOZONE)
),
age AS
(
SELECT geozone, yr, [Under 5] as pop_0to4
  , [5 to 9] as pop_5to9
  , [10 to 14] as pop_10to14
  , [15 to 17] as pop_15to17
  , [18 and 19] as pop_18to19
  , [20 to 24] as pop_20to24
  ,[25 to 29] as pop_25to29
  ,[30 to 34] as pop_30to34
  ,[35 to 39] as pop_35to39
  ,[40 to 44] as pop_40to44
  ,[45 to 49] as pop_45to49
  ,[50 to 54] as pop_50to54
  ,[55 to 59] as pop_55to59
  ,[60 and 61] as pop_60to61
  ,[62 to 64] as pop_62to64
  ,[65 to 69] as pop_65to69
  ,[70 to 74] as pop_70to74
  ,[75 to 79] as pop_75to79
  ,[80 to 84] as pop_80to84
  ,[85 and Older] as pop_85plus FROM
(
SELECT
  m.geozone
  ,ase.yr
  ,a.name age_group
  ,sum(population) pop
FROM
  fact.age_sex_ethnicity ase
  JOIN dim.mgra m ON ase.mgra_id = m.mgra_id
  JOIN dim.age_group a ON ase.age_group_id = a.age_group_id
WHERE
  ase.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
GROUP BY
   m.geozone, ase.yr, ase.age_group_id, a.name) as ageTbl PIVOT
(AVG(pop) FOR age_group IN (
  [Under 5]
  , [5 to 9]
  , [10 to 14]
  , [15 to 17]
  , [18 and 19]
  , [20 to 24]
  ,[25 to 29]
  ,[30 to 34]
  ,[35 to 39]
  ,[40 to 44]
  ,[45 to 49]
  ,[50 to 54]
  ,[55 to 59]
  ,[60 and 61]
  ,[62 to 64]
  ,[65 to 69]
  ,[70 to 74]
  ,[75 to 79]
  ,[80 to 84]
  ,[85 and Older])) as pivot_table)
, ethnic AS (
SELECT geozone, yr, [Hispanic] hisp
 ,[White] + [Black] + [American Indian] + [Asian] + [Pacific Islander] + [Other] + [Two or More] nhisp
 ,[White] nhw
 ,[Black] nhb
 ,[American Indian] nhi
 ,[Asian] nha
 ,[Pacific Islander] nhh
 ,[Other] nho
 ,[Two or More] nh2 FROM
(SELECT
  m.geozone
  ,ase.yr
  ,e.short_name ethnic_group
  ,sum(population) pop
FROM
  fact.age_sex_ethnicity ase
  JOIN dim.mgra m ON ase.mgra_id = m.mgra_id
  JOIN dim.ethnicity e on ase.ethnicity_id = e.ethnicity_id
WHERE
  ase.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
GROUP BY
   m.geozone, ase.yr, ase.ethnicity_id, e.short_name) as ethnic_table
PIVOT
 (AVG(POP) FOR ethnic_group IN (
 [Hispanic]
 ,[White]
 ,[Black]
 ,[American Indian]
 ,[Asian]
 ,[Pacific Islander]
 ,[Other]
 ,[Two or More])) as pivot_table),
 land as (
   SELECT geozone, yr, [dev_ldsf]
      ,[dev_sf]
      ,[dev_mf]
      ,[dev_mh]
      ,[dev_oth]
      ,[dev_ag]
      ,[dev_indus]
      ,[dev_comm]
      ,[dev_office]
      ,[dev_schools]
      ,[dev_roads]
      ,[dev_parks]
      ,[dev_mil]
      ,[dev_water]
      ,[dev_mixed_use]
      ,[vac_ldsf]
      ,[vac_sf]
      ,[vac_mf]
      ,[vac_mh]
      ,[vac_oth]
      ,[vac_ag]
      ,[vac_indus]
      ,[vac_comm]
      ,[vac_office]
      ,[vac_schools]
      ,[vac_roads]
      ,[vac_mixed_use]
      ,[vac_parks]
	  ,[constrained_constrained] unusable FROM
   (SELECT
     m.geozone
	 ,lu.yr
	 ,CONCAT(dt.development_type, '_', lut.short_name) land_type
	 ,sum(lu.acres) acres
   FROM
     fact.land_use lu
	 JOIN dim.mgra m ON lu.mgra_id = m.mgra_id
	 JOIN dim.land_use_type lut ON lu.land_use_type_id = lut.land_use_type_id
	 JOIN dim.development_type dt ON lu.development_type_id = dt.development_type_id
   WHERE
     lu.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
   GROUP BY
     m.geozone,lu.yr,CONCAT(dt.development_type, '_', lut.short_name)) land_table PIVOT
   (AVG(acres) FOR land_type IN (
       [dev_ldsf]
      ,[dev_sf]
      ,[dev_mf]
      ,[dev_mh]
      ,[dev_oth]
      ,[dev_ag]
      ,[dev_indus]
      ,[dev_comm]
      ,[dev_office]
      ,[dev_schools]
      ,[dev_roads]
      ,[dev_parks]
      ,[dev_mil]
      ,[dev_water]
      ,[dev_mixed_use]
      ,[vac_ldsf]
      ,[vac_sf]
      ,[vac_mf]
      ,[vac_mh]
      ,[vac_oth]
      ,[vac_ag]
      ,[vac_indus]
      ,[vac_comm]
      ,[vac_office]
      ,[vac_schools]
      ,[vac_roads]
      ,[vac_mixed_use]
      ,[vac_parks]
	  ,[constrained_constrained])) pvt
 ), land_summary as
 (
 SELECT geozone, yr, dev, vac, dev+vac+constrained acres FROM
 (SELECT
     m.geozone
	 ,lu.yr
	 ,dt.development_type
	 ,sum(lu.acres) acres
   FROM
     fact.land_use lu
	 JOIN dim.mgra m ON lu.mgra_id = m.mgra_id
	 JOIN dim.land_use_type lut ON lu.land_use_type_id = lut.land_use_type_id
	 JOIN dim.development_type dt ON lu.development_type_id = dt.development_type_id
   WHERE
     lu.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
   GROUP BY
     m.geozone,lu.yr,dt.development_type) sum_table pivot
   (AVG(acres) FOR development_type IN ([dev],[vac],[constrained])) pvt
 )

 SELECT 
   ppop.geozone id
   ,ppop.yr year
   ,ppop.pop
   ,ppop.hhp
   ,ppop.gq
   ,ppop.gq_civ
   ,ppop.gq_mil
   ,hs.hs
   ,hs.hs_sf
   ,hs.hs_mf
   ,hs.hs_mh
   ,hh.hh
   ,hh.hh_sf
   ,hh.hh_mf
   ,hh.hh_mh
   ,tot_jobs.emp
   ,civ_jobs.emp_civ
   ,mil_jobs.emp_mil
   ,income.i1
   ,income.i2
   ,income.i3
   ,income.i4
   ,income.i5
   ,income.i6
   ,income.i7
   ,income.i8
   ,income.i9
   ,income.i10
   ,med_inc.median_inc
   ,age.pop_0to4
   ,age.pop_5to9
   ,age.pop_10to14
   ,age.pop_15to17
   ,age.pop_18to19
   ,age.pop_20to24
   ,age.pop_25to29
   ,age.pop_30to34
   ,age.pop_35to39
   ,age.pop_40to44
   ,age.pop_45to49
   ,age.pop_50to54
   ,age.pop_55to59
   ,age.pop_60to61
   ,age.pop_62to64
   ,age.pop_65to69
   ,age.pop_70to74
   ,age.pop_75to79
   ,age.pop_80to84
   ,age.pop_85plus
   ,0 as median_age
   ,ethnic.hisp
   ,ethnic.nhisp
   ,ethnic.nhw
   ,ethnic.nhb
   ,ethnic.nhi
   ,ethnic.nha
   ,ethnic.nhh
   ,ethnic.nho
   ,ethnic.nh2
   ,0 as daypop
   ,land.dev_ldsf
   ,land.dev_sf
   ,land.dev_mf
   ,land.dev_mh
   ,land.dev_oth
   ,land.dev_ag
   ,land.dev_indus
   ,land.dev_comm
   ,land.dev_office
   ,land.dev_schools
   ,land.dev_roads
   ,land.dev_parks
   ,land.dev_mil
   ,land.dev_water
   ,land.dev_mixed_use
   ,land.vac_ldsf
   ,land.vac_sf
   ,land.vac_mf
   ,land.vac_mh
   ,land.vac_oth
   ,land.vac_ag
   ,land.vac_indus
   ,land.vac_comm
   ,land.vac_office
   ,land.vac_schools
   ,land.vac_roads
   ,land.vac_mixed_use
   ,land.vac_parks
   ,0 as redev_sf_mf
   ,0 as redev_sf_emp
   ,0 as redev_mf_emp
   ,0 as redev_mh_sf
   ,0 as redev_mh_mf
   ,0 as redev_mh_emp
   ,0 as redev_ag_ldsf
   ,0 as redev_ag_mf
   ,0 as redev_ag_indus
   ,0 as redev_ag_comm
   ,0 as redev_ag_office
   ,0 as redev_ag_schools
   ,0 as redev_ag_roads
   ,0 as redev_emp_res
   ,0 as redev_emp_emp
   ,0 as infill_sf
   ,0 as infill_mf
   ,0 as infill_emp
   ,land_summary.acres as acres
   ,land_summary.dev as dev
   ,land_summary.vac as vac
   ,land.unusable
 FROM ppop
 JOIN hs ON ppop.geozone = hs.geozone and ppop.yr = hs.yr
 JOIN hh ON ppop.geozone = hh.geozone and ppop.yr = hh.yr
 JOIN tot_jobs ON ppop.geozone = tot_jobs.geozone and ppop.yr = tot_jobs.yr
 JOIN civ_jobs ON ppop.geozone = civ_jobs.geozone and ppop.yr = civ_jobs.yr
 JOIN mil_jobs ON ppop.geozone = mil_jobs.geozone and ppop.yr = mil_jobs.yr
 JOIN income ON ppop.geozone = income.geozone and ppop.yr = income.yr
 JOIN med_inc ON ppop.geozone = med_inc.geozone and ppop.yr = med_inc.yr
 JOIN age ON ppop.geozone = age.geozone and ppop.yr = age.yr
 JOIN ethnic ON ppop.geozone = ethnic.geozone and ppop.yr = ethnic.yr
 JOIN land ON ppop.geozone = land.geozone and ppop.yr = land.yr
 JOIN land_summary ON ppop.geozone = land_summary.geozone and ppop.yr = land_summary.yr
 ORDER BY    ppop.geozone, ppop.yr