# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'ba_spree_cash_on_delivery'
  s.version     =  '4.0.1'
  s.summary     = 'Payment Method Cash On Delivery (Be-Agile fork)'
  s.description = 'Payment Method Cash On Delivery supporting Ruby 3.1, Rails 7.1 and Spree 4.10'
  s.author      = 'be agile Co., Ltd.'
  s.email       = 'develop@be-agile.jp'
  s.homepage    = 'https://github.com/be-agile/ba_spree_cash_on_delivery'
  s.required_ruby_version = '>= 3.1.4'
  s.licenses    = ['AGPL-3.0-or-later', 'BSD-3-Clause']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core'
end
