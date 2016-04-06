require 'spec_helper_acceptance'

describe 'custom pip provider' do

  pp = File.read(File.join(File.dirname(__FILE__), 'fixtures/openstack_pip.pp'))

  context 'using mirrors' do

    before :all do
      # Set up pip.conf for testers playing at home
      pip_conf =<<EOF
[global]
timeout = 60
index-url = http://mirror.dfw.rax.openstack.org/pypi/simple
trusted-host = mirror.dfw.rax.openstack.org
extra-index-url = http://mirror.dfw.rax.openstack.org/wheel/ubuntu-14.04-x86_64
EOF
      shell("if [ ! -f /etc/pip.conf ] ; then echo '#{pip_conf}' > /etc/pip.conf ; fi")
      # Block pypi.python.org so we know the mirror is working
      shell("iptables -A OUTPUT -d pypi.python.org -j DROP")
    end


    it 'should work with no errors' do
      apply_manifest(pp, catch_failures: true)
    end

    # This is where latest will be checked
    it 'should be idempotent' do
      apply_manifest(pp, catch_changes: true)
    end

  end

  context 'without mirrors' do

    before :all do
      shell("iptables -D OUTPUT -d pypi.python.org -j DROP")
      shell("rm /etc/pip.conf")
    end

    it 'should be idempotent' do
      apply_manifest(pp, catch_changes: true)
    end

  end

end
