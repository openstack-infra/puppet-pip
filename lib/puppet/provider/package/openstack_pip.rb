require 'puppet/provider/package'
require 'net/http'
require 'xmlrpc/client'
require 'puppet/util/http_proxy'

Puppet::Type.type(:package).provide(:openstack_pip, :parent => :pip) do

  desc "Python packages via `pip` with mirrors."

  def latest
    outdated = lazy_pip ['list', '--outdated']
    if outdated =~ /#{@resource[:name]}/
      latest = outdated.split('-')[1].match('Latest: (.*) ')[1]
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
