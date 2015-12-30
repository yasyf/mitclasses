module ML
  module Learners
    class Classifier < Learner
      def self.type
        :classify
      end
    end
  end
end
