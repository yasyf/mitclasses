import sys, os
from server import Server
from models.schedule import Schedule
from clustering.clusterer import Clusterer
from sklearn.cluster import MiniBatchKMeans

def main_loop():
  server = Server(int(sys.argv[1]), int(sys.argv[2]))
  try:
    server.start(server.minibatch_kmeans_backend)
  except StopIteration:
    pass
  finally:
    server.close()

def manual():
  feature_vectors, labels = Schedule.fetch_all(wrap=False)
  clusterer = Clusterer(feature_vectors, labels)
  clusterer.backend = MiniBatchKMeans(clusterer.num_clusters)
  clusterer.fit()

  print labels[0]
  print clusterer.predict(feature_vectors[0])

if __name__ == '__main__':
  if os.getenv('MODE') == 'manual':
    manual()
  else:
    main_loop()
