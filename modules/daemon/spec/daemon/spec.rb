require 'spec_helper'

describe 'daemon' do

  describe service('my-program') do
    it { should be_enabled }
    it { should be_running }
  end

  describe process('my-program') do
    its(:user) { should eq 'alice' }
    its(:args) { should match /--foo=12/ }
    it { should be_running }
  end

  describe command('ps --no-headers -o nice -p $(pgrep -f "^/bin/bash /tmp/my-program")') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /19/ }
  end

  describe command('cat /proc/$(pgrep -f "^/bin/bash /tmp/my-program")/oom_score_adj') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /-500/ }
  end

end
