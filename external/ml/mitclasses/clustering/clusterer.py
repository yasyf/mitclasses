import numpy as np
from scipy.spatial import distance
from sklearn import preprocessing, decomposition, pipeline, feature_selection

class Clusterer(object):
  def __init__(self, feature_vectors, labels):
    self.feature_vectors = feature_vectors
    self.labels = labels
    self._preprocessor = pipeline.make_pipeline(
      feature_selection.VarianceThreshold(),
      preprocessing.StandardScaler(),
      decomposition.PCA(0.9, whiten=True)
    )
    self._backend = None

  def update(self, feature_vectors, labels):
    mask = np.in1d(labels, self.clusterer.labels, assume_unique=True, invert=True)
    new_feature_vectors, new_labels = feature_vectors[mask], labels[mask]
    self.feature_vectors = np.concatenate((self.feature_vectors, new_feature_vectors))
    self.labels = np.concatenate((self.labels, new_labels))

  @property
  def backend(self):
    return self._backend

  @backend.setter
  def backend(self, backend):
    self._backend = backend

  @property
  def num_clusters(self):
    if self.backend and self.backend.cluster_centers_:
      return self.backend.cluster_centers_.shape[0]
    return int(np.sqrt(self.feature_vectors.shape[0] / 2.0))

  def preprocess(self, X):
    return self._preprocessor.transform(X)

  def fit(self):
    assert self.backend is not None

    self.feature_vectors = self._preprocessor.fit_transform(self.feature_vectors)
    self.backend.fit(self.feature_vectors)

  def predict(self, X_raw):
    assert self.backend is not None

    X = self.preprocess(X_raw)

    cluster_index = self.backend.predict(X)
    cluster_mask = (self.backend.labels_ == cluster_index)

    cluster = self.feature_vectors[cluster_mask]
    labels = self.labels[cluster_mask]

    distances = np.apply_along_axis(lambda fv: distance.euclidean(fv, X), 1, cluster)
    sort_mask = np.argsort(distances)

    return labels[sort_mask]
