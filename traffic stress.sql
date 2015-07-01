------------------------------------------------------
--wipe old values
------------------------------------------------------
UPDATE	generated.road_network
SET			ft_seg_stress=NULL,
				ft_int_stress=NULL,
				tf_seg_stress=NULL,
				tf_int_stress=NULL;


------------------------------------------------------
--apply segment stress using tables
------------------------------------------------------
-- mixed ft direction
UPDATE	generated.road_network
SET			ft_seg_stress=(	SELECT			stress
												FROM				generated.seg_stress_mixed s
												WHERE				generated.road_network.speed_limit <= s.speed
												AND					generated.road_network.adt <= s.adt
												AND					generated.road_network.ft_seg_lanes_thru <= s.lanes
												ORDER BY		s.stress ASC
												LIMIT				1)
WHERE		(COALESCE(ft_seg_lanes_bike_wd_ft,0) < 4 AND COALESCE(ft_seg_lanes_park_wd_ft,0) = 0)
OR			COALESCE(ft_seg_lanes_bike_wd_ft,0) + COALESCE(ft_seg_lanes_park_wd_ft,0) < 12;

-- mixed tf direction
UPDATE	generated.road_network
SET			tf_seg_stress=(	SELECT			stress
												FROM				generated.seg_stress_mixed s
												WHERE				generated.road_network.speed_limit <= s.speed
												AND					generated.road_network.adt <= s.adt
												AND					generated.road_network.tf_seg_lanes_thru <= s.lanes
												ORDER BY		s.stress ASC
												LIMIT				1)
WHERE		(COALESCE(tf_seg_lanes_bike_wd_ft,0) < 4 AND COALESCE(tf_seg_lanes_park_wd_ft,0) = 0)
OR			COALESCE(tf_seg_lanes_bike_wd_ft,0) + COALESCE(tf_seg_lanes_park_wd_ft,0) < 12;

-- bike lane no parking ft direction
UPDATE	generated.road_network
SET			ft_seg_stress=(	SELECT			stress
												FROM				generated.seg_stress_bike_no_park s
												WHERE				generated.road_network.speed_limit <= s.speed
												AND					generated.road_network.ft_seg_lanes_bike_wd_ft <= s.bike_lane_wd_ft
												AND					generated.road_network.ft_seg_lanes_thru <= s.lanes
												ORDER BY		s.stress ASC
												LIMIT				1)
WHERE		ft_seg_lanes_bike_wd_ft >= 4
AND 		COALESCE(ft_seg_lanes_park_wd_ft,0) = 0;

-- bike lane no parking tf direction
UPDATE	generated.road_network
SET			tf_seg_stress=(	SELECT			stress
												FROM				generated.seg_stress_bike_no_park s
												WHERE				generated.road_network.speed_limit <= s.speed
												AND					generated.road_network.tf_seg_lanes_bike_wd_ft <= s.bike_lane_wd_ft
												AND					generated.road_network.tf_seg_lanes_thru <= s.lanes
												ORDER BY		s.stress ASC
												LIMIT				1)
WHERE		tf_seg_lanes_bike_wd_ft >= 4
AND 		COALESCE(tf_seg_lanes_park_wd_ft,0) = 0;

-- parking with or without bike lanes ft direction
UPDATE	generated.road_network
SET			ft_seg_stress=(	SELECT			stress
												FROM				generated.seg_stress_bike_w_park s
												WHERE				generated.road_network.speed_limit <= s.speed
												AND					COALESCE(generated.road_network.ft_seg_lanes_bike_wd_ft,0) + generated.road_network.ft_seg_lanes_park_wd_ft <= s.bike_park_lane_wd_ft
												AND					generated.road_network.ft_seg_lanes_thru <= s.lanes
												ORDER BY		s.stress ASC
												LIMIT				1)
WHERE		COALESCE(ft_seg_lanes_park_wd_ft,0) > 0
AND			ft_seg_lanes_park_wd_ft + COALESCE(ft_seg_lanes_bike_wd_ft,0) >= 12;





-- parking with or without bike lanes tf direction
UPDATE	generated.road_network
SET			tf_seg_stress=(	SELECT			stress
												FROM				generated.seg_stress_bike_w_park s
												WHERE				generated.road_network.speed_limit <= s.speed
												AND					COALESCE(generated.road_network.tf_seg_lanes_bike_wd_ft,0) + generated.road_network.tf_seg_lanes_park_wd_ft <= s.bike_park_lane_wd_ft
												AND					generated.road_network.tf_seg_lanes_thru <= s.lanes
												ORDER BY		s.stress ASC
												LIMIT				1)
WHERE		COALESCE(tf_seg_lanes_park_wd_ft,0) > 0
AND			tf_seg_lanes_park_wd_ft + COALESCE(tf_seg_lanes_bike_wd_ft,0) >= 12;






------------------------------------------------------
--nullify stress on contraflow one-way segments
------------------------------------------------------
UPDATE  generated.road_network
SET     ft_seg_stress = NULL,
        ft_int_stress = NULL,
WHERE   one_way = 'tf';
UPDATE  generated.road_network
SET     tf_seg_stress = NULL,
        tf_int_stress = NULL,
WHERE   one_way = 'ft';













WHERE   flag_urban = 1
AND     speed_mph <= 25
AND     ((travel_lanes = 1 AND one_way = 1) OR (travel_lanes <= 2 AND one_way IS NULL));
UPDATE	road
SET		urb_stress_score = 2
WHERE   flag_urban = 1
AND     urb_stress_score IS NULL
AND     speed_mph = 30
AND     ((travel_lanes = 1 AND one_way = 1) OR (travel_lanes <= 2 AND one_way IS NULL));
UPDATE	road
SET		urb_stress_score = 3
WHERE   flag_urban = 1
AND     urb_stress_score IS NULL
AND     speed_mph <= 25
AND     ((travel_lanes = 2 AND one_way = 1) OR (travel_lanes <= 4 AND one_way IS NULL));
UPDATE  road
SET     urb_stress_score = 1
WHERE   flag_urban = 1
AND     urb_stress_score IS NULL
AND     functional_class = 'Local';
UPDATE  road
SET     urb_stress_score = 4
WHERE   functional_class = 'Ramp'
AND     flag_urban = 1;
UPDATE  road
SET     urb_stress_score = 4
WHERE   flag_urban = 1
AND     urb_stress_score IS NULL;
UPDATE  road
SET     urb_stress_score = NULL
WHERE   flag_urban = 1
AND     speed_mph IS NULL
AND     functional_class NOT IN ('Local','Ramp');



------------------------------------------------------
--bike lanes
------------------------------------------------------












------------------------------------------------------
--rural
------------------------------------------------------
-- NOTE: No adjustment is made for yellow line
--       percentage because of lack of data.
--       Truck traffic was assumed at 10% due
--       to lack of data as directed by the
--       documentation.
------------------------------------------------------
-- up to 22 foot lanes
UPDATE	road
SET		rur_rdwy_rating=CASE	WHEN adt <  1050 THEN 1
								WHEN adt <  1440 THEN 2
								WHEN adt >= 1440 THEN 4
								END
WHERE	flag_urban IS NULL
AND		roadway_width_ft <= 22;

-- 22-24 foot lanes
UPDATE	road
SET		rur_rdwy_rating=CASE	WHEN adt <  1400 THEN 1
								WHEN adt <  1925 THEN 2
								WHEN adt >= 1925 THEN 4
								END
WHERE	flag_urban IS NULL
AND		roadway_width_ft >  22
AND		roadway_width_ft <= 24;

-- 24-26 foot lanes (same as 22-24)
UPDATE	road
SET		rur_rdwy_rating=CASE	WHEN adt <  1400 THEN 1
								WHEN adt <  1925 THEN 2
								WHEN adt >= 1925 THEN 4
								END
WHERE	flag_urban IS NULL
AND		roadway_width_ft >  24
AND		roadway_width_ft <= 26;

-- 26-28 foot lanes
UPDATE	road
SET		rur_rdwy_rating=CASE	WHEN adt <  1715 THEN 1
								WHEN adt <  2360 THEN 2
								WHEN adt >= 2360 THEN 4
								END
WHERE	flag_urban IS NULL
AND		roadway_width_ft >  26
AND		roadway_width_ft <= 28;

-- 28-30 foot lanes
UPDATE	road
SET		rur_rdwy_rating=CASE	WHEN adt <  3435 THEN 1
								WHEN adt <  4720 THEN 2
								WHEN adt >= 4720 THEN 4
								END
WHERE	flag_urban IS NULL
AND		roadway_width_ft >  28
AND		roadway_width_ft <= 30;

-- 30-32 foot lanes
UPDATE	road
SET		rur_rdwy_rating=CASE	WHEN adt <  3450 THEN 1
								WHEN adt <  4740 THEN 2
								WHEN adt <  6035 THEN 3
								WHEN adt >= 6035 THEN 4
								END
WHERE	flag_urban IS NULL
AND		roadway_width_ft >  30
AND		roadway_width_ft <= 32;

-- >32 foot lanes
UPDATE	road
SET		rur_rdwy_rating=CASE	WHEN adt <  4035 THEN 1
								WHEN adt <  5545 THEN 2
								WHEN adt <  7325 THEN 3
								WHEN adt >= 7325 THEN 4
								END
WHERE	flag_urban IS NULL
AND		roadway_width_ft >  32;

-- null adt
UPDATE  road
SET     rur_rdwy_rating = 1
WHERE   rur_rdwy_rating IS NULL
AND     flag_urban IS NULL
AND     (adt IS NULL OR speed_mph IS NULL)
AND     functional_class = 'Local';

-- unpaved roads (NOT USED CURRENTLY BECAUSE THERE ARE EFFECTIVELY NO UNPAVED ROADS IN WILL COUNTY)
--UPDATE  road
--SET     rur_rdwy_rating = 4
--WHERE   paved = 0
--AND     flag_urban IS NULL;


------------------------------------------------------
--final score
------------------------------------------------------
-- overrides
UPDATE  road
SET     urb_stress_score=urb_stress_override
WHERE   urb_stress_override IS NOT NULL;
UPDATE  road
SET     rur_rdwy_rating=rur_rdwy_rating_override
WHERE   rur_rdwy_rating_override IS NOT NULL;

UPDATE  road
SET     stress_score = COALESCE(urb_stress_score,rur_rdwy_rating + 1);
