DELETE FROM networkx;

WITH selfs AS ( SELECT  id_from AS id,
                MAX(cost) AS cost,
                MAX(stress) AS stress
                FROM link_network
                WHERE id_from=id_to
                GROUP BY id_from)
INSERT INTO networkx (id_from,id_to,stress,cost)
SELECT  id_from::int,
        id_to::int,
        GREATEST(selfs.stress,link_network.stress)::int,
        selfs.cost::int
FROM    link_network,
        selfs
WHERE   id_from != id_to
AND     link_network.id_from = selfs.id;
