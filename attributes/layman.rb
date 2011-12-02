default[:portage][:layman][:urls] = []
default[:portage][:layman][:overlay_maps] = Mash.new({
  'http://www.gentoo.org/proj/en/overlays/repositories.xml' => [
  ],
  'https://raw.github.com/emiddleton/chef-gentoo-bootstrap-overlay/master/overlays.xml' => [
    'chef-gentoo-bootstrap-overlay'
  ]
})
