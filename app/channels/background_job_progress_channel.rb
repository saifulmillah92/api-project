# frozen_string_literal: true

class BackgroundJobProgressChannel < ApplicationCable::Channel
  rescue_from StandardError, with: :report_error

  def subscribed
    stream_for [current_user]
  end
end
