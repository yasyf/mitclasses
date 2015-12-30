from models.schedule import Schedule
from models.mit_class import MitClass
from sklearn.cluster import MiniBatchKMeans
from sklearn.svm import SVC
from learning.clusterer import Clusterer
from learning.classifier import Classifier

def manual_clustering():
  feature_vectors, labels = Schedule.fetch_all(wrap=False)
  clusterer = Clusterer(feature_vectors, labels)
  clusterer.backend = MiniBatchKMeans(clusterer.num_clusters)
  clusterer.fit()

  print labels[0]
  print clusterer.predict(feature_vectors[0])

def manual_classification():
  preprocess_vectors = MitClass.fetch_preprocess_vectors()
  feature_vectors, labels = MitClass.fetch_feedback()
  classifier = Classifier(preprocess_vectors, feature_vectors, labels)
  classifier.backend = SVC()
  classifier.fit()

  print labels[0]
  print classifier.predict(feature_vectors[0])
