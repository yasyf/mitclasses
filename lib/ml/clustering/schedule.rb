module ML
  module Clustering
    class Schedule
      def initialize(schedules)
        @schedules = schedules
        build_feature_vectors
        set_clusterer
      end

      def suggestions(schedule_semester)
        cluster = eval(schedule_semester)

        all_classes = schedule_semester.schedule.classes.includes(:semester)
        all_class_set = Set.new all_classes.map(&:number)
        all_class_set |= all_classes.flat_map(&:equivalents)
        completed_classes = all_classes.select { |c| c.semester < schedule_semester.semester }

        Enumerator.new do |yielder|
          cluster.each do |id|
            next if id == schedule_semester.id
            ::Schedule.parse(id).classes.map(&:number).each do |cn|
              c = schedule_semester.semester.mit_class!(cn)

              next unless c.offered?
              next if all_class_set.include?(c.number)
              next if schedule_semester.conflicts? c
              next unless c.prereqs.blank? || c.prereqs.satisfied?(completed_classes)
              next unless c.coreqs.blank? || c.coreqs.satisfied?(completed_classes)

              all_class_set.add c.number
              yielder.yield c
            end
          end
        end
      end

      def destroy
        @clusterer.destroy
      end

      private

      def eval(schedule_semester)
        @clusterer.eval schedule_semester.feature_vector
      end

      def build_feature_vectors
        @feature_vectors = @schedules.flat_map(&:feature_vectors)
      end

      def set_clusterer
        @clusterer = ML::Clustering::Clusterer.new(@feature_vectors.first.size - 1)
        @clusterer.build(@feature_vectors)
      end
    end
  end
end
