# frozen_string_literal: true

class NullPresenter < Presenters::Base
  def self.root
    nil
  end

  def initialize(*_args)
    super({}, {})
  end

  def status
    :accepted
  end

  def presentation
    {}
  end
end
