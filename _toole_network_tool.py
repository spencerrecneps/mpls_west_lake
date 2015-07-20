from qgis.core import *
#from PyQt4.QtCore import *
#from processing.tools.vector import VectorWriter
import networkx as nx

# #get QGIS objects
# grid = processing.getObject(Grid_layer)
# network = processing.getObjectFromUri(Network_table)
# roads = processing.getObjectFromUri(Road_layer)
#

def buildGraph(network_table):
    #create graph
    DG=nx.DiGraph()

    #iterate features and add edges
    feats = processing.features(network_table)
    n = len(feats)
    for i, feat in enumerate(feats):
        DG.add_edge(feat['id_from'],feat['id_to'],weight=feat['cost'],stress=feat['stress'])
        progress.setPercentage(int(100 * i / n))

    return DG

def shortestPathStress(graph,source,target,stress=None):
    if stress is None:      #get shortest path without stress
        return nx.shortest_path(graph,source=source,target=target,weight='weight')
    else:
        SG = nx.DiGraph( [ (u,v,d) for u,v,d in graph.edges(data=True) if d['stress'] <= stress ] )
        return nx.shortest_path(SG,source=source,target=target,weight='weight')
