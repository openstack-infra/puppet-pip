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

    context 'when it can reach the mirror' do
      # This is where latest will be checked
      it 'should be idempotent' do
        apply_manifest(pp, catch_changes: true)
      end
    end

    context 'when it cannot reach the mirror' do
      it 'should raise a timeout error about the mirror' do
        awk_cmd = "awk '/^index-url/{ print \$3 }' /etc/pip.conf"
        mirror_url = shell(awk_cmd).stdout.strip
        mirror_addr = URI(mirror_url).host
        shell("iptables -A OUTPUT -d #{mirror_addr} -j DROP")
        timeout_msg = "Timeout while contacting #{mirror_addr}:"
        expect(apply_manifest(pp, catch_failures: false).stderr).to contain(timeout_msg)
      end
    end

  end

  context 'without mirrors' do

    before :all do
      shell("iptables -D OUTPUT -d pypi.python.org -j DROP")
      shell("rm /etc/pip.conf")
    end

    context 'when it can reach pypi.python.org' do
      it 'should be idempotent' do
        apply_manifest(pp, catch_changes: true)
      end
    end

    context 'when it cannot reach pypi.python.org' do
      it 'should raise a timeout error about pypi.python.org' do
        shell("iptables -A OUTPUT -d pypi.python.org -j DROP")
        timeout_msg = "Timeout while contacting pypi.python.org:"
        expect(apply_manifest(pp, catch_failures: false).stderr).to contain(timeout_msg)
      end
    end

  end

end
