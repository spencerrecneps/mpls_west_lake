UPDATE  ped_network_vertices_pgr
SET     intersection = (SELECT  p.road_name
                        FROM    ped_network p
                        WHERE   ped_network_vertices_pgr.id IN (p.source,p.target)
                        LIMIT   1);

UPDATE  ped_network_vertices_pgr
SET     intersection = intersection || ' / ' || (   SELECT  p.road_name
                                                    FROM    ped_network p
                                                    WHERE   ped_network_vertices_pgr.id IN (p.source,p.target)
                                                    AND     NOT p.road_name = ped_network_vertices_pgr.intersection
                                                    LIMIT   1);

WITH dest AS (  SELECT      v.id,
                            d.name
                FROM        ped_network_vertices_pgr v,
                            destinations d
                WHERE       v.id = (SELECT      pv.id
                                    FROM        ped_network_vertices_pgr pv
                                    ORDER BY    d.geom <-> pv.the_geom ASC
                                    LIMIT 1))
UPDATE  ped_network_vertices_pgr
SET     destination = dest.name
FROM    dest
WHERE   ped_network_vertices_pgr.id = dest.id;
