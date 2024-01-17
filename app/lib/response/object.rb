# frozen_string_literal: true

module Response
  class Object
    class << self
      attr_reader :type

      def set_type
        @type = underscore(to_s).gsub(/.*\//, "").to_sym
      end

      def inherited(klass)
        klass.set_type
      end

      def underscore(string)
        return string.underscore if string.respond_to?(:underscore)
        return string unless string.match?(/[ A-Z-]|::/)

        string.gsub(/::/, '/')
              .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
              .gsub(/([a-z\d])([A-Z])/, '\1_\2')
              .tr("-", "_")
              .downcase
      end
    end

    def type
      self.class.type
    end

    def success?
      is_a? Success
    end

    def failure?
      is_a? Failure
    end
  end

  class Success < Response::Object
    attr_reader :data

    def initialize(data) @data = data end
  end

  class Created < Success
  end

  class Failure < Response::Object
    attr_reader :error, :data

    def initialize(error, data) @error, @data = error, data end
  end

  class Unauthenticated < Failure
  end

  class NotFound < Failure
  end

  class NotAllowed < Failure
  end

  class Invalid < Failure
    def error
      errors.first
    end

    def errors
      if @error.is_a?(ActiveModel::Errors)
        @error
      else
        Array(@error)
      end
    end
  end
end
