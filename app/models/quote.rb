class Quote < ApplicationRecord
  validates :name, presence: true

  belongs_to :company
  has_many :line_item_dates, dependent: :destroy
  has_many :line_items, through: :line_item_dates

  ##
  # broadcast_prepent_to async(activejob) equivalent is broadcast_prepend_later_to
  # broadcast_replace_to async equivalent is broadcast_replace_later_to

  # after_create_commit -> { broadcast_prepend_to "quotes_stream" } # optional target: "quotes"
  # after_update_commit -> { broadcast_replace_to "quotes_stream" }
  # after_destroy_commit -> { broadcast_remove_to "quotes_stream" }
  ##

  broadcasts_to ->(quote) { [quote.company, "quotes_stream"] }, inserts_by: :prepend

  def total_price
    line_items.sum(&:total_price)
  end
end
