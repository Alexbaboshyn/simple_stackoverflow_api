require 'rails_helper'

RSpec.describe AnswerSerializer do
  subject { AnswerSerializer.new create(:answer) }

  let(:attributes) { subject.attributes.keys }

  it('returns necessary attributes for Answer') { expect(attributes).to eq %i[id body user_id] }
end
