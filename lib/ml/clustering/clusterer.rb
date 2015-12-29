require 'socket'

module ML
  module Clustering
    class Clusterer < Learner
      def self.type
        :cluster
      end
    end
  end
end
