from learner import Learner
from sklearn import pipeline, feature_selection, feature_extraction, base

class TextToVect(base.TransformerMixin):
  def __init__(self, index=0):
    self.index = index
    self.vectorizer = feature_extraction.text.CountVectorizer(binary=True)

  def fit(self, X):
    self.vectorizer.fit(X[self.index:])
    return self

  def transform(self, X):
    return X[:self.index] + self.vectorizer.transform(X[self.index:])

class Classifier(Learner):
  def __init__(self, feature_vectors, labels):
    super(Classifier, self).__init__(feature_vectors, labels)
    self._preprocessor = pipeline.make_pipeline(
      TextToVect(index=-1),
      feature_selection.VarianceThreshold()
    )
