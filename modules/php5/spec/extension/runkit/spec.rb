require 'spec_helper'

describe 'php5::extension::runkit' do

  describe command('php --ri runkit') do
    its(:exit_status) { should eq 0 }
  end

  describe file('/var/log/php/error.log') do
    its(:content) { should_not match /Warning.*runkit.*already loaded/ }
  end
end
