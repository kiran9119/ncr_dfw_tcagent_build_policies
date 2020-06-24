name 'ncr_dfw_tcagent_server51'

default_source :supermarket, 'https://supermarket.hospitality.ncr.com'

cookbook 'ncr_dfw_tcagent_build'

run_list %w(
  ncr_appops::default
  ncr_dcops::default
  ncr_dfw_tcagent_build::default
  ncr_dfw_tcagent_build::vs2019
)
instance_eval(IO.read('./attributes/ncr_appops.rb'))
instance_eval(IO.read('./attributes/ncr_dcops.rb'))
