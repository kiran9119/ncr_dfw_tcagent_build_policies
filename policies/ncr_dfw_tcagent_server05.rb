name 'ncr_dfw_tcagent_server05'

default_source :supermarket, 'https://supermarket.hospitality.ncr.com'

cookbook 'ncr_dfw_tcagent_build'

run_list %w(
  ncr_dfw_tcagent_build::default
)
