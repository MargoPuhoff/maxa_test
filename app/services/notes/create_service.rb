class Notes::CreateService
  attr_reader :params, :note

  def initialize(params)
    @params = params
  end

  def call
    @note = Note.new(note_params)

    if @note.save
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
