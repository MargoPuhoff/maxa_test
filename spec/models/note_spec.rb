require 'rails_helper'

RSpec.describe Note, type: :model do
  describe 'validations' do
    subject { build(:note) }

    it { is_expected.to be_valid }

    context 'when title is present' do
      it 'is valid' do
        note = build(:note, title: 'Valid Title')
        expect(note).to be_valid
      end
    end

    context 'when title is missing' do
      it 'is invalid' do
        note = build(:note, title: nil)
        expect(note).not_to be_valid
        expect(note.errors[:title]).to include("can't be blank")
      end

      it 'is invalid with empty string' do
        note = build(:note, title: '')
        expect(note).not_to be_valid
        expect(note.errors[:title]).to include("can't be blank")
      end

      it 'is invalid with only whitespace' do
        note = build(:note, title: '   ')
        expect(note).not_to be_valid
        expect(note.errors[:title]).to include("can't be blank")
      end
    end
  end

  describe 'attributes' do
    let(:note) { create(:note) }

    it 'has the expected attributes' do
      expect(note).to respond_to(:title)
      expect(note).to respond_to(:body)
      expect(note).to respond_to(:archived)
      expect(note).to respond_to(:created_at)
      expect(note).to respond_to(:updated_at)
    end

    it 'has default values' do
      note = Note.new
      expect(note.title).to eq('')
      expect(note.body).to eq('')
      expect(note.archived).to eq(false)
    end
  end

  describe 'factory' do
    it 'creates a valid note' do
      note = build(:note)
      expect(note).to be_valid
    end

    it 'creates an archived note with trait' do
      note = build(:note, :archived)
      expect(note.archived).to be true
      expect(note).to be_valid
    end

    it 'creates a note with long title using trait' do
      note = build(:note, :with_long_title)
      expect(note.title.split.length).to be >= 10
      expect(note).to be_valid
    end

    it 'creates a note with empty body using trait' do
      note = build(:note, :with_empty_body)
      expect(note.body).to eq('')
      expect(note).to be_valid
    end
  end

  describe 'database constraints' do
    it 'can be saved to database' do
      note = build(:note)
      expect { note.save! }.not_to raise_error
    end

    it 'can be updated' do
      note = create(:note)
      note.title = 'Updated Title'
      expect { note.save! }.not_to raise_error
      expect(note.reload.title).to eq('Updated Title')
    end

    it 'can be deleted' do
      note = create(:note)
      expect { note.destroy! }.not_to raise_error
      expect(Note.exists?(note.id)).to be false
    end
  end

  describe 'timestamps' do
    let(:note) { create(:note) }

    it 'sets created_at on creation' do
      expect(note.created_at).to be_present
      expect(note.created_at).to be_within(1.second).of(Time.current)
    end

    it 'sets updated_at on creation' do
      expect(note.updated_at).to be_present
      expect(note.updated_at).to be_within(1.second).of(Time.current)
    end

    it 'updates updated_at on modification' do
      original_updated_at = note.updated_at
      sleep(1.second)
      note.update!(title: 'Modified Title')
      expect(note.updated_at).to be > original_updated_at
    end
  end

  describe 'edge cases' do
    it 'handles very long titles' do
      long_title = 'a' * 1000
      note = build(:note, title: long_title)
      expect(note).to be_valid
    end

    it 'handles very long bodies' do
      long_body = 'a' * 10000
      note = build(:note, body: long_body)
      expect(note).to be_valid
    end

    it 'handles special characters in title' do
      special_title = "Title with special chars: !@#$%^&*()_+-=[]{}|;':\",./<>?"
      note = build(:note, title: special_title)
      expect(note).to be_valid
    end

    it 'handles unicode characters' do
      unicode_title = "Заголовок с кириллицей и emoji 🧑‍💻"
      note = build(:note, title: unicode_title)
      expect(note).to be_valid
    end
  end
end
