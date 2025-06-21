require 'rails_helper'

RSpec.describe NotesController, type: :controller do
  let(:note) { create(:note) }

  describe 'GET #index' do
    let!(:active_note) { create(:note, archived: false) }
    let!(:archived_note) { create(:note, :archived) }

    context 'without archived parameter' do
      before { get :index, format: :json }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns only active notes by default' do
        notes = JSON.parse(response.body)
        expect(notes).to be_an(Array)
        expect(notes.length).to eq(1)
        expect(notes.first['id']).to eq(active_note.id)
        expect(notes.first['title']).to eq(active_note.title)
        expect(notes.first['body']).to eq(active_note.body)
        expect(notes.first['updated_at']).to be_present
      end
    end

    context 'with archived=false' do
      before { get :index, params: { archived: 'false' }, format: :json }

      it 'returns only active notes' do
        notes = JSON.parse(response.body)
        expect(notes.length).to eq(1)
        expect(notes.first['id']).to eq(active_note.id)
      end
    end

    context 'with archived=true' do
      before { get :index, params: { archived: 'true' }, format: :json }

      it 'returns only archived notes' do
        notes = JSON.parse(response.body)
        expect(notes.length).to eq(1)
        expect(notes.first['id']).to eq(archived_note.id)
      end
    end

    context 'with invalid archived parameter' do
      before { get :index, params: { archived: 'invalid' }, format: :json }

      it 'returns only active notes (default behavior)' do
        notes = JSON.parse(response.body)
        expect(notes.length).to eq(1)
        expect(notes.first['id']).to eq(active_note.id)
      end
    end

    context 'when no notes exist' do
      before do
        Note.destroy_all
        get :index, format: :json
      end

      it 'returns empty array' do
        notes = JSON.parse(response.body)
        expect(notes).to eq([])
      end
    end
  end

  describe 'GET #show' do
    context 'when note exists' do
      before { get :show, params: { id: note.id }, format: :json }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the note as json' do
        note_data = JSON.parse(response.body)
        expect(note_data['id']).to eq(note.id)
        expect(note_data['title']).to eq(note.title)
        expect(note_data['body']).to eq(note.body)
        expect(note_data['updated_at']).to be_present
      end
    end

    context 'when note does not exist' do
      before { get :show, params: { id: 999999 }, format: :json }

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        { note: { title: 'New Note', body: 'Note content', archived: false } }
      end

      it 'creates a new note' do
        expect {
          post :create, params: valid_params, format: :json
        }.to change(Note, :count).by(1)
      end

      it 'returns http created' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:created)
      end

      it 'returns the created note' do
        post :create, params: valid_params, format: :json
        note_data = JSON.parse(response.body)
        expect(note_data['title']).to eq('New Note')
        expect(note_data['body']).to eq('Note content')
        expect(note_data['archived']).to eq(false)
      end
    end

    context 'with minimal parameters' do
      let(:minimal_params) { { note: { title: 'Minimal Note' } } }

      it 'creates a note with defaults' do
        expect {
          post :create, params: minimal_params, format: :json
        }.to change(Note, :count).by(1)
      end

      it 'sets default values' do
        post :create, params: minimal_params, format: :json
        note_data = JSON.parse(response.body)
        expect(note_data['title']).to eq('Minimal Note')
        expect(note_data['body']).to eq('')
        expect(note_data['archived']).to eq(false)
      end
    end

    context 'with invalid parameters' do
      context 'when title is missing' do
        let(:invalid_params) { { note: { body: 'Content without title' } } }

        it 'does not create a note' do
          expect {
            post :create, params: invalid_params, format: :json
          }.not_to change(Note, :count)
        end

        it 'returns http unprocessable entity' do
          post :create, params: invalid_params, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns validation errors' do
          post :create, params: invalid_params, format: :json
          errors = JSON.parse(response.body)
          expect(errors['title']).to include("can't be blank")
        end
      end

      context 'when title is empty' do
        let(:invalid_params) { { note: { title: '', body: 'Content' } } }

        it 'does not create a note' do
          expect {
            post :create, params: invalid_params, format: :json
          }.not_to change(Note, :count)
        end

        it 'returns validation errors' do
          post :create, params: invalid_params, format: :json
          errors = JSON.parse(response.body)
          expect(errors['title']).to include("can't be blank")
        end
      end

      context 'when title is only whitespace' do
        let(:invalid_params) { { note: { title: '   ', body: 'Content' } } }

        it 'does not create a note' do
          expect {
            post :create, params: invalid_params, format: :json
          }.not_to change(Note, :count)
        end

        it 'returns validation errors' do
          post :create, params: invalid_params, format: :json
          errors = JSON.parse(response.body)
          expect(errors['title']).to include("can't be blank")
        end
      end
    end

    context 'with archived note' do
      let(:archived_params) { { note: { title: 'Archived Note', archived: true } } }

      it 'creates an archived note' do
        post :create, params: archived_params, format: :json
        note_data = JSON.parse(response.body)
        expect(note_data['archived']).to eq(true)
      end
    end

    context 'with missing note parameter' do
      before { post :create, params: {}, format: :json }

      it 'returns http bad request' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error message' do
        error_data = JSON.parse(response.body)
        expect(error_data['error']).to eq('Missing required parameters')
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:update_params) do
        { id: note.id, note: { title: 'Updated Title', body: 'Updated content' } }
      end

      before { patch :update, params: update_params, format: :json }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'updates the note' do
        note_data = JSON.parse(response.body)
        expect(note_data['title']).to eq('Updated Title')
        expect(note_data['body']).to eq('Updated content')
      end

      it 'persists changes to database' do
        note.reload
        expect(note.title).to eq('Updated Title')
        expect(note.body).to eq('Updated content')
      end
    end

    context 'with partial parameters' do
      let(:original_title) { note.title }
      let(:update_params) do
        { id: note.id, note: { body: 'Only body updated' } }
      end

      before { patch :update, params: update_params, format: :json }

      it 'updates only provided fields' do
        note_data = JSON.parse(response.body)
        expect(note_data['title']).to eq(original_title)
        expect(note_data['body']).to eq('Only body updated')
      end
    end

    context 'with invalid parameters' do
      context 'when title is empty' do
        let(:update_params) { { id: note.id, note: { title: '' } } }

        before { patch :update, params: update_params, format: :json }

        it 'returns http unprocessable entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns validation errors' do
          errors = JSON.parse(response.body)
          expect(errors['title']).to include("can't be blank")
        end

        it 'does not update the note' do
          note.reload
          expect(note.title).not_to eq('')
        end
      end

      context 'when title is only whitespace' do
        let(:update_params) { { id: note.id, note: { title: '   ' } } }

        before { patch :update, params: update_params, format: :json }

        it 'returns validation errors' do
          errors = JSON.parse(response.body)
          expect(errors['title']).to include("can't be blank")
        end
      end
    end

    context 'when updating archived status' do
      let(:update_params) { { id: note.id, note: { archived: true } } }

      before { patch :update, params: update_params, format: :json }

      it 'updates archived status' do
        note_data = JSON.parse(response.body)
        expect(note_data['archived']).to eq(true)
      end
    end

    context 'when note does not exist' do
      let(:update_params) { { id: 999999, note: { title: 'Updated Title' } } }

      before { patch :update, params: update_params, format: :json }

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when note exists' do
      let!(:note_to_delete) { create(:note) }

      it 'deletes the note' do
        expect {
          delete :destroy, params: { id: note_to_delete.id }, format: :json
        }.to change(Note, :count).by(-1)
      end

      it 'returns http no content' do
        delete :destroy, params: { id: note_to_delete.id }, format: :json
        expect(response).to have_http_status(:no_content)
      end

      it 'removes the note from database' do
        delete :destroy, params: { id: note_to_delete.id }, format: :json
        expect(Note.exists?(note_to_delete.id)).to be false
      end
    end

    context 'when note does not exist' do
      before { delete :destroy, params: { id: 999999 }, format: :json }

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when note is already deleted' do
      before do
        note.destroy
        delete :destroy, params: { id: note.id }, format: :json
      end

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'edge cases' do
    context 'with extra parameters' do
      let(:extra_params) do
        {
          note: { title: 'Valid Title' },
          extra_field: 'should be ignored'
        }
      end

      it 'creates note and ignores extra parameters' do
        expect {
          post :create, params: extra_params, format: :json
        }.to change(Note, :count).by(1)
      end

      it 'returns http created' do
        post :create, params: extra_params, format: :json
        expect(response).to have_http_status(:created)
      end
    end
  end
end
