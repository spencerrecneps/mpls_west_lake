#Definition of inputs and outputs
#==================================
##Toole=group
##Connect destinations=name
##Road_layer=vector
##Destinations_layer=vector
##Network_table=table
##Maximum_stress=number 2
##Output_paths=output vector

#Algorithm body
#==================================
from qgis.core import *
from PyQt4.QtCore import *
from processing.tools.vector import VectorWriter
import networkx as nx

#get QGIS objects
network = processing.getObjectFromUri(Network_table)
roads = processing.getObjectFromUri(Road_layer)
destinations = processing.getObjectFromUri(Destinations_layer)

#create graph
DG=nx.DiGraph()

#iterate features and add edges
progress.setText('Building unconstrained network')
feats = processing.features(network)
n = len(feats)
for i, feat in enumerate(feats):
    DG.add_edge(feat['id_from'],feat['id_to'],weight=feat['cost'],stress=feat['stress'])
    progress.setPercentage(int(100 * i / n))

#create subgraph using stress tolerance
progress.setText('Building stress-constrained network')
SG = nx.DiGraph( [ (u,v,d) for u,v,d in DG.edges(data=True) if d['stress'] <= Maximum_stress ] )

#set up the roads provider for copying roads
provider = roads.dataProvider()
writer = VectorWriter(Output_paths, None, [QgsField("orig", QVariant.String),QgsField("dest",QVariant.String),QgsField("cost", QVariant.Int),QgsField("path_type", QVariant.String)], provider.geometryType(), provider.crs() )

#iterate destinations to get shortest paths
destFeats = processing.features(destinations)
destIds = []
for i, feat in enumerate(destFeats):
    destIds.append( (feat['road_id_unconstrained'], feat['road_id_constrained'], feat['name']) )
n = len(destIds)
for i, fromId in enumerate(destIds):
    progress.setText('Getting shortest paths for ' + fromId[2])

    for toId in destIds:
        if not fromId == toId:
            #get shortest path without stress constraints
            pathNoStress = nx.shortest_path(DG,source=fromId[0],target=toId[0],weight='weight')
            progress.setInfo('Shortest unconstrained path: ' + str(pathNoStress))

            #get shortest path with stress constraints
            hasPath = False
            if SG.has_node(fromId[1]) and SG.has_node(toId[1]):
                if nx.has_path(SG,source=fromId[1],target=toId[1]):
                    hasPath = True
                    pathStress = nx.shortest_path(SG,source=fromId[1],target=toId[1],weight='weight')
                    progress.setInfo('Shortest constrained path: ' + str(pathStress))

            #iterate roads and write features in the path
            for feat in processing.features(roads):
                if feat.attribute('id') in pathNoStress:
                    newFeat = QgsFeature()
                    newFeat.setGeometry(feat.geometry())
                    newFeat.initAttributes(4)
                    newFeat.setAttribute(0,fromId[2])
                    newFeat.setAttribute(1,toId[2])
                    newFeat.setAttribute(2,feat.attribute('cost'))
                    newFeat.setAttribute(3,'Not constrained')
                    writer.addFeature( newFeat )
                if hasPath:
                    if feat.attribute('id') in pathStress:
                        newFeat = QgsFeature()
                        newFeat.setGeometry(feat.geometry())
                        newFeat.initAttributes(4)
                        newFeat.setAttribute(0,fromId[2])
                        newFeat.setAttribute(1,toId[2])
                        newFeat.setAttribute(2,feat.attribute('cost'))
                        newFeat.setAttribute(3,'Stress constrained')
                        writer.addFeature( newFeat )

    progress.setPercentage(int(100 * i / n))

del writer
