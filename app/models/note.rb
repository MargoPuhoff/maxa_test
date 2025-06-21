class Note < ApplicationRecord
  validates :title, presence: true

  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }

  def self.filter_by_archived_status(status)
    case status
    when "true"
      archived
    when "false"
      active
    else
      active
    end
  end
end
