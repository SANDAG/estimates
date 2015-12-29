DECLARE @GEOZONE as nvarchar(15) = 'msa';
DECLARE @DATASOURCE_ID as smallint = 13;

SELECT
  geozone
  ,yr
  ,[hhp] + [gq_civ] + [gq_mil] as pop
  ,[hhp],[gq_civ],[gq_mil]
  ,[hs_sf]+[hs_mf]+[hs_mh] as hs
  ,[hs_sf],[hs_mf],[hs_mh]
  ,[hh_sf]+[hh_mf]+[hh_mh] as hh
  ,[hh_sf],[hh_mf],[hh_mh]
  ,[emp],[emp_civ],[emp_mil]
  ,[i1],[i2],[i3],[i4],[i5],[i6],[i7],[i8],[i9],[i10]
  ,CASE
	WHEN ((i1)) > (([hh_sf]  + [hh_mf] + [hh_mh]) / 2)                            THEN          ROUND(15000 * (([hh_sf]  + [hh_mf] + [hh_mh]) / 2.0)                                          / (i1),  0)
	WHEN (i1 + i2) > (([hh_sf]  + [hh_mf] + [hh_mh]) / 2)                       THEN  15000 + ROUND(15000 * (([hh_sf]  + [hh_mf] + [hh_mh]) / 2.0 - (i1))                              / (i2),  0)
	WHEN (i1 + i2 + i3) > (([hh_sf]  + [hh_mf] + [hh_mh]) / 2)                THEN  30000 + ROUND(15000 * (([hh_sf]  + [hh_mf] + [hh_mh]) / 2.0 - (i1 + i2))                       / (i3),  0)
	WHEN (i1 + i2 + i3 + i4) > (([hh_sf]  + [hh_mf] + [hh_mh]) / 2)         THEN  45000 + ROUND(15000 * (([hh_sf]  + [hh_mf] + [hh_mh]) / 2.0 - (i1 + i2 + i3))                / (i4),  0)
	WHEN (i1 + i2 + i3 + i4 + i5) > (([hh_sf]  + [hh_mf] + [hh_mh]) / 2)  THEN  60000 + ROUND(15000 * (([hh_sf]  + [hh_mf] + [hh_mh]) / 2.0 - (i1 + i2 + i3 + i4))         / (i5),  0)
	WHEN ([hh_sf]  + [hh_mf] + [hh_mh] - i10 - i9 - i8 - i7) > (([hh_sf]  + [hh_mf] + [hh_mh]) / 2) THEN  75000 + ROUND(25000 * (([hh_sf]  + [hh_mf] + [hh_mh]) / 2.0 - (i1 + i2 + i3 + i4 + i5))  / (i6),  0)
	WHEN ([hh_sf]  + [hh_mf] + [hh_mh] - i10 - i9 - i8) > (([hh_sf]  + [hh_mf] + [hh_mh]) / 2)        THEN 100000 + ROUND(25000 * (([hh_sf]  + [hh_mf] + [hh_mh]) / 2.0 - ([hh_sf]  + [hh_mf] + [hh_mh] - i10 - i9 - i8 - i7)) / (i7),  0)
	WHEN ([hh_sf]  + [hh_mf] + [hh_mh] - i10 - i9) > (([hh_sf]  + [hh_mf] + [hh_mh]) / 2)               THEN 125000 + ROUND(25000 * (([hh_sf]  + [hh_mf] + [hh_mh]) / 2.0 - ([hh_sf]  + [hh_mf] + [hh_mh] - i10 - i9 - i8))        / (i8),  0)
	WHEN ([hh_sf]  + [hh_mf] + [hh_mh] - i10) > (([hh_sf]  + [hh_mf] + [hh_mh]) / 2)                      THEN 150000 + ROUND(50000 * (([hh_sf]  + [hh_mf] + [hh_mh]) / 2.0 - ([hh_sf]  + [hh_mf] + [hh_mh] - i10 - i9))               / (i9),  0)
	ELSE 200000 + ROUND(150000 * (([hh_sf]  + [hh_mf] + [hh_mh]) / 2.0 - ([hh_sf]  + [hh_mf] + [hh_mh] - i10))                     / (i10), 0)
  END as inc_median
  ,[pop_0to4],[pop_5to9],[pop_10to14],[pop_15to17],[pop_18to19],[pop_20to24],[pop_25to29],[pop_30to34],[pop_35to39],[pop_40to44],[pop_45to49],[pop_50to54],[pop_55to59],[pop_60to61],[pop_62to64],[pop_65to69],[pop_70to74],[pop_75to79],[pop_80to84],[pop_85plus]
    ,	CASE
	  WHEN (pop_0to4) > ((hhp + gq_civ + gq_mil) / 2) THEN ROUND(5 * ((hhp + gq_civ + gq_mil) / 2.0) / pop_0to4, 1)
	  WHEN (pop_0to4 + pop_5to9) > ((hhp + gq_civ + gq_mil) / 2) THEN 5 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4) / pop_5to9, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14) > ((hhp + gq_civ + gq_mil) / 2) THEN 10 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9) / pop_10to14, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17) > ((hhp + gq_civ + gq_mil) / 2) THEN 15 + ROUND(3 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14) / pop_15to17, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19) > ((hhp + gq_civ + gq_mil) / 2) THEN 18 + ROUND(2 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17) / pop_18to19, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24) > ((hhp + gq_civ + gq_mil) / 2) THEN 20 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19) / pop_20to24, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24 + pop_25to29) > ((hhp + gq_civ + gq_mil) / 2) THEN 25 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19 - pop_20to24) / pop_25to29, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24 + pop_25to29 + pop_30to34) > ((hhp + gq_civ + gq_mil) / 2) THEN 30 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19 - pop_20to24 - pop_25to29) / pop_30to34, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24 + pop_25to29 + pop_30to34 + pop_35to39) > ((hhp + gq_civ + gq_mil) / 2) THEN 35 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19 - pop_20to24 - pop_25to29 - pop_30to34) / pop_35to39, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24 + pop_25to29 + pop_30to34 + pop_35to39 + pop_40to44) > ((hhp + gq_civ + gq_mil) / 2) THEN 40 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19 - pop_20to24 - pop_25to29 - pop_30to34 - pop_35to39) / pop_40to44, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24 + pop_25to29 + pop_30to34 + pop_35to39 + pop_40to44 + pop_45to49) > ((hhp + gq_civ + gq_mil) / 2) THEN 45 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19 - pop_20to24 - pop_25to29 - pop_30to34 - pop_35to39 - pop_40to44) / pop_45to49, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24 + pop_25to29 + pop_30to34 + pop_35to39 + pop_40to44 + pop_45to49 + pop_50to54) > ((hhp + gq_civ + gq_mil) / 2) THEN 50 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19 - pop_20to24 - pop_25to29 - pop_30to34 - pop_35to39 - pop_40to44 - pop_45to49) / pop_50to54, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24 + pop_25to29 + pop_30to34 + pop_35to39 + pop_40to44 + pop_45to49 + pop_50to54 + pop_55to59) > ((hhp + gq_civ + gq_mil) / 2) THEN 55 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19 - pop_20to24 - pop_25to29 - pop_30to34 - pop_35to39 - pop_40to44 - pop_45to49 - pop_50to54) / pop_55to59, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24 + pop_25to29 + pop_30to34 + pop_35to39 + pop_40to44 + pop_45to49 + pop_50to54 + pop_55to59 + pop_60to61) > ((hhp + gq_civ + gq_mil) / 2) THEN 60 + ROUND(2 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19 - pop_20to24 - pop_25to29 - pop_30to34 - pop_35to39 - pop_40to44 - pop_45to49 - pop_50to54 - pop_55to59) / pop_60to61, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24 + pop_25to29 + pop_30to34 + pop_35to39 + pop_40to44 + pop_45to49 + pop_50to54 + pop_55to59 + pop_60to61 + pop_62to64) > ((hhp + gq_civ + gq_mil) / 2) THEN 62 + ROUND(3 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19 - pop_20to24 - pop_25to29 - pop_30to34 - pop_35to39 - pop_40to44 - pop_45to49 - pop_50to54 - pop_55to59 - pop_60to61) / pop_62to64, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24 + pop_25to29 + pop_30to34 + pop_35to39 + pop_40to44 + pop_45to49 + pop_50to54 + pop_55to59 + pop_60to61 + pop_62to64 + pop_65to69) > ((hhp + gq_civ + gq_mil) / 2) THEN 65 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19 - pop_20to24 - pop_25to29 - pop_30to34 - pop_35to39 - pop_40to44 - pop_45to49 - pop_50to54 - pop_55to59 - pop_60to61 - pop_62to64) / pop_65to69, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24 + pop_25to29 + pop_30to34 + pop_35to39 + pop_40to44 + pop_45to49 + pop_50to54 + pop_55to59 + pop_60to61 + pop_62to64 + pop_65to69 + pop_70to74) > ((hhp + gq_civ + gq_mil) / 2) THEN 70 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19 - pop_20to24 - pop_25to29 - pop_30to34 - pop_35to39 - pop_40to44 - pop_45to49 - pop_50to54 - pop_55to59 - pop_60to61 - pop_62to64 - pop_65to69) / pop_70to74, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24 + pop_25to29 + pop_30to34 + pop_35to39 + pop_40to44 + pop_45to49 + pop_50to54 + pop_55to59 + pop_60to61 + pop_62to64 + pop_65to69 + pop_70to74 + pop_75to79) > ((hhp + gq_civ + gq_mil) / 2) THEN 75 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19 - pop_20to24 - pop_25to29 - pop_30to34 - pop_35to39 - pop_40to44 - pop_45to49 - pop_50to54 - pop_55to59 - pop_60to61 - pop_62to64 - pop_65to69 - pop_70to74) / pop_75to79, 1)
	  WHEN (pop_0to4 + pop_5to9 + pop_10to14 + pop_15to17 + pop_18to19 + pop_20to24 + pop_25to29 + pop_30to34 + pop_35to39 + pop_40to44 + pop_45to49 + pop_50to54 + pop_55to59 + pop_60to61 + pop_62to64 + pop_65to69 + pop_70to74 + pop_75to79 + pop_80to84) > ((hhp + gq_civ + gq_mil) / 2) THEN 80 + ROUND(5 * (((hhp + gq_civ + gq_mil) / 2.0) - pop_0to4 - pop_5to9 - pop_10to14 - pop_15to17 - pop_18to19 - pop_20to24 - pop_25to29 - pop_30to34 - pop_35to39 - pop_40to44 - pop_45to49 - pop_50to54 - pop_55to59 - pop_60to61 - pop_62to64 - pop_65to69 - pop_70to74 - pop_75to79) / pop_80to84, 1)
	END as median_age
  ,[hisp],[nhw],[nhb],[nhi],[nha],[nhh],[nho],[nh2]
  ,[dev_ldsf],[dev_sf],[dev_mf],[dev_mh],[dev_oth],[dev_ag],[dev_indus],[dev_comm],[dev_office],[dev_schools],[dev_roads],[dev_parks],[dev_mil],[dev_water],[dev_mixed_use]
  ,[vac_ldsf],[vac_sf],[vac_mf],[vac_mh],[vac_oth],[vac_ag],[vac_indus],[vac_comm],[vac_office],[vac_schools],[vac_roads],[vac_parks],[vac_mixed_use]
  ,[dev],[vac],[constrained]
FROM
(SELECT
  m.geozone
  ,p.yr
  ,CASE h.short_name
    WHEN 'hh' THEN 'hhp'
	WHEN 'gq_mil' THEN 'gq_mil'
	ELSE 'gq_civ' END as indicator
  ,sum(p.population) as value
FROM
  fact.population p
  JOIN dim.housing_type h ON p.housing_type_id = h.housing_type_id
  JOIN dim.mgra m ON p.mgra_id = m.mgra_id
WHERE
  p.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
GROUP BY
  m.geozone
  ,p.yr
  ,CASE h.short_name
    WHEN 'hh' THEN 'hhp'
	WHEN 'gq_mil' THEN 'gq_mil'
	ELSE 'gq_civ' END
UNION ALL
SELECT
  m.geozone
  ,h.yr
  ,CONCAT('hs_', s.short_name) as indicator
  ,sum(h.units) as value
FROM
  fact.housing h
  JOIN dim.mgra m ON h.mgra_id = m.mgra_id
  JOIN dim.structure_type s ON h.structure_type_id = s.structure_type_id
WHERE
  h.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
GROUP BY
  m.geozone,h.yr,CONCAT('hs_', s.short_name)
UNION ALL
SELECT
  m.geozone
  ,h.yr
  ,CONCAT('hh_', s.short_name) as indicator
  ,sum(h.occupied) as value
FROM
  fact.housing h
  JOIN dim.mgra m ON h.mgra_id = m.mgra_id
  JOIN dim.structure_type s ON h.structure_type_id = s.structure_type_id
WHERE
  h.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
GROUP BY
  m.geozone,h.yr,CONCAT('hh_', s.short_name)
UNION ALL
SELECT
  m.geozone
  ,j.yr
  ,'emp' as indicator
  ,sum(j.jobs) as value
FROM fact.jobs j
JOIN dim.mgra m ON j.mgra_id = m.mgra_id
JOIN dim.employment_type e on j.employment_type_id = e.employment_type_id
WHERE datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
GROUP BY   m.geozone,j.yr
UNION ALL
SELECT
  m.geozone
  ,j.yr
  ,CASE e.civilian
    WHEN 1 THEN 'emp_civ'
	WHEN 0 THEN 'emp_mil'
  END as indicator
  ,sum(j.jobs) as value
FROM fact.jobs j
JOIN dim.mgra m ON j.mgra_id = m.mgra_id
JOIN dim.employment_type e on j.employment_type_id = e.employment_type_id
WHERE datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
GROUP BY   m.geozone,j.yr, CASE e.civilian WHEN 1 THEN 'emp_civ' WHEN 0 THEN 'emp_mil'  END
UNION ALL
SELECT
  m.geozone
  ,i.yr
  ,CASE (i.income_group_id % 10)
  WHEN 0 THEN 'i10'
  ELSE CONCAT('i',(i.income_group_id % 10))
  END as indicator
  ,sum(i.households) as value
FROM 
  fact.household_income i
  JOIN dim.mgra m ON i.mgra_id = m.mgra_id
  WHERE i.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
  GROUP BY m.geozone,i.yr, CASE (i.income_group_id % 10)
  WHEN 0 THEN 'i10'
  ELSE CONCAT('i',(i.income_group_id % 10))
  END
UNION ALL
SELECT
  m.geozone
  ,age.yr
  ,CASE a.lower_bound
    WHEN 85 THEN CONCAT('pop_',a.lower_bound,'plus')
	ELSE CONCAT('pop_',a.lower_bound,'to',a.upper_bound)
  END as indicator
  ,sum(population) as value
FROM
  fact.age age
  JOIN dim.mgra m ON age.mgra_id = m.mgra_id
  JOIN dim.age_group a ON age.age_group_id = a.age_group_id
WHERE
  age.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
GROUP BY
   m.geozone, age.yr, age.age_group_id, CASE a.lower_bound
    WHEN 85 THEN CONCAT('pop_',a.lower_bound,'plus')
	ELSE CONCAT('pop_',a.lower_bound,'to',a.upper_bound)
  END
UNION ALL
SELECT
  m.geozone
  ,ethnic.yr
  ,CASE e.code
    WHEN 'nhai' THEN 'nhi'
	WHEN 'nh2m' THEN 'nh2'
	ELSE e.code
  END as indicator
  ,sum(population) pop
FROM
  fact.ethnicity ethnic
  JOIN dim.mgra m ON ethnic.mgra_id = m.mgra_id
  JOIN dim.ethnicity e on ethnic.ethnicity_id = e.ethnicity_id
WHERE
  ethnic.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
GROUP BY
   m.geozone, ethnic.yr, ethnic.ethnicity_id, e.short_name,CASE e.code
    WHEN 'nhai' THEN 'nhi'
	WHEN 'nh2m' THEN 'nh2'
	ELSE e.code
  END
UNION ALL
SELECT
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

  m.geozone,lu.yr,CONCAT(dt.development_type, '_', lut.short_name)
UNION ALL  
SELECT
     m.geozone
	 ,lu.yr
	 ,dt.development_type as indicator
	 ,sum(lu.acres) as value
   FROM
     fact.land_use lu
	 JOIN dim.mgra m ON lu.mgra_id = m.mgra_id
	 JOIN dim.land_use_type lut ON lu.land_use_type_id = lut.land_use_type_id
	 JOIN dim.development_type dt ON lu.development_type_id = dt.development_type_id
   WHERE
     lu.datasource_id = @DATASOURCE_ID and m.geotype = @GEOZONE
   GROUP BY
     m.geozone,lu.yr,dt.development_type) pvt
PIVOT
(AVG(value) FOR indicator IN (
  [hhp],[gq_civ],[gq_mil]
  ,[hs_sf],[hs_mf],[hs_mh]
  ,[hh_sf],[hh_mf],[hh_mh]
  ,[emp],[emp_civ],[emp_mil]
  ,[i1],[i2],[i3],[i4],[i5],[i6],[i7],[i8],[i9],[i10]
  ,[pop_0to4],[pop_5to9],[pop_10to14],[pop_15to17],[pop_18to19],[pop_20to24],[pop_25to29],[pop_30to34],[pop_35to39],[pop_40to44],[pop_45to49],[pop_50to54],[pop_55to59],[pop_60to61],[pop_62to64],[pop_65to69],[pop_70to74],[pop_75to79],[pop_80to84],[pop_85plus]
  ,[hisp],[nhw],[nhb],[nhi],[nha],[nhh],[nho],[nh2]
  ,[dev_ldsf],[dev_sf],[dev_mf],[dev_mh],[dev_oth],[dev_ag],[dev_indus],[dev_comm],[dev_office],[dev_schools],[dev_roads],[dev_parks],[dev_mil],[dev_water],[dev_mixed_use]
  ,[vac_ldsf],[vac_sf],[vac_mf],[vac_mh],[vac_oth],[vac_ag],[vac_indus],[vac_comm],[vac_office],[vac_schools],[vac_roads],[vac_parks],[vac_mixed_use]
  ,[dev],[vac],[constrained]
)) p
ORDER BY geozone, yr;
	 /*
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
 ORDER BY    ppop.geozone, ppop.yr*/