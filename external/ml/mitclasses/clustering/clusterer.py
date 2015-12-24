import numpy as np
from scipy.spatial import distance

class Clusterer(object):
  def __init__(self, feature_vectors, labels):
    self.feature_vectors = feature_vectors
    self.labels = labels
    self._clusterer = None

  def update(self, feature_vectors, labels):
    self.feature_vectors = np.concatenate((self.feature_vectors, feature_vectors))
    self.labels = np.concatenate((self.labels, labels))

  @property
  def backend(self):
    return getattr(self, '_backend', None)

  @backend.setter
  def backend(self, backend):
    self._backend = backend

  @property
  def num_clusters(self):
    if self.backend and self.backend.cluster_centers_:
      return self.backend.cluster_centers_.shape[0]
    return int(np.sqrt(self.feature_vectors.shape[0] / 2))

  def fit(self):
    assert self.backend is not None
    # TODO: PCA or some other dimensionality reduction
    self.backend.fit(self.feature_vectors)

  def predict(self, X):
    assert self.backend is not None

    cluster_index = self.backend.predict(X)
    cluster_mask = (self.backend.labels_ == cluster_index)

    cluster = self.feature_vectors[cluster_mask]
    labels = self.labels[cluster_mask]

    distances = np.apply_along_axis(lambda fv: distance.euclidean(fv, X), 1, cluster)
    sort_mask = np.argsort(distances)

    return labels[sort_mask]
