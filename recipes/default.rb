link "/etc/make.profile" do
  to node[:portage][:profile]
end

directory node[:portage][:distdir] do
  owner "root"
  group "portage"
end

directory node[:portage][:confdir] do
  owner "root"
  group "root"
  mode "0755"
  not_if { File.directory?(node[:portage][:confdir]) }
end

cookbook_file "#{node[:portage][:confdir]}/bashrc" do
  source "bashrc"
  owner "root"
  group "root"
  mode "0644"
end

%w(keywords mask unmask use).each do |type|
  path = "#{node[:portage][:confdir]}/package.#{type}"

  ruby_block "backup-package.#{type}" do
    block { FileUtils.mv(path, "#{path}.bak") }
    only_if { File.file?(path) }
  end

  directory path do
    owner "root"
    group "root"
    mode "0755"
    not_if { File.directory?(path) }
  end

  ruby_block "restore-package.#{type}" do
    block { FileUtils.mv("#{path}.bak", "#{path}/local") }
    only_if { File.file?("#{path}.bak") }
  end
end

directory "#{node[:portage][:confdir]}/preserve-libs.d" do
  owner "root"
  group "root"
  mode "0755"
end

directory "#{node[:portage][:make_conf]}.d" do
  owner "root"
  group "root"
  mode "0755"
  not_if { File.directory?("#{node[:portage][:make_conf]}.d") }
end

template "#{node[:portage][:make_conf]}.d/local.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "make.conf.local"
  backup 0
end

template node[:portage][:make_conf] do
  owner "root"
  group "root"
  mode "0644"
  source "make.conf"
  cookbook "portage"
  variables({:sources => []})
  backup 0
end

package "sys-apps/portage"

# resync portage
e = execute "emerge --sync" do
  action :nothing
end
e.run_action(:run)


%w(autounmask eix elogv gentoolkit portage-utils).each do |pkg|
  package "app-portage/#{pkg}"
end

execute "eix-update" do
  not_if do
    check_files = Dir.glob("/var/lib/layman/*/.git/index")
    check_files << "/usr/portage/.git/index"
    FileUtils.uptodate?("/var/cache/eix", check_files)
  end
end

cookbook_file "/etc/logrotate.d/portage" do
  source "portage.logrotate"
  mode "0644"
  backup 0
end

cookbook_file "/etc/dispatch-conf.conf" do
  source "dispatch-conf.conf"
  mode "0644"
  backup 0
end

%w(
  cruft
  fake-preserved-libs
  remerge
  update-preserved-libs
  updateworld
).each do |f|
  cookbook_file "/usr/local/sbin/#{f}" do
    source "scripts/#{f}"
    owner "root"
    group "root"
    mode "0755"
  end
end

%w(
  fake-world
  fake-vardb
).each do |f|
  file "/usr/local/sbin/#{f}" do
    action :delete
  end
end
