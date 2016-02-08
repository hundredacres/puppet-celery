require 'spec_helper'
describe 'celery' do

  context 'with defaults for all parameters' do
    it { should contain_class('celery') }
  end
end
