import numpy as np

class Clusterer(object):
  def __init__(self, feature_vectors, labels):
    self.feature_vectors = feature_vectors
    self.labels = labels
    self._clusterer = None

  @property
  def backend(self):
    return self._backend

  @backend.setter
  def backend(self, backend):
    self._backend = backend

  @property
  def num_clusters(self):
    return int(np.sqrt(self.feature_vectors.shape[0] / 2))

  def fit(self):
    assert self.backend is not None

    self.backend.fit(self.feature_vectors, self.labels)

  def predict(self, X):
    assert self.backend is not None

    cluster = self.backend.predict(X)
    return self.labels[self.backend.labels_ == cluster]
