import sys, os
from server import Server
from models.schedule import Schedule
from models.mit_class import MitClass
from learning.clusterer import Clusterer
from learning.classifier import Classifier
from sklearn.cluster import MiniBatchKMeans
from sklearn.svm import SVC

def main_loop():
  socket_fd, num_features, learning_type = sys.argv[1:4]

  if learning_type == 'cluster':
    learner = Clusterer.empty(int(num_features))
  elif learning_type == 'classify':
    learner = Classifier.empty(int(num_features))
  else:
    raise RuntimeError('invalid learning_type!')
  server = Server(int(socket_fd), learner, Schedule.parse_raw)
  try:
    server.start(server.minibatch_kmeans_backend)
  except StopIteration:
    pass
  finally:
    server.close()

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

if __name__ == '__main__':
  if os.getenv('MODE') == 'clustering':
    manual_clustering()
  elif os.getenv('MODE') == 'classification':
    manual_classification()
  else:
    main_loop()
