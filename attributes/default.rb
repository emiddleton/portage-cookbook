case node.platform
when "gentoo"
  # paths & directories
  set[:portage][:make_conf] = "/etc/make.conf"
  set[:portage][:confdir] = "/etc/portage"
  set[:portage][:portdir] = "/usr/portage"
  set[:portage][:distdir] = "#{set[:portage][:portdir]}/distfiles"
  set[:portage][:pkgdir] = "#{set[:portage][:portdir]}/packages/${ARCH}"

  case node.kernel.machine
  when 'x86_64'
    default[:portage][:profile] = "#{set[:portage][:portdir]}/profiles/default/linux/amd64/10.0"
    default[:portage][:CFLAGS] = "-O2 -pipe"
    default[:portage][:CXXFLAGS] = "${CFLAGS}"
  when 'i686'
    default[:portage][:profile] = "#{set[:portage][:portdir]}/profiles/default/linux/x86/10.0"
    if node.has_key?("ec2")
      default[:portage][:CFLAGS] = "-O2 -pipe -march=i686 -mno-tls-direct-seg-refs"
    else
      default[:portage][:CFLAGS] = "-O2 -pipe -march=i686"
    end
    default[:portage][:CXXFLAGS] = "${CFLAGS}"
  else
    raise "Unknown architecture"
  end

  # build-time flags
  default[:portage][:USE] = []

  # advanced masking
  default[:portage][:ACCEPT_KEYWORDS] = nil

  # advanced features
  default[:portage][:OPTS] = []
  default[:portage][:MAKEOPTS] = "-j#{node.cpu.total.to_i+1}"

  # language support
  default[:portage][:LINGUAS] = %w(en)
  default[:portage][:MIRRORS] = []
  default[:portage][:BINHOST] = []
when 'centos'
  Chef::Log.info "not supported but don't fail"
else
  raise "This cookbook is Gentoo-only"
end
