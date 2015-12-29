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

  @property
  def num_clusters(self):
    if self.backend and self.backend.cluster_centers_:
      return self.backend.cluster_centers_.shape[0]
    return super(Clusterer, self).num_clusters

  def postprocess(self, X, cluster_index):
    assert self.backend is not None

    cluster_mask = (self.backend.labels_ == cluster_index)

    cluster = self.feature_vectors[cluster_mask]
    labels = self.labels[cluster_mask]

    distances = np.apply_along_axis(lambda fv: distance.euclidean(fv, X), 1, cluster)
    sort_mask = np.argsort(distances)

    return labels[sort_mask]
