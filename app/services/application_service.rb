# frozen_string_literal: true

# ApplicationService
class ApplicationService
  include ApiHelper
  include AfterCommitEverywhere
  delegate :permission?, to: GeneralPermission

  @@parent_transaction_count = 10

  def self.parent_transaction_count(number)
    @@parent_transaction_count = number
  end

  def initialize(*)
    # empty
  end

  def authenticate!(object, on_error: t("unauthenticated"))
    raise Unauthenticated, on_error unless object
  end

  def assert!(*truths, on_error: t("invalid"))
    raise Invalid, on_error if truths.none?
  end

  def authorize!(*truths, on_error: t("not_allowed"))
    raise Unauthorized, on_error if truths.none?
  end

  def transaction(*args, &block)
    if in_transaction?
      yield
    else
      ActiveRecord::Base.transaction(*args, &block)
    end
  end

  private

  def in_transaction?
    ActiveRecord::Base.connection.open_transactions > @@parent_transaction_count
  end

  class NotFound < ::StandardError
  end

  class Unauthenticated < ::StandardError
  end

  class Unauthorized < ::StandardError
  end

  class Invalid < ::StandardError
  end

  class Throttled < ::StandardError
  end
end
