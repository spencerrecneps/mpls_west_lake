#Definition of inputs and outputs
#==================================
##Toole=group
##Connectivity score=name
##Grid_layer=vector
##From_ID=number 375
##To_ID=number 999
##Road_id=field Grid_layer
##Network_table=table
##Maximum_stress=number 2
##Road_layer=vector
##Output_paths=output vector

#Algorithm body
#==================================
from qgis.core import *
from PyQt4.QtCore import *
from processing.tools.vector import VectorWriter
import networkx as nx

#get QGIS objects
grid = processing.getObject(Grid_layer)
network = processing.getObjectFromUri(Network_table)
roads = processing.getObjectFromUri(Road_layer)

#create graph
DG=nx.DiGraph()

#iterate features and add edges
progress.setText('Building unconstrained network')
feats = processing.features(network)
n = len(feats)
for i, feat in enumerate(feats):
    DG.add_edge(feat['id_from'],feat['id_to'],weight=feat['cost'],stress=feat['stress'])
    progress.setPercentage(int(100 * i / n))

#get shortest path without stress
progress.setText('Getting shortest path without stress')
pathNoStress = nx.shortest_path(DG,source=From_ID,target=To_ID,weight='weight')
progress.setInfo('Shortest unconstrained path: ' + str(pathNoStress))

#create subgraph using stress tolerance
progress.setText('Building stress-constrained network')
SG = nx.DiGraph( [ (u,v,d) for u,v,d in DG.edges(data=True) if d['stress'] <= Maximum_stress ] )

#get shortest path with stress
progress.setText('Getting shortest path with stress')
pathStress = nx.shortest_path(SG,source=From_ID,target=To_ID,weight='weight')
progress.setInfo('Shortest constrained path: ' + str(pathStress))

#write shortest paths to new vector layer
provider = roads.dataProvider()
writer = VectorWriter(Output_paths, None, [QgsField("road_id", QVariant.Int),QgsField("cost", QVariant.Int),QgsField("path_type", QVariant.String)], provider.geometryType(), provider.crs() )
for feat in processing.features(roads):
    if feat.attribute('id') in pathNoStress:
        newFeat = QgsFeature()
        newFeat.setGeometry(feat.geometry())
        newFeat.initAttributes(3)
        newFeat.setAttribute(0,feat.attribute('id'))
        newFeat.setAttribute(1,feat.attribute('cost'))
        newFeat.setAttribute(2,'Unconstrained')
        writer.addFeature( newFeat )
    if feat.attribute('id') in pathStress:
        newFeat = QgsFeature()
        newFeat.setGeometry(feat.geometry())
        newFeat.initAttributes(3)
        newFeat.setAttribute(0,feat.attribute('id'))
        newFeat.setAttribute(1,feat.attribute('cost'))
        newFeat.setAttribute(2,'Constrained')
        writer.addFeature( newFeat )
