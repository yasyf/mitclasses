from learner import Learner
import scipy
import numpy as np
from sklearn import feature_extraction, base

class TextToVect(base.TransformerMixin):
  DATA_TYPE = 'float64'

  def __init__(self, index=0):
    self.index = index
    self.vectorizer = feature_extraction.text.CountVectorizer(stop_words='english', binary=True)

  def fit(self, X):
    self.vectorizer.fit(X[:,self.index:].flatten())
    return self

  def transform(self, X):
    index = X.shape[-1] + self.index if self.index < 0 else self.index
    rest, transformed = np.array_split(X, [index], axis=-1)

    transformed = self.vectorizer.transform(transformed.flatten())
    rest = rest.astype(self.DATA_TYPE)

    return scipy.sparse.hstack((rest, transformed))

class Classifier(Learner):
  def __init__(self, preprocessing_vectors, feature_vectors, labels):
    super(Classifier, self).__init__(feature_vectors, labels.flatten())
    self._preprocessor = TextToVect(index=-1)
    self.preprocessing_vectors = preprocessing_vectors

  def _preprocess_and_fit(self):
    self._preprocessor.fit(self.preprocessing_vectors)
    self.feature_vectors = self._preprocessor.transform(self.feature_vectors)
    self.backend.fit(self.feature_vectors, self.labels)
