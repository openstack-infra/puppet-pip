require 'puppet/provider/package'
require 'net/http'
require 'xmlrpc/client'
require 'puppet/util/http_proxy'

Puppet::Type.type(:package).provide(:openstack_pip, :parent => :pip) do

  desc "Python packages via `pip` with mirrors."

  has_feature :installable, :uninstallable, :upgradeable, :versionable

  commands :pip => 'pip'

  def self.outdated
    @outdated ||= pip(['list', '--outdated', '--format columns'])
  end

  def latest
    outdated = self.class.outdated
    if outdated =~ /#{@resource[:name]}/
      # Output looks like:
      # Package Version Latest Type
      # ------- ------- ------ -----
      # gear    0.12.0  0.13.0 wheel
      # pip     9.0.1   19.0.3 wheel
      latest = outdated.split("\n").select { |line|
        line =~ /#{@resource[:name]}/
      }.first.match("#{@resource[:name]}\s+[^\s]+\s+([^\s]+)")[1]
    else
      package_info = lazy_pip(['show', @resource[:name]])
      current = package_info.split("\n").select { |line|
        line =~ /^Version/
      }.first.split(': ')[1]
      latest = current
    end
    return latest
  end
end
