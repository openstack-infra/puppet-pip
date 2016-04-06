require 'puppet/provider/package'
require 'net/http'
require 'xmlrpc/client'
require 'puppet/util/http_proxy'

Puppet::Type.type(:package).provide(:openstack_pip, :parent => :pip) do

  desc "Python packages via `pip` with mirrors."

  def latest
    if File.exists?('/etc/pip.conf')
      conf = File.readlines('/etc/pip.conf')
      index_url = conf.select { |line| line =~ /^index-url/ }.first
      index_url = index_url.split('=')[1].strip if index_url
    end
    index_url = 'http://pypi.python.org/pypi/' unless index_url

    # If using a mirror
    unless index_url == 'http://pypi.python.org/pypi/'
      # Net::HTTP will automatically create a proxy from the http_proxy
      # environment variable so no need to set that up
      uri = URI(index_url)
      http = Net::HTTP.new(uri.host)
      http.open_timeout = 30
      http.read_timeout = 30
      result = http.get("/#{uri.path}/#{@resource[:name]}/").body

      # We don't want to have to pull in nokogiri to parse the HTML, but since
      # we know roughly what we'll be getting back just filter the links and
      # extract the text from that
      link_body_pattern = /<a href=.*>(.*?)<\/a>/
      extension_pattern = /(\.whl|\.tar\.gz|\.zip|\.exe)$/
      # Get the links with version numbers in them
      latest = result.split("<br/>").select{ |line|
        line =~ /a href=/ && line =~ /\d/
      }.map{ |line|
        # And get the body from the links
        line = line[link_body_pattern,1]
        # And extract the version number from the body
        line = line.gsub(extension_pattern,'').gsub(/^#{@resource[:name]}/, '').split('-')[1]
        # We don't need to compare the windows version, if that's what we needed
        # we sould already have installed it
        line.gsub(/\.win\d*/,'')
      }.max{ |a,b|
        Puppet::Util::Package.versioncmp(a,b)
      }
      return latest
    # Fall back to upstream behavior
    else
      super
    end
  rescue Timeout::Error => detail
    raise Puppet::Error, "Timeout while contacting #{URI(index_url).host}: #{detail}", detail.backtrace
  end

end
