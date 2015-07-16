--network topology needs to be created on road_network first:
--select pgr_createtopology('generated.road_network',5,'geom','id');

------------------------------------------------------
--assign cross street speed limits
------------------------------------------------------
--ft
UPDATE  road_network
SET     ft_cross_speed_limit = (SELECT  MAX(r.speed_limit)
                                FROM    road_network r
                                WHERE   road_network.id != r.id
                                AND     (road_network.target = r.source OR road_network.target = r.target));

--tf
UPDATE  road_network
SET     tf_cross_speed_limit = (SELECT  MAX(r.speed_limit)
                                FROM    road_network r
                                WHERE   road_network.id != r.id
                                AND     (road_network.source = r.source OR road_network.source = r.target));
