module ML
  class Schedule
    def initialize(mutex, schedules)
      @mutex = mutex
      @schedules = schedules
      @schedule_ids = @schedules.map(&:id)
      build_vectors
      set_learners
    end

    def suggestions(schedule_semester, ignore_conflicts: false, use_classifier: true)
      cluster = fetch_cluster(schedule_semester)

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
            next if !ignore_conflicts && schedule_semester.conflicts?(c)
            next unless c.prereqs.blank? || c.prereqs.satisfied?(completed_classes)
            next unless c.coreqs.blank? || c.coreqs.satisfied?(completed_classes)
            next if use_classifier && !evaluate(schedule_semester, c)

            all_class_set.add c.number
            yielder.yield c
          end
        end
      end
    end

    def destroy
      @clusterer.destroy
      @classifier.destroy
    end

    private

    def fetch_cluster(schedule_semester)
      @mutex.synchronize do
        @clusterer.eval schedule_semester.augmented_feature_vector
      end
    end

    def evaluate(schedule_semester, mit_class)
      @mutex.synchronize do
        result = @classifier.eval(Feedback.build_feature_vector(schedule_semester.schedule, mit_class)).first
        !(result.zero? || result.blank?)
      end
    end

    def build_vectors
      build_preprocessing_vectors
      build_feedback_vectors
      build_feature_vectors
    end

    def build_feature_vectors
      @feature_vectors = @schedules.flat_map(&:feature_vectors)
    end

    def build_preprocessing_vectors
      semester_ids = ::Schedule.where(id: @schedule_ids).joins(mit_classes: :semester).pluck('DISTINCT semester_id')
      @preprocessing_vectors = Semester.where(id: semester_ids).flat_map(&:feature_vectors).select { |fv| fv.present? }
    end

    def build_feedback_vectors
      feedback_ids = ::Schedule.where(id: @schedule_ids).joins(:feedbacks).pluck('DISTINCT feedbacks.id')
      @feedback_vectors = Feedback.where(id: feedback_ids).map(&:feature_vector)
    end

    def set_learners
      set_classifier
      set_clusterer
    end

    def set_classifier
      @classifier = Learners::Classifier.new(MitClass)
      @classifier.preprocess @preprocessing_vectors
      @classifier.build @feedback_vectors
    end

    def set_clusterer
      @clusterer = Learners::Clusterer.new(::Schedule)
      @clusterer.build @feature_vectors
    end
  end
end
