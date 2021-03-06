require 'rails_helper'

RSpec.describe QuestionCreator do
  it { is_expected.to be_a ServicesHandler }

  let(:params) { attributes_for(:question) }

  let(:question) { instance_double(Question, as_json: params, **params) }

  let(:errors) { instance_double(ActiveModel::Errors) }

  subject { QuestionCreator.new params }

  describe '#call' do
    before { allow(Question).to receive(:create).with(params).and_return(question) }

    context 'valid params were passed' do
      before { be_broadcasted_succeeded question }

      it('broadcasts created question') { expect { subject.call }.to_not raise_error }
    end

    context 'invalid params were passed' do
      before { allow(question).to receive(:errors).and_return(errors) }

      before { be_broadcasted_failed(question, errors) }

      it('broadcasts question.errors') { expect { subject.call }.to_not raise_error }
    end
  end
end
