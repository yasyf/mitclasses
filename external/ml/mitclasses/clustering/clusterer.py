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

  def fit(self):
    assert self.backend is not None
    self.backend.fit(self.feature_vectors, self.labels)

  def predict(self, X):
    assert self.backend is not None
    return self.backend.predict(X)
