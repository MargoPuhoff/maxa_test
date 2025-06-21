class NoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :archived, :updated_at
end
