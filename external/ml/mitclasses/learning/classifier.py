from models.base import Base
from learner import Learner
import scipy
import numpy as np
from sklearn import feature_extraction, base, pipeline, feature_selection, preprocessing

class TextToVect(base.TransformerMixin):
  DATA_TYPE = 'float64'

  def __init__(self, index=0):
    self.index = index
    self.vectorizer = feature_extraction.text.CountVectorizer(stop_words='english', binary=True)

  def fit(self, X):
    return self

  def pre_fit(self, X):
    self.vectorizer.fit(X[:,self.index:].flatten())
    return self

  def transform(self, X):
    index = X.shape[-1] + self.index if self.index < 0 else self.index
    rest, transformed = np.array_split(X, [index], axis=-1)

    transformed = self.vectorizer.transform(transformed.flatten())
    rest = rest.astype(self.DATA_TYPE)

    return scipy.sparse.hstack((rest, transformed)).toarray()

class Classifier(Learner):
  def __init__(self, preprocessing_vectors, feature_vectors, labels):
    super(Classifier, self).__init__(feature_vectors, labels)
    self._vectorizer = TextToVect(index=-1)
    self._preprocessor = pipeline.make_pipeline(
      self._vectorizer,
      feature_selection.VarianceThreshold(),
      preprocessing.StandardScaler(),
    )
    self.preprocessing_vectors = preprocessing_vectors

  def update_preprocess(self, preprocessing_vectors):
    self.preprocessing_vectors = np.concatenate((self.preprocessing_vectors, preprocessing_vectors))

  def _preprocess_and_fit(self):
    self.labels = self.labels.ravel()
    self._vectorizer.pre_fit(self.preprocessing_vectors)
    super(Classifier, self)._preprocess_and_fit()

  @classmethod
  def empty(cls, num_preprocessing_features, num_features):
    return cls(Base.empty_vector(num_preprocessing_features),
               Base.empty_vector(num_features), Base.empty_label())
