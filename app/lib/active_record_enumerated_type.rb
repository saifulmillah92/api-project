# frozen_string_literal: true

module ActiveRecordEnumeratedType
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def inherited(base)
      super
      base.instance_variable_set("@types", types)
    end

    def set_types(hash_map)
      @types = hash_map
      validates :type, inclusion: @types.keys.map(&:to_s)
    end

    def types
      @types.to_h.with_indifferent_access
    end

    def sti_name
      types.key(name) || nil
    end

    def find_sti_class(type_name)
      types[type_name].to_s.safe_constantize || self
    end

    def type_condition(table = arel_table)
      sti_column = table[inheritance_column]
      name = sti_name
      return nil unless name

      sti_column.eq(name)
    end

    def subclass_from_attributes(attrs)
      attrs = attrs.to_h if attrs.respond_to?(:permitted?)
      return unless attrs.is_a?(Hash)

      subclass_name = attrs.with_indifferent_access[inheritance_column]

      return unless subclass_name.present? && subclass_name != name

      subclass = find_sti_class(subclass_name)

      return if subclass == self

      unless descendants.include?(subclass)
        raise ActiveRecord::SubclassNotFound, "Invalid single-table inheritance type: "\
          "#{subclass} is not a subclass of #{name}"
      end

      subclass
    end
  end
end
