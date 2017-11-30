class QuestionsUpdater
  include ErrorsHandler

  def initialize(question, params)
    @question = question

    @params = params
  end

  def resource
    @question.assign_attributes(@params)

    @question
  end

  def update
    save_resource
  end
end
