--network topology needs to be created on road_network first:
--select pgr_createtopology('generated.road_network',5,'geom','id');

DELETE FROM generated.link_network;

CREATE TEMP TABLE lengths ( id SERIAL PRIMARY KEY,
                            len FLOAT,
                            f_point geometry(point, 26858),
                            t_point geometry(point, 26858))
ON COMMIT DROP;

INSERT INTO lengths (id, len, f_point, t_point)
SELECT  id, 
        ST_Length(geom) AS len,
        ST_LineInterpolatePoint(geom,LEAST(0.5*ST_Length(geom)-5,50.0)/ST_Length(geom)) AS f_point,
        ST_LineInterpolatePoint(geom,GREATEST(0.5*ST_Length(geom)+5,ST_Length(geom)-50)/ST_Length(geom)) AS t_point
FROM    generated.road_network;

--self segment ft
INSERT INTO generated.link_network (    geom,
                                        id_from,
                                        id_to)
SELECT  ST_Makeline(l.f_point,l.t_point),
        r.id,
        r.id
FROM    generated.road_network r,
        lengths l
WHERE   r.id=l.id
AND     (r.one_way IS NULL OR r.one_way = 'ft');

--self segment tf
INSERT INTO generated.link_network (    geom,
                                        id_from,
                                        id_to)
SELECT  ST_Makeline(l.t_point,l.f_point),
        r.id,
        r.id
FROM    generated.road_network r,
        lengths l
WHERE   r.id=l.id
AND     (r.one_way IS NULL OR r.one_way = 'tf');

--from end to start
INSERT INTO generated.link_network (    geom,
                                        id_from,
                                        id_to)
SELECT  ST_Makeline(fl.t_point,tl.f_point),
        f.id,
        t.id
FROM    generated.road_network f,
        generated.road_network t,
        lengths fl,
        lengths tl
WHERE   f.id != t.id 
AND     f.target = t.source
AND     f.id = fl.id
AND     t.id = tl.id
AND     (f.one_way IS NULL OR f.one_way = 'ft')
AND     (t.one_way IS NULL OR t.one_way = 'ft');

--from end to end
INSERT INTO generated.link_network (    geom,
                                        id_from,
                                        id_to)
SELECT  ST_Makeline(fl.t_point,tl.t_point),
        f.id,
        t.id
FROM    generated.road_network f,
        generated.road_network t,
        lengths fl,
        lengths tl
WHERE   f.id != t.id 
AND     f.target = t.target
AND     f.id = fl.id
AND     t.id = tl.id
AND     (f.one_way IS NULL OR f.one_way = 'ft')
AND     (t.one_way IS NULL OR t.one_way = 'tf');

--from start to end
INSERT INTO generated.link_network (    geom,
                                        id_from,
                                        id_to)
SELECT  ST_Makeline(fl.f_point,tl.t_point),
        f.id,
        t.id
FROM    generated.road_network f,
        generated.road_network t,
        lengths fl,
        lengths tl
WHERE   f.id != t.id 
AND     f.source = t.target
AND     f.id = fl.id
AND     t.id = tl.id
AND     (f.one_way IS NULL OR f.one_way = 'tf')
AND     (t.one_way IS NULL OR t.one_way = 'tf');

--from start to start
INSERT INTO generated.link_network (    geom,
                                        id_from,
                                        id_to)
SELECT  ST_Makeline(fl.f_point,tl.f_point),
        f.id,
        t.id
FROM    generated.road_network f,
        generated.road_network t,
        lengths fl,
        lengths tl
WHERE   f.id != t.id 
AND     f.source = t.source
AND     f.id = fl.id
AND     t.id = tl.id
AND     (f.one_way IS NULL OR f.one_way = 'tf')
AND     (t.one_way IS NULL OR t.one_way = 'ft');
