require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  it { is_expected.to be_an ApplicationController }

  let(:attrs) { attributes_for(:question) }

  let(:question) { instance_double(Question, id: 1, as_json: attrs, **attrs) }

  let(:user) { instance_double User }

  let(:resource_params) { attributes_for(:question) }

  let(:question_id) { '1' }

  before { allow(Question).to receive(:find).with(question_id).and_return(question) }

  describe 'POST #create' do
    context 'user authenticated' do
      before { sign_in user }

      context 'user is valid' do
        before { allow(subject).to receive(:authorize).and_return(true) }

        let(:creator) { QuestionCreator.new(resource_params) }

        context 'new question was created' do
          before { allow(QuestionCreator).to receive(:new).and_return(creator) }

          before { expect(creator).to receive(:on).twice.and_call_original }

          before { broadcast_succeeded creator, question }

          before { process :create, method: :post, params: { question: resource_params }, format: :json }

          it('returns created question') { expect(response.body).to eq question.to_json }

          it('returns HTTP Status Code 201') { expect(response).to have_http_status 201 }
        end

        context 'user sent invalid attributes' do
          let(:errors) { instance_double(ActiveModel::Errors) }

          before { allow(QuestionCreator).to receive(:new).and_return(creator) }

          before { expect(creator).to receive(:on).twice.and_call_original }

          before { broadcast_failed creator, errors }

          before { process :create, method: :post, params: { question: resource_params }, format: :json }

          it('returns errors') { expect(response.body).to eq errors.to_json }

          it('returns HTTP Status Code 422') { expect(response).to have_http_status 422 }
        end

        context 'bad request was sent' do
          before { process :create, method: :post, params: { ' ': resource_params }, format: :json }

          it('returns HTTP Status Code 400') { expect(response).to have_http_status 400 }
        end
      end

      context 'user is not valid' do
        before { expect(subject).to receive(:authorize).and_raise Pundit::NotAuthorizedError }

        before { process :create, method: :post, params: { question: resource_params }, format: :json }

        it('returns HTTP Status Code 403') { expect(response).to have_http_status 403 }
      end
    end

    context 'user not authenticated' do
      before { process :create, method: :post, params: { question: resource_params }, format: :json }

      it('returns HTTP Status Code 401') { expect(response).to have_http_status 401 }
    end
  end

  describe 'PATCH #update' do
    context 'user authenticated' do
      before { sign_in user }

      context 'question was found' do
        context 'user passed authorization' do
          before { allow(subject).to receive(:authorize).and_return true }

          let(:updater) { QuestionUpdater.new(resource_params, question) }

          context 'question was updated' do
            before { allow(QuestionUpdater).to receive(:new).and_return(updater) }

            before { expect(updater).to receive(:on).twice.and_call_original }

            before { broadcast_succeeded updater, question }

            before { process :update, method: :patch, params: { id: question_id, question: resource_params }, format: :json }

            it('returns updated question') { expect(response.body).to eq question.to_json }

            it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
          end

          context 'invalid attributes were sent' do
            let(:errors) { instance_double(ActiveModel::Errors) }

            before { allow(QuestionUpdater).to receive(:new).and_return(updater) }

            before { expect(updater).to receive(:on).twice.and_call_original }

            before { broadcast_failed updater, errors }

            before { process :update, method: :patch, params: { id: question_id, question: resource_params }, format: :json }

            it('returns errors') { expect(response.body).to eq errors.to_json }

            it('returns HTTP Status Code 422') { expect(response).to have_http_status 422 }
          end

          context 'bad request was sent' do
            before { process :update, method: :patch, params: { id: question_id, ' ': resource_params }, format: :json }

            it('returns HTTP Status Code 400') { expect(response).to have_http_status 400 }
          end
        end
      end

      context 'user did not pass authorization' do
        before { expect(subject).to receive(:authorize).and_raise Pundit::NotAuthorizedError }

        before { process :update, method: :patch, params: { id: question_id, question: resource_params }, format: :json }

        it('returns HTTP Status Code 403') { expect(response).to have_http_status 403 }
      end

      context 'question was not found' do
        before { expect(Question).to receive(:find).with('0').and_raise ActiveRecord::RecordNotFound }

        before { process :update, method: :patch, params: { id: 0, question: resource_params }, format: :json }

        it('returns HTTP Status Code 404') { expect(response).to have_http_status 404 }
      end
    end

    context 'user not authenticated' do
      before { process :update, method: :patch, params: { id: question_id, question: resource_params }, format: :json }

      it('returns HTTP Status Code 401') { expect(response).to have_http_status 401 }
    end
  end

  describe 'DELETE #destroy' do
    context 'user authenticated' do
      before { sign_in user }

      context 'question was found' do
        context 'user passes authorization' do
          before { allow(subject).to receive(:authorize).and_return true }

          before do
            expect(QuestionDestroyer).to receive(:new).with(question) do
              double.tap { |question_destroyer| expect(question_destroyer).to receive(:destroy) }
            end
          end

          before { process :destroy, method: :delete, params: { id: question_id }, format: :json }

          it('returns HTTP Status Code 204') { expect(response).to have_http_status 204 }
        end
      end

      context 'user did not pass authorization' do
        before { expect(subject).to receive(:authorize).and_raise Pundit::NotAuthorizedError }

        before { process :destroy, method: :delete, params: { id: question_id }, format: :json }

        it('returns HTTP Status Code 403') { expect(response).to have_http_status 403 }
      end

      context 'question was not found' do
        before { expect(Question).to receive(:find).with('0').and_raise ActiveRecord::RecordNotFound }

        before { process :destroy, method: :delete, params: {id: 0}, format: :json }

        it('returns HTTP Status Code 404') { expect(response).to have_http_status 404 }
      end
    end

    context 'user not authencticated' do
      before { process :destroy, method: :delete, params: { id: question_id }, format: :json }

      it('returns HTTP Status Code 401') { expect(response).to have_http_status 401 }
    end
  end

  describe 'GET #show' do
    context 'question was found' do
      before { process :show, method: :get, params: { id: question_id }, format: :json }

      it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }

      it('returns searched question') { expect(response.body).to eq question.to_json }
    end

    context 'question was not found' do
      before { expect(Question).to receive(:find).with('0').and_raise ActiveRecord::RecordNotFound }

      before { process :show, method: :get, params: {id: 0}, format: :json }

      it('returns HTTP Status Code 404') { expect(response).to have_http_status 404 }
    end
  end

  describe 'GET #index' do
    let(:params) { attributes_for(:question) }

    let(:collection) { double }

    before { allow(subject).to receive(:params).and_return(params) }

    before do
      allow(QuestionSearcher).to receive(:new).with(params) do
        double.tap { |question_searcher| allow(question_searcher).to receive(:search).and_return(collection) }
      end
    end

    before { process :index, method: :get, params: params, format: :json }

    it('returns collection') { expect(response.body).to eq collection.to_json }

    it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
  end
end
