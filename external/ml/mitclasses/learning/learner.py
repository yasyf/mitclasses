import numpy as np
from models.schedule import Schedule

class Learner(object):
  def __init__(self, feature_vectors, labels):
    self.feature_vectors = feature_vectors
    self.labels = labels
    self._preprocessor = None
    self._backend = None
    self._original_feature_vectors = None

  @classmethod
  def empty(cls, num_features):
    return cls(Schedule.empty_vector(num_features), Schedule.empty_label())

  def update(self, feature_vectors, labels, assume_unique=True):
    if not assume_unique:
      mask = np.in1d(labels, self.labels, assume_unique=True, invert=True)
      feature_vectors, labels = feature_vectors[mask], labels[mask]
    self.feature_vectors = np.concatenate((self.feature_vectors, feature_vectors))
    self.labels = np.concatenate((self.labels, labels))

  @property
  def backend(self):
    return self._backend

  @backend.setter
  def backend(self, backend):
    self._backend = backend

  @property
  def num_features(self):
    return self.feature_vectors.shape[1]

  @property
  def num_original_features(self):
    try:
      return self._original_feature_vectors.shape[1]
    except AttributeError:
      return self.num_features

  @property
  def num_samples(self):
    return self.feature_vectors.shape[0]

  @property
  def num_clusters(self):
    return int(np.sqrt(self.num_samples / 2.0))

  def preprocess(self, X):
    assert self._preprocessor is not None

    return self._preprocessor.transform(X)

  def postprocess(self, X_raw, X, y):
    return y

  def fit(self):
    assert self.backend is not None

    self._original_feature_vectors = self.feature_vectors.copy()
    self.feature_vectors = self._preprocessor.fit_transform(self.feature_vectors)
    self.backend.fit(self.feature_vectors)

  def predict(self, X_raw):
    assert self.backend is not None

    X = self.preprocess(X_raw)
    return self.postprocess(X_raw, X, self.backend.predict(X))
