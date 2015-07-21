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
        GREATEST(sf.stress,st.stress,link_network.stress)::int,
        sf.cost::int
FROM    link_network,
        selfs sf,
        selfs st
WHERE   id_from != id_to
AND     link_network.id_from = sf.id
AND     link_network.id_to = st.id;
