import json
from models.schedule import Schedule
from clustering.clusterer import Clusterer
from sklearn.cluster import KMeans, AffinityPropagation

class Server(object):
  def __init__(self, num_features):
    self.input = []
    self.clusterer = Clusterer(Schedule.empty_vector(num_features), Schedule.empty_label())

  def read(self):
    while True:
      try:
        self.input.append(raw_input())
      except EOFError:
        break

  def parse(self):
    parsed_input = json.loads('\n'.join(self.input))
    self.input = []
    return Schedule.parse_raw(parsed_input)

  def parse_from_stdin(self):
    self.read()
    return self.parse()

  def parse_from_http(self):
    return Schedule.fetch_all(wrap=False)

  def affinity_propogation_backend(self):
    return AffinityPropagation()

  def kmeans_backend(self):
    return KMeans(n_clusters=self.clusterer.num_clusters)

  def start(self):
    feature_vectors, labels = self.parse_from_stdin()
    self.clusterer.update(feature_vectors, labels)
    self.clusterer.backend = self.affinity_propogation_backend()
    self.clusterer.fit()

    self.predict_loop()

  def predict_loop(self):
    while True:
      feature_vectors, _ = self.parse_from_stdin()
      feature_vector = feature_vectors[0].reshape(1, -1)
      print(json.dumps({'cluster': self.clusterer.predict(feature_vector).tolist()}))
