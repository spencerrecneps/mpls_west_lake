UPDATE      hex_grid
SET         nearest_road_id = ( SELECT      id
                                FROM        road_network
                                WHERE       hex_grid.geom <#> road_network.geom < 50
                                AND         NOT road_network.id IN (988,985,198,984,983,982,981,980,979,528) --exclude portions of cedar lake/dean pkwy with side path
                                ORDER BY    ST_Distance(hex_grid.geom,road_network.geom) ASC,
                                            ST_Distance(ST_Centroid(hex_grid.geom),road_network.geom) ASC
                                LIMIT       1);
