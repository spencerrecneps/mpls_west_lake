--MUST BE RUN AS SUPERUSER
--requires running CREATE LANGUAGE plpythonu if it hasn't already been done

---------------------------------
-- Returns the shortest path subject to the given stress level
---------------------------------



CREATE OR REPLACE FUNCTION pyshortest_path (road_id_f int, road_id_t int, max_stress int)
RETURNS INT
AS $$

#need to figure out path issues
if 'nx' in SD:
    nx = SD['nx']
else:
    from sys import path
    path.append( '/home/spencer/.local/lib/python2.7/site-packages' )
    import networkx as nx
    SD['nx'] = nx

cost = 0

DG=nx.DiGraph()
DG.add_weighted_edges_from([(1,2,3.0), (3,1,7.5)])
if nx.has_path(DG,2,3):
  for w in nx.shortest_path(DG,2,3,'weight'):
    cost = cost + DG[w]['weight']
else:
  cost = -9999

return cost

$$ LANGUAGE plpythonu;
