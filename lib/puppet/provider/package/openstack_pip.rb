require 'puppet/provider/package'
require 'net/http'
require 'xmlrpc/client'
require 'puppet/util/http_proxy'

Puppet::Type.type(:package).provide(:openstack_pip, :parent => :pip) do

  desc "Python packages via `pip` with mirrors."

  def latest
    outdated = lazy_pip "list" "--outdated"
    if outdated =~ @resource[:name]
      latest = outdated.split('-')[1].match('Latest: (.*) ')[1]
    end
  end
end
