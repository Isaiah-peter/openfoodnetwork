# frozen_string_literal: true

class ModalComponent < ViewComponent::Base
  def initialize(id:, close_button: true, instant: false, modal_class: :small)
    @id = id
    @close_button = close_button
    @instant = instant
    @modal_class = modal_class
  end

  private

  def close_button_class
    if namespace == "admin"
      "red"
    else
      "primary"
    end
  end

  def close_button?
    !!@close_button
  end

  def namespace
    helpers.controller_path.split("/").first
  end
end
