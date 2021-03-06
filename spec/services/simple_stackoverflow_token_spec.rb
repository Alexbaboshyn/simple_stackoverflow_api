require 'rails_helper'

RSpec.describe SimpleStackoverflowToken do
  let(:user) { FactoryBot.build_stubbed(:user) }

  let(:exp) { 1.day.from_now.to_i }

  let(:payload) { { user_id: user.id, exp: exp } }

  let(:token) { described_class.encode(payload) }

  describe '#decode' do
    context 'token is expired' do
      let(:exp) { 1.day.ago }

      it('returns false') { expect(described_class.decode(token)).to eq false }
    end

    context 'token is invalid' do
      let(:token) { 'invalid_token' }

      it('returns false') { expect(described_class.decode(token)).to eq false }
    end

    context 'token is valid' do
      it('decodes token') { expect(described_class.decode(token).first).to eq payload.stringify_keys }
    end
  end
end
