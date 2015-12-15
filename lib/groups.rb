module Groups
  class ClassWrapper
    def initialize(class_number)
      @class_number = class_number.is_a?(MitClass) ? class_number.number : class_number
    end

    def satisfied?(mit_classes)
      mit_classes.map(&:number).include?(@class_number)
    end

    def simplify
      self
    end

    def to_s(nested: false)
      @class_number
    end

    alias_method :to_h, :to_s
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

    alias_method :as_json, :to_h

    def op
      self.class.name.demodulize.downcase
    end

    def satisfied?(classes)
      raise NotImplementedError
    end

    def simplify
      self.class.new simplified_classes
    end

    def simplify!
      @classes = simplified_classes
      self
    end

    def to_s(nested: false)
      s = @classes.map { |c| c.to_s(nested: true) }.join(" #{op} ")
      (nested && @classes.size > 1) ? "(#{s})" : s
    end

    private

    def simplified_classes
      classes = @classes.map(&:simplify)
      if classes.all? { |c| c.is_a?(self.class) }
        classes.flat_map { |c| c.instance_variable_get(:@classes) }
      else
        classes
      end
    end
  end

  class Or < Operation
    def satisfied?(classes)
      @classes.any? { |c| c.satisfied? classes }
    end
  end

  class And < Operation
    def satisfied?(classes)
      @classes.all? { |c| c.satisfied? classes }
    end
  end
end
