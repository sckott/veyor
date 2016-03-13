def make_ua
	requa = 'Faraday/v' + Faraday::VERSION
  habua = 'Veyor/v' + Veyor::VERSION
  return requa + ' ' + habua
end
