------------------------------------------------------
--wipe old values
------------------------------------------------------
UPDATE  generated.road_network
SET     ft_seg_stress=NULL,
        ft_int_stress=NULL,
        ft_cross_stress=NULL,
        tf_seg_stress=NULL,
        tf_int_stress=NULL,
        tf_cross_stress=NULL;


------------------------------------------------------
--apply segment stress using tables
------------------------------------------------------
-- mixed ft direction
UPDATE  generated.road_network
SET     ft_seg_stress=( SELECT      stress
                        FROM        generated.stress_seg_mixed s
                        WHERE       generated.road_network.speed_limit <= s.speed
                        AND         generated.road_network.adt <= s.adt
                        AND         generated.road_network.ft_seg_lanes_thru <= s.lanes
                        ORDER BY    s.stress ASC
                        LIMIT       1)
WHERE   (COALESCE(ft_seg_lanes_bike_wd_ft,0) < 4 AND COALESCE(ft_seg_lanes_park_wd_ft,0) = 0)
OR      COALESCE(ft_seg_lanes_bike_wd_ft,0) + COALESCE(ft_seg_lanes_park_wd_ft,0) < 12;

-- mixed tf direction
UPDATE  generated.road_network
SET     tf_seg_stress=( SELECT      stress
                        FROM        generated.stress_seg_mixed s
                        WHERE       generated.road_network.speed_limit <= s.speed
                        AND         generated.road_network.adt <= s.adt
                        AND         generated.road_network.tf_seg_lanes_thru <= s.lanes
                        ORDER BY    s.stress ASC
                        LIMIT       1)
WHERE   (COALESCE(tf_seg_lanes_bike_wd_ft,0) < 4 AND COALESCE(tf_seg_lanes_park_wd_ft,0) = 0)
OR      COALESCE(tf_seg_lanes_bike_wd_ft,0) + COALESCE(tf_seg_lanes_park_wd_ft,0) < 12;

-- bike lane no parking ft direction
UPDATE  generated.road_network
SET     ft_seg_stress=( SELECT      stress
                        FROM        generated.stress_seg_bike_no_park s
                        WHERE       generated.road_network.speed_limit <= s.speed
                        AND         generated.road_network.ft_seg_lanes_bike_wd_ft <= s.bike_lane_wd_ft
                        AND         generated.road_network.ft_seg_lanes_thru <= s.lanes
                        ORDER BY    s.stress ASC
                        LIMIT       1)
WHERE   ft_seg_lanes_bike_wd_ft >= 4
AND     COALESCE(ft_seg_lanes_park_wd_ft,0) = 0;

-- bike lane no parking tf direction
UPDATE  generated.road_network
SET     tf_seg_stress=( SELECT      stress
                        FROM        generated.stress_seg_bike_no_park s
                        WHERE       generated.road_network.speed_limit <= s.speed
                        AND         generated.road_network.tf_seg_lanes_bike_wd_ft <= s.bike_lane_wd_ft
                        AND         generated.road_network.tf_seg_lanes_thru <= s.lanes
                        ORDER BY    s.stress ASC
                        LIMIT       1)
WHERE   tf_seg_lanes_bike_wd_ft >= 4
AND     COALESCE(tf_seg_lanes_park_wd_ft,0) = 0;

-- parking with or without bike lanes ft direction
UPDATE  generated.road_network
SET     ft_seg_stress=( SELECT      stress
                        FROM        generated.stress_seg_bike_w_park s
                        WHERE       generated.road_network.speed_limit <= s.speed
                        AND         COALESCE(generated.road_network.ft_seg_lanes_bike_wd_ft,0) + generated.road_network.ft_seg_lanes_park_wd_ft <= s.bike_park_lane_wd_ft
                        AND         generated.road_network.ft_seg_lanes_thru <= s.lanes
                        ORDER BY    s.stress ASC
                        LIMIT       1)
WHERE   COALESCE(ft_seg_lanes_park_wd_ft,0) > 0
AND     ft_seg_lanes_park_wd_ft + COALESCE(ft_seg_lanes_bike_wd_ft,0) >= 12;

-- parking with or without bike lanes tf direction
UPDATE  generated.road_network
SET     tf_seg_stress=( SELECT      stress
                        FROM        generated.stress_seg_bike_w_park s
                        WHERE       generated.road_network.speed_limit <= s.speed
                        AND         COALESCE(generated.road_network.tf_seg_lanes_bike_wd_ft,0) + generated.road_network.tf_seg_lanes_park_wd_ft <= s.bike_park_lane_wd_ft
                        AND         generated.road_network.tf_seg_lanes_thru <= s.lanes
                        ORDER BY    s.stress ASC
                        LIMIT       1)
WHERE   COALESCE(tf_seg_lanes_park_wd_ft,0) > 0
AND     tf_seg_lanes_park_wd_ft + COALESCE(tf_seg_lanes_bike_wd_ft,0) >= 12;

--overrides
UPDATE  generated.road_network
SET     ft_seg_stress = ft_seg_stress_override
WHERE   ft_seg_stress_override IS NOT NULL;
UPDATE  generated.road_network
SET     tf_seg_stress = tf_seg_stress_override
WHERE   tf_seg_stress_override IS NOT NULL;

------------------------------------------------------
--apply intersection stress
------------------------------------------------------

-- shared right turn lanes ft direction
UPDATE  generated.road_network
SET     ft_int_stress = 3
WHERE   COALESCE(ft_int_lanes_bike_wd_ft,0) < 4
AND     ft_int_lanes_rt_len_ft >= 75
AND     ft_int_lanes_rt_len_ft < 150;
UPDATE  generated.road_network
SET     ft_int_stress = 4
WHERE   COALESCE(ft_int_lanes_bike_wd_ft,0) < 4
AND     ft_int_lanes_rt_len_ft >= 150;

-- shared right turn lanes tf direction
UPDATE  generated.road_network
SET     tf_int_stress = 3
WHERE   COALESCE(tf_int_lanes_bike_wd_ft,0) < 4
AND     tf_int_lanes_rt_len_ft >= 75
AND     tf_int_lanes_rt_len_ft < 150;
UPDATE  generated.road_network
SET     tf_int_stress = 4
WHERE   COALESCE(tf_int_lanes_bike_wd_ft,0) < 4
AND     tf_int_lanes_rt_len_ft >= 150;

-- pocket bike lane w/right turn lanes ft direction
UPDATE  generated.road_network
SET     ft_int_stress = 2
WHERE   COALESCE(ft_int_lanes_bike_wd_ft,0) >= 4
AND     ft_int_lanes_rt_len_ft <= 150
AND     ft_int_lanes_rt_radius_speed_mph <= 15
AND     ft_int_lanes_bike_straight = 1;
UPDATE  generated.road_network
SET     ft_int_stress = 3
WHERE   COALESCE(ft_int_lanes_bike_wd_ft,0) >= 4
AND     COALESCE(ft_int_lanes_rt_len_ft,0) > 0
AND     ft_int_lanes_rt_radius_speed_mph <= 20
AND     ft_int_lanes_bike_straight = 1
AND     ft_int_stress IS NOT NULL;
UPDATE  generated.road_network
SET     ft_int_stress = 3
WHERE   COALESCE(ft_int_lanes_bike_wd_ft,0) >= 4
AND     ft_int_lanes_rt_radius_speed_mph <= 15
AND     COALESCE(ft_int_lanes_bike_straight,0) = 0;
UPDATE  generated.road_network
SET     ft_int_stress = 4
WHERE   COALESCE(ft_int_lanes_bike_wd_ft,0) >= 4
AND     ft_int_stress IS NULL;

-- pocket bike lane w/right turn lanes tf direction
UPDATE  generated.road_network
SET     tf_int_stress = 2
WHERE   COALESCE(tf_int_lanes_bike_wd_ft,0) >= 4
AND     tf_int_lanes_rt_len_ft <= 150
AND     tf_int_lanes_rt_radius_speed_mph <= 15
AND     tf_int_lanes_bike_straight = 1;
UPDATE  generated.road_network
SET     tf_int_stress = 3
WHERE   COALESCE(tf_int_lanes_bike_wd_ft,0) >= 4
AND     COALESCE(tf_int_lanes_rt_len_ft,0) > 0
AND     tf_int_lanes_rt_radius_speed_mph <= 20
AND     tf_int_lanes_bike_straight = 1
AND     tf_int_stress IS NOT NULL;
UPDATE  generated.road_network
SET     tf_int_stress = 3
WHERE   COALESCE(tf_int_lanes_bike_wd_ft,0) >= 4
AND     tf_int_lanes_rt_radius_speed_mph <= 15
AND     COALESCE(tf_int_lanes_bike_straight,0) = 0;
UPDATE  generated.road_network
SET     tf_int_stress = 4
WHERE   COALESCE(tf_int_lanes_bike_wd_ft,0) >= 4
AND     tf_int_stress IS NULL;

--overrides
UPDATE  generated.road_network
SET     ft_int_stress = ft_int_stress_override
WHERE   ft_int_stress_override IS NOT NULL;
UPDATE  generated.road_network
SET     tf_int_stress = tf_int_stress_override
WHERE   tf_int_stress_override IS NOT NULL;

------------------------------------------------------
--apply crossing stress
------------------------------------------------------
--no median (or less than 6 ft), ft
UPDATE  generated.road_network
SET     ft_cross_stress = ( SELECT      s.stress
                            FROM        generated.stress_cross_no_median s
                            WHERE       generated.road_network.ft_cross_speed_limit <= s.speed
                            AND         generated.road_network.ft_cross_lanes <= s.lanes
                            ORDER BY    s.stress ASC
                            LIMIT       1)
WHERE   COALESCE(ft_cross_median_wd_ft,0) < 6;

--no median (or less than 6 ft), tf
UPDATE  generated.road_network
SET     tf_cross_stress = ( SELECT      s.stress
                            FROM        generated.stress_cross_no_median s
                            WHERE       generated.road_network.tf_cross_speed_limit <= s.speed
                            AND         generated.road_network.tf_cross_lanes <= s.lanes
                            ORDER BY    s.stress ASC
                            LIMIT       1)
WHERE   COALESCE(tf_cross_median_wd_ft,0) < 6;

--with median at least 6 ft, ft
UPDATE  generated.road_network
SET     ft_cross_stress = ( SELECT      s.stress
                            FROM        generated.stress_cross_w_median s
                            WHERE       generated.road_network.ft_cross_speed_limit <= s.speed
                            AND         generated.road_network.ft_cross_lanes <= s.lanes
                            ORDER BY    s.stress ASC
                            LIMIT       1)
WHERE   COALESCE(ft_cross_median_wd_ft,0) >= 6;

--with median at least 6 ft, tf
UPDATE  generated.road_network
SET     tf_cross_stress = ( SELECT      s.stress
                            FROM        generated.stress_cross_w_median s
                            WHERE       generated.road_network.tf_cross_speed_limit <= s.speed
                            AND         generated.road_network.tf_cross_lanes <= s.lanes
                            ORDER BY    s.stress ASC
                            LIMIT       1)
WHERE   COALESCE(tf_cross_median_wd_ft,0) >= 6;

--traffic signals ft
UPDATE  generated.road_network
SET     ft_cross_stress = 1
WHERE   ft_cross_signal = 1;

--traffic signals tf
UPDATE  generated.road_network
SET     tf_cross_stress = 1
WHERE   tf_cross_signal = 1;

--overrides
UPDATE  generated.road_network
SET     tf_cross_stress = tf_cross_stress_override
WHERE   tf_cross_stress_override IS NOT NULL;
UPDATE  generated.road_network
SET     ft_cross_stress = ft_cross_stress_override
WHERE   ft_cross_stress_override IS NOT NULL;


------------------------------------------------------
--nullify stress on contraflow one-way segments
------------------------------------------------------
UPDATE  generated.road_network
SET     ft_seg_stress = NULL,
        ft_int_stress = NULL,
        ft_cross_stress = NULL
WHERE   one_way = 'tf';
UPDATE  generated.road_network
SET     tf_seg_stress = NULL,
        tf_int_stress = NULL,
        tf_cross_stress = NULL
WHERE   one_way = 'ft';
