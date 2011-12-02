define :portage_preserve_libs do
  include_recipe "portage"

  file "/etc/portage/preserve-libs.d/#{params[:name]}" do
    content "#{params[:paths].join("\n")}\n"
    owner "root"
    group "root"
    mode "0644"
  end
end
