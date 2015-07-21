#Definition of inputs and outputs
#==================================
##Toole=group
##Grid connectivity score=name
##Grid_layer=vector
##Road_ID_field=field Grid_layer
##Network_table=table
##Maximum_stress=number 2
##Output_grid=output vector

#Algorithm body
#==================================
from qgis.core import *
from PyQt4.QtCore import *
import sys
from processing.tools.vector import VectorWriter
from processing.core.GeoAlgorithmExecutionException import GeoAlgorithmExecutionException
import networkx as nx

#get QGIS objects
grid = processing.getObject(Grid_layer)
network = processing.getObjectFromUri(Network_table)

#create graph
DG=nx.DiGraph()

#iterate features and add edges
progress.setText('Building unconstrained network')
feats = processing.features(network)
n = len(feats)
for i, feat in enumerate(feats):
    DG.add_edge(feat['id_from'],feat['id_to'],weight=feat['cost'],stress=feat['stress'])
    progress.setPercentage(int(100 * i / n))
graphCosts = nx.get_edge_attributes(DG,'weight')

#create subgraph using stress tolerance
progress.setText('Building stress-constrained network')
SG = nx.DiGraph( [ (u,v,d) for u,v,d in DG.edges(data=True) if d['stress'] <= Maximum_stress ] )

#get grid feature and  road id
progress.setText('Reading selected feature(s)')
selectedGridFeatures = processing.features(grid)
if not len(selectedGridFeatures) == 1:
    raise GeoAlgorithmExecutionException('You must select one and only one feature in the grid layer')
gridFeature = QgsFeature()
for i, f in enumerate(selectedGridFeatures):
    gridFeature = f
sourceRoadId = gridFeature.attribute(Road_ID_field)

#test for source feature not having any low stress connections
if not SG.has_node(sourceRoadId):
    raise GeoAlgorithmExecutionException('The selected grid cell has no low stress connections')

#helper function to sum costs from graph
def sumCosts(nodes,graphWeights):
    cost = 0
    for j, node in enumerate(nodes):
            try:
                cost = cost + graphCosts[(node,nodes[j+1])]
            except:
                pass
    return cost

#iterate grid features and compile scores
progress.setText('Generating grid scores')
gridProvider = grid.dataProvider()
writer = VectorWriter(Output_grid, None, [QgsField("road_id", QVariant.Int),QgsField("cost_uncon", QVariant.Int),QgsField("cost_const", QVariant.Int),QgsField("conn_score", QVariant.Double)], gridProvider.geometryType(), gridProvider.crs() )
gridFeatures = grid.getFeatures()
for i, gf in enumerate(gridFeatures):
    targetRoadId = gf.attribute(Road_ID_field)
    progress.setInfo('from: ' + str(sourceRoadId) + ' to: ' + str(targetRoadId))

    if (not targetRoadId == sourceRoadId and SG.has_node(targetRoadId)):
        if nx.has_path(SG,source=sourceRoadId,target=targetRoadId):
            #get shortest path without stress
            pathNoStress = nx.shortest_path(DG,source=sourceRoadId,target=targetRoadId,weight='weight')
            #get shortest path with stress
            pathStress = nx.shortest_path(SG,source=sourceRoadId,target=targetRoadId,weight='weight')
            #get cost values
            costNoStress = sumCosts(pathNoStress,graphCosts)
            costStress = sumCosts(pathStress,graphCosts)

            #write new feature
            progress.setText('Writing grid feature')
            newFeat = QgsFeature()
            newFeat.setGeometry(gf.geometry())
            newFeat.initAttributes(4)
            newFeat.setAttribute(0,gf.attribute(Road_ID_field))
            newFeat.setAttribute(1,costNoStress)
            newFeat.setAttribute(2,costStress)
            newFeat.setAttribute(3,float(costStress)/float(costNoStress))
            writer.addFeature(newFeat)

del writer
