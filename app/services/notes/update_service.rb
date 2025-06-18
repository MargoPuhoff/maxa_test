class Notes::UpdateService
  attr_reader :note, :params

  def initialize(note, params)
    @note = note
    @params = params
  end

  def call
    if @note.update(note_params)
      { success: true, note: @note }
    else
      { success: false, errors: @note.errors }
    end
  end

  private

  def note_params
    params.require(:note).permit(:title, :body, :archived)
  end
end
