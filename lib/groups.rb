module Groups
  class ClassWrapper
    def initialize(class_number)
      @class_number = class_number.is_a?(MitClass) ? class_number.number : class_number
    end

    def satisfied?(mit_classes)
      mit_classes.map(&:number).include?(@class_number)
    end

    def to_s
      @class_number
    end

    alias_method :to_h, :to_s
    alias_method :nested_to_s, :to_s
  end

  class Operation
    def initialize(classes)
      @classes = classes.map do |c|
        if c.is_a?(Operation) || c.is_a?(ClassWrapper)
          c
        elsif c.is_a?(Hash)
          self.class.load c
        else
          ClassWrapper.new(c)
        end
      end
    end

    def self.load(hash)
      operation = "#{self.parent.name}::#{hash['op'].camelize}".constantize
      operation.new hash['classes']
    end

    def to_h
      { classes: @classes.map(&:to_h), op: op }.with_indifferent_access
    end

    def to_json
      to_h.to_json
    end

    def op
      self.class.name.demodulize.downcase
    end

    def satisfied?(classes)
      raise NotImplementedError
    end

    def to_s
      @classes.map { |c| c.send(:nested_to_s) }.join(" #{op} ")
    end

    private

    def nested_to_s
      @classes.size > 1 ? "(#{to_s})" : to_s
    end
  end

  class Or < Operation
    def satisfied?(classes)
      @classes.map { |c| c.satisfied? classes }.any?
    end
  end

  class And < Operation
    def satisfied?(classes)
      @classes.map { |c| c.satisfied? classes }.all?
    end
  end
end
