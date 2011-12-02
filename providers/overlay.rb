action :create do
  url = new_resource.url ||
    if url.nil?
      node[:portage][:layman][:overlay_maps].find do |overlay|
       overlay[1].include? new_resource.name
      end[0]
    end


  # add repo if given
  layman_cfg "add #{new_resource.name}" do
    overlay url
  end
  node[:portage][:layman][:overlays] ||= []
  unless node[:portage][:layman][:overlays].include?(new_resource.name)
    script "add layman overlay #{new_resource.name}" do
      interpreter 'bash'
      code <<-EOS 
        if [ ! -d /var/lib/layman/#{new_resource.name} ]; then
          layman --fetch
          layman --add=#{new_resource.name}
        fi
      EOS
    end
    node[:portage][:layman][:overlays].push(new_resource.name).sort!.uniq!
    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  if node[:portage][:layman][:overlays].include?(new_resource.name)
    node[:portage][:layman][:overlays].delete(new_resource.name)
    script "add layman overlay #{new_resource.name}" do
      interpreter 'bash'
      code <<-EOS 
        layman --delete=#{new_resource.name}
      EOS
    end
    new_resource.updated_by_last_action(true)
  end
end
