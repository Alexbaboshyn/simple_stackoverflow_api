require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  it('authenticate and set user') { is_expected.to be_kind_of(Authenticatable) }

  it('authorize user') { is_expected.to be_kind_of(Pundit) }
end
