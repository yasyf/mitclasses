import numpy as np
from scipy.spatial import distance
from learner import Learner
from sklearn import preprocessing, decomposition, pipeline, feature_selection, cluster

class Clusterer(Learner):
  def __init__(self, feature_vectors, labels):
    super(Clusterer, self).__init__(feature_vectors, labels)
    self._preprocessor = pipeline.make_pipeline(
      feature_selection.VarianceThreshold(),
      preprocessing.StandardScaler(),
      cluster.FeatureAgglomeration(n_clusters=int(self.num_features / 4.0)),
      decomposition.PCA(0.75, whiten=True)
    )
    self._half_feature_vectors = None

  @property
  def num_clusters(self):
    if self.backend and self.backend.cluster_centers_:
      return self.backend.cluster_centers_.shape[0]
    return super(Clusterer, self).num_clusters

  @property
  def half_index(self):
    return self.num_original_features / 2

  def fit(self):
    self._half_feature_vectors = self.feature_vectors.copy()
    Learner.fit(self)
    self._half_feature_vectors[:,self.half_index:] = 0
    self._half_feature_vectors = self.preprocess(self._half_feature_vectors)

  def postprocess(self, X_raw, X, cluster_index):
    assert self.backend is not None

    cluster_mask = (self.backend.labels_ == cluster_index)

    cluster = self._half_feature_vectors[cluster_mask]
    labels = self.labels[cluster_mask]

    X_comp = X_raw.copy()
    X_comp[self.half_index:] = 0
    X_comp = self.preprocess(X_comp)

    distances = np.apply_along_axis(lambda fv: distance.euclidean(fv, X_comp), 1, cluster)
    sort_mask = np.argsort(distances)

    return labels[sort_mask]
