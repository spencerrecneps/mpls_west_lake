UPDATE      hex_grid
SET         nearest_road_id = ( SELECT      id
                                FROM        road_network
                                WHERE       hex_grid.geom <#> road_network.geom < 50
                                ORDER BY    ST_Distance(hex_grid.geom,road_network.geom) ASC,
                                            ST_Distance(ST_Centroid(hex_grid.geom),road_network.geom) ASC
                                LIMIT       1);
