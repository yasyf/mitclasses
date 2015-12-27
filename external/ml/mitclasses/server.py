import json, socket
from models.schedule import Schedule
from clustering.clusterer import Clusterer
from sklearn.cluster import KMeans, MiniBatchKMeans, AffinityPropagation

class Server(object):
  SOCKET_BUFFSIZE = 65536

  def __init__(self, socket_fd, num_features):
    self.socket = socket.fromfd(socket_fd, socket.AF_UNIX, socket.SOCK_DGRAM)
    self.clusterer = Clusterer(Schedule.empty_vector(num_features), Schedule.empty_label())

  def read(self):
    try:
      return json.loads(self.socket.recv(self.SOCKET_BUFFSIZE))
    except ValueError:
      self.send('decode failed', 'error')
      return self.read()

  def send(self, data, type_='info'):
    self.socket.send(json.dumps({'type': type_, 'data': data}))

  def close(self):
    self.socket.close()

  def seed_from_stdin(self):
    while True:
      message = self.read()
      if message['type'] == 'features':
        feature_vectors, labels = Schedule.parse_raw(message['data'])
        self.clusterer.update(feature_vectors, labels)
      elif message['type'] == 'eof':
        break

  def read_from_stdin(self):
    while True:
      message = self.read()
      if message['type'] == 'features':
        return Schedule.parse_raw(message['data'])
      elif message['type'] == 'quit':
        raise StopIteration

  def seed_from_http(self):
    feature_vectors, labels = Schedule.fetch_all(wrap=False)
    self.clusterer.update(feature_vectors, labels)

  def affinity_propogation_backend(self):
    return AffinityPropagation()

  def kmeans_backend(self):
    return KMeans(n_clusters=self.clusterer.num_clusters, n_jobs=-1)

  def minibatch_kmeans_backend(self):
    return MiniBatchKMeans(n_clusters=self.clusterer.num_clusters)

  def start(self, backend_fn=None):
    self.seed_from_stdin()
    self.clusterer.backend = backend_fn() or self.kmeans_backend()
    self.clusterer.fit()

    self.send('trained model')

    self.predict_loop()

  def predict_loop(self):
    while True:
      feature_vectors, _ = self.read_from_stdin()
      feature_vector = feature_vectors[0].reshape(1, -1)
      cluster = self.clusterer.predict(feature_vector)
      self.send(cluster.tolist(), 'cluster')
