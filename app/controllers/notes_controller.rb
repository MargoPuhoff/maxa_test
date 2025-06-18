class NotesController < ApplicationController
  before_action :set_note, only: %i[ show update destroy ]

  # GET /notes
  def index
    @notes = Note.all
    render json: @notes
  end

  # GET /notes/1
  def show
    render json: @note
  end

  # POST /notes
  def create
    result = Notes::CreateService.new(params).call

    if result[:success]
      render json: result[:note], status: :created, location: result[:note]
    else
      render json: result[:errors], status: :unprocessable_entity
    end
  end

  # PATCH/PUT /notes/1
  def update
    result = Notes::UpdateService.new(@note, params).call

    if result[:success]
      render json: result[:note]
    else
      render json: result[:errors], status: :unprocessable_entity
    end
  end

  # DELETE /notes/1
  def destroy
    @note.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = Note.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def note_params
      params.fetch(:note, {})
    end
end
