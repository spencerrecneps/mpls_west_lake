WITH selfs AS ( SELECT  id_from AS id,
                MAX(cost) AS cost
                FROM link_network
                WHERE id_from=id_to
                GROUP BY id_from)

SELECT  'DG.add_edge(' || id_from || ',' || id_to || ',weight=' || selfs.cost || ')'
FROM    link_network,
        selfs
WHERE   id_from != id_to
AND     link_network.id_from = selfs.id;
