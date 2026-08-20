# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_cash_on_delivery/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'ba_spree_cash_on_delivery'
  s.version     = SpreeCashOnDelivery::VERSION
  s.summary     = 'Payment Method Cash On Delivery (be agile fork)'
  s.required_ruby_version = '>= 3.0'

  s.author      = 'be agile Co., Ltd.'
  s.email       = 'develop@be-agile.jp'
  s.homepage    = 'https://github.com/be-agile/ba_spree_cash_on_delivery'
  s.licenses    = ['AGPL-3.0-or-later']

  # `git ls-files` を使わない: フォーク元やリネーム前の古いファイルが git 上に残っていると、
  # 削除漏れがあった場合にそれらも巻き込んでパッケージしてしまう(#1317 で実際に発生した不具合)。
  # 明示的な Dir[] にすることで、実際にディスク上にある現行ファイルだけをパッケージする。
  s.files        = Dir['LICENSE', 'README.md', 'Gemfile', 'app/**/*', 'config/**/*', 'lib/**/*', 'db/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree', '= 5.3.6'
  s.add_dependency 'spree_storefront', '= 5.3.6'
  s.add_dependency 'spree_admin', '= 5.3.6'
  s.add_dependency 'spree_extension', '= 0.1.0'
  s.add_dependency 'deface'

  s.add_development_dependency 'spree_dev_tools'
end
