require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  it { is_expected.to be_an ApplicationController }

  let(:resource_params) { attributes_for(:user) }

  let(:user) { instance_double(User, id: 1, as_json: resource_params, **resource_params) }

  describe 'POST #create' do
    let(:creator) { UserCreator.new(resource_params) }

    context 'new user was created' do
      before { allow(UserCreator).to receive(:new).and_return(creator) }

      before { expect(creator).to receive(:on).twice.and_call_original }

      before { broadcast_succeeded creator, user }

      before { process :create, method: :post, params: { user: resource_params }, format: :json }

      it('returns created user') { expect(response.body).to eq user.to_json }

      it('returns HTTP Status Code 201') { expect(response).to have_http_status 201 }
    end

    context 'invalid attributes were sent' do
      let(:errors) { instance_double(ActiveModel::Errors) }

      before { allow(UserCreator).to receive(:new).and_return(creator) }

      before { expect(creator).to receive(:on).twice.and_call_original }

      before { broadcast_failed creator, errors}

      before { process :create, method: :post, params: { user: resource_params }, format: :json }

      it('returns errors') { expect(response.body).to eq errors.to_json }

      it('returns HTTP Status Code 422') { expect(response).to have_http_status 422 }
    end

    context 'bad request was sent' do
      before { process :create, method: :post, params: { ' ': resource_params }, format: :json }

      it('returns HTTP Status Code 400') { expect(response).to have_http_status 400 }
    end
  end

  describe 'GET #confirm' do
    let(:user) { User.new }

    let(:payload) { { user_id: '1' } }

    context 'invalid token was sent' do
      let(:params) { { token: 'invalid_token' } }

      before { allow(SimpleStackoverflowToken).to receive(:decode).with(params[:token]).and_return(false) }

      before { process :confirm, method: :post, params: params, format: :json }

      it('returns header "WWW-Authenticate"') { expect(response.header['WWW-Authenticate']).to eq 'Token realm="Application"' }

      it('returns HTTP Status Code 401') { expect(response).to have_http_status 401 }
    end

    context 'valid token was sent' do
      let(:params) { { token: 'valid_token' } }

      before { allow(SimpleStackoverflowToken).to receive(:decode).with(params[:token]).and_return(payload) }

      before { allow(User).to receive(:find).with(payload['user_id']).and_return(user) }

      context 'user did not pass authorization' do
        before { expect(subject).to receive(:authorize).and_raise Pundit::NotAuthorizedError }

        before { process :confirm, method: :post, params: params, format: :json }

        it('returns HTTP Status Code 403') { expect(response).to have_http_status 403 }
      end

      context 'valid token was sent and user passed authorization' do
        before { allow(subject).to receive(:authorize).and_return(true) }

        before { expect(user).to receive(:confirmed!) }

        before { process :confirm, method: :post, params: params, format: :json }

        it('returns HTTP Status Code 200') { expect(response).to have_http_status 200 }
      end
    end
  end
end
