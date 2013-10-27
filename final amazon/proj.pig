SET DEFALT_PARALLEL 12;
---getting the stations 
stat = load 's3://cs440-climate/ish-history.csv' as (row:chararray);
stat_par = FOREACH stat GENERATE
  FLATTEN(
	(tuple(int,int, chararray,chararray,chararray,chararray))   
	REGEX_EXTRACT_ALL( 
      row, '^"(\\d+)","(\\d+)","(.*?)","(US)","(.*?)","(.*?)".*$')
  )
  AS (
    USAF:           int,
    WBAN:           int,
    STATION_NAME:   chararray,
    CTRY:           chararray,
    FIPS:           chararray,
    STATE:          chararray
);
stat_us = filter stat_par by STATE is not null;
stat_not_usaf = filter stat_us by not USAF == 999999;
stat_not_wban = filter stat_not_usaf by not WBAN == 99999;



--- getting weather data

gsod = LOAD 's3://cs440-climate/gsod/' USING TextLoader as (line:chararray);
no_head = filter gsod by SIZE(line) > 108L;
wd = foreach no_head generate
	(int)TRIM(SUBSTRING(line,0,6))		AS STN,
	--(int)TRIM(SUBSTRING(line,7,13))	AS WBAN,
	(int)TRIM(SUBSTRING(line,14,18))	AS YEAR,
	(int)TRIM(SUBSTRING(line,18,20))	AS MONTH,
	(float)TRIM(SUBSTRING(line,26,30))	AS TEMP;

wd_Group = group wd by STN..MONTH;
wd_Avg= foreach wd_Group {
	temp_t = wd.TEMP;
	generate flatten(group), AVG(temp_t) as avg_Temp;
	};
wd_Filter = filter wd_Avg by avg_Temp is not null;


--- joining stations with weather data

join_data = join wd_Filter by STN, stat_not_wban by USAF; 

grouping = group join_data by (YEAR,MONTH,STATE);
join_Avg= foreach grouping {
	temp_t = join_data.avg_Temp;
	generate flatten(group), AVG(temp_t) as join_avg_Temp;
	};

store join_Avg into 's3://usypolt/mgsod';
