import json, socket, gc
from sklearn.cluster import MiniBatchKMeans, AffinityPropagation
from sklearn.svm import SVC

class Server(object):
  SOCKET_BUFFSIZE = 1048576

  def __init__(self, socket_fd, learner, parser):
    self.socket = socket.fromfd(socket_fd, socket.AF_UNIX, socket.SOCK_DGRAM)
    self.learner = learner
    self.parser = parser

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
        feature_vectors, labels = self.parser(message['data'])
        self.learner.update(feature_vectors, labels)
      elif message['type'] == 'preprocess':
        preprocess_vectors, _ = self.parser(message['data'])
        self.learner.update_preprocess(preprocess_vectors)
      elif message['type'] == 'eof':
        break

  def read_from_stdin(self):
    while True:
      message = self.read()
      if message['type'] == 'features':
        return self.parser(message['data'])
      elif message['type'] == 'quit':
        raise StopIteration

  def affinity_propogation_backend(self):
    return AffinityPropagation()

  def minibatch_kmeans_backend(self):
    return MiniBatchKMeans(n_clusters=self.learner.num_clusters)

  def svc_backend(self):
    return SVC()

  def start(self, backend_fn=None):
    self.seed_from_stdin()
    self.learner.backend = backend_fn()
    self.learner.fit()

    self.send('trained model')

    self.predict_loop()

  def _predict(self):
    feature_vectors, _ = self.read_from_stdin()
    feature_vector = feature_vectors[0].reshape(1, -1)
    result = self.learner.predict(feature_vector)
    self.send(result.tolist(), 'result')

  def predict_loop(self):
    while True:
      self._predict()
      gc.collect()
