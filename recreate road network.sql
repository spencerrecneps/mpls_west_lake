ALTER TABLE road_network SET SCHEMA scratch;
ALTER TABLE turn_restrictions SET SCHEMA scratch;

CREATE TABLE road_network ( id serial NOT NULL,
                            geom geometry(LineString,26858),
                            road_name text,
                            source_data text,
                            source_ids text,
                            functional_class text,
                            one_way character varying(2),
                            speed_limit integer,
                            adt integer,
                            ft_seg_lanes_thru integer,
                            ft_seg_lanes_bike_wd_ft integer,
                            ft_seg_lanes_park_wd_ft integer,
                            ft_seg_stress_override integer,
                            ft_seg_stress integer,
                            ft_int_lanes_thru integer,
                            ft_int_lanes_lt integer,
                            ft_int_lanes_rt_len_ft integer,
                            ft_int_lanes_rt_radius_speed_mph integer,
                            ft_int_lanes_bike_wd_ft integer,
                            ft_int_lanes_bike_straight integer,
                            ft_int_stress_override integer,
                            ft_int_stress integer,
                            ft_cross_median_wd_ft integer,
                            ft_cross_signal integer,
                            ft_cross_speed_limit integer,
                            ft_cross_lanes integer,
                            ft_cross_stress_override integer,
                            ft_cross_stress integer,
                            tf_seg_lanes_thru integer,
                            tf_seg_lanes_bike_wd_ft integer,
                            tf_seg_lanes_park_wd_ft integer,
                            tf_seg_stress_override integer,
                            tf_seg_stress integer,
                            tf_int_lanes_thru integer,
                            tf_int_lanes_lt integer,
                            tf_int_lanes_rt_len_ft integer,
                            tf_int_lanes_rt_radius_speed_mph integer,
                            tf_int_lanes_bike_wd_ft integer,
                            tf_int_lanes_bike_straight integer,
                            tf_int_stress_override integer,
                            tf_int_stress integer,
                            tf_cross_median_wd_ft integer,
                            tf_cross_signal integer,
                            tf_cross_speed_limit integer,
                            tf_cross_lanes integer,
                            tf_cross_stress_override integer,
                            tf_cross_stress integer,
                            source integer,
                            target integer,
                            cost integer,
                            reverse_cost integer,
                            CONSTRAINT road_network_pkey PRIMARY KEY (id));

CREATE INDEX road_network_source_idx
  ON road_network
  USING btree
  (source);

CREATE INDEX road_network_target_idx
  ON road_network
  USING btree
  (target);

CREATE INDEX sidx_road_network_geom
  ON road_network
  USING gist
  (geom);



CREATE TABLE turn_restrictions
(
  from_id integer NOT NULL,
  to_id integer NOT NULL,
  CONSTRAINT turn_restrictions_from_id_fkey FOREIGN KEY (from_id)
        REFERENCES generated.road_network (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT turn_restrictions_to_id_fkey FOREIGN KEY (to_id)
        REFERENCES generated.road_network (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT turn_restrictions_check CHECK (from_id <> to_id)
);

CREATE INDEX idx_turnrestrictions
  ON turn_restrictions
  USING btree
  (from_id, to_id);



-- INSERT INTO road_network (  id, geom, road_name, source_data, source_ids, functional_class,
--                             one_way, speed_limit, adt, ft_seg_lanes_thru, ft_seg_lanes_bike_wd_ft,
--                             ft_seg_lanes_park_wd_ft, ft_seg_stress_override, ft_seg_stress,
--                             ft_int_lanes_thru, ft_int_lanes_rt_len_ft, ft_int_lanes_rt_radius_speed_mph,
--                             ft_int_lanes_bike_wd_ft, ft_int_lanes_bike_straight, ft_int_stress_override,
--                             ft_int_stress, ft_cross_median_wd_ft, ft_cross_signal, ft_cross_speed_limit,
--                             ft_cross_lanes, ft_cross_stress_override, ft_cross_stress, tf_seg_lanes_thru,
--                             tf_seg_lanes_bike_wd_ft, tf_seg_lanes_park_wd_ft, tf_seg_stress_override,
--                             tf_seg_stress, tf_int_lanes_thru, tf_int_lanes_rt_len_ft, tf_int_lanes_rt_radius_speed_mph,
--                             tf_int_lanes_bike_wd_ft, tf_int_lanes_bike_straight, tf_int_stress_override,
--                             tf_int_stress, tf_cross_median_wd_ft, tf_cross_signal, tf_cross_speed_limit,
--                             tf_cross_lanes, tf_cross_stress_override, tf_cross_stress, source,
--                             target, cost, reverse_cost)
-- SELECT                      id, geom, road_name, source_data, source_ids, functional_class,
--                             one_way, speed_limit, adt, ft_seg_lanes_thru, ft_seg_lanes_bike_wd_ft,
--                             ft_seg_lanes_park_wd_ft, ft_seg_stress_override, ft_seg_stress,
--                             ft_int_lanes_thru, ft_int_lanes_rt_len_ft, ft_int_lanes_rt_radius_speed_mph,
--                             ft_int_lanes_bike_wd_ft, ft_int_lanes_bike_straight, ft_int_stress_override,
--                             ft_int_stress, ft_cross_median_wd_ft, ft_cross_signal, ft_cross_speed_limit,
--                             ft_cross_lanes, ft_cross_stress_override, ft_cross_stress, tf_seg_lanes_thru,
--                             tf_seg_lanes_bike_wd_ft, tf_seg_lanes_park_wd_ft, tf_seg_stress_override,
--                             tf_seg_stress, tf_int_lanes_thru, tf_int_lanes_rt_len_ft, tf_int_lanes_rt_radius_speed_mph,
--                             tf_int_lanes_bike_wd_ft, tf_int_lanes_bike_straight, tf_int_stress_override,
--                             tf_int_stress, tf_cross_median_wd_ft, tf_cross_signal, tf_cross_speed_limit,
--                             tf_cross_lanes, tf_cross_stress_override, tf_cross_stress, source,
--                             target, cost, reverse_cost
-- FROM                        scratch.road_network;

INSERT INTO turn_restrictions (from_id, to_id)
SELECT from_id, to_id FROM scratch.turn_restrictions;

SELECT setval('generated.road_network_id_seq', 1427, true);

ANALYZE road_network;
ANALYZE turn_restrictions;
