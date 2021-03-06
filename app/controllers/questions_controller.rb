class QuestionsController < ApplicationController
  skip_before_action :authenticate, only: [:show, :index]

  before_action :set_question, only: [:show, :update, :destroy]

  before_action :authorize_question, only: [:update, :destroy]

  def show
    render json: @question
  end

  def index
    questions = QuestionSearcher.new(params).search

    render json: questions
  end

  def create
    authorize(:question, :create?)

    QuestionCreator.new(resource_params.merge(user: current_user))
      .on(:succeeded) { |serialized_resource| render json: serialized_resource, status: 201 }
      .on(:failed) { |errors| render json: errors, status: 422 }
      .call
  end

  def update
    QuestionUpdater.new(@question, resource_params)
      .on(:succeeded) { |serialized_resource| render json: serialized_resource }
      .on(:failed) { |errors| render json: errors, status: 422 }
      .call
  end

  def destroy
    QuestionDestroyer.new(@question).destroy

    head 204
  end

  private
  def authorize_question
    authorize @question
  end

  def set_question
    @question ||= Question.find(params[:id])
  end

  def resource_params
    params.require(:question).permit(:title, :body).to_h
  end
end
