class NotesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  before_action :set_note, only: %i[ show update destroy ]

  # GET /notes
  def index
    @notes = Note.filter_by_archived_status(params[:archived])
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
      render json: result[:note], status: :created
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

    def record_not_found
      render json: { error: "Note not found" }, status: :not_found
    end

    def parameter_missing
      render json: { error: "Missing required parameters" }, status: :bad_request
    end

    # Only allow a list of trusted parameters through.
    def note_params
      params.require(:note).permit(:title, :body, :archived)
    end
end
