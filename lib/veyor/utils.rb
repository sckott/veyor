def make_ua
	requa = 'Faraday/v' + Faraday::VERSION
  habua = 'Veyor/v' + Veyor::VERSION
  return requa + ' ' + habua
end

def prep_args(limit, start_build, branch)
	args = { recordsNumber: limit, startBuildId: start_build, branch: branch }
  opts = args.delete_if { |k, v| v.nil? }
  return opts
end

def get_account(x)
	if x.nil?
	  x = Veyor.account_name
	  if x.nil?
	  	raise 'could not find env var APPVEYOR_ACCOUNT_NAME; please set it'
	  end
	end
	return x
end

def prep_route(route, account, project, branch, version)
  if branch.nil? && version.nil?
    route = sprintf('%s/%s/%s', route, account, project)
  elsif !branch.nil? && version.nil?
    route = sprintf('%s/%s/%s/branch/%s', route, account, project, branch)
  elsif branch.nil? && !version.nil?
    route = sprintf('%s/%s/%s/build/%s', route, account, project, version)
  end
  return route
end


def check_provider(x)
  appveyor_providers = ["gitHub",
    "bitBucket",
    "vso",
    "gitLab",
    "kiln",
    "stash",
    "git",
    "mercurial",
    "subversion"]
  
  if appveyor_providers.include? x
    return x
  else
    raise 'provider must be one of: %s' % appveyor_providers.join(', ')
  end 
end
