# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ip_library/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["tumayun"]
  gem.email         = ["tumayun.2010@gmail.com"]
  gem.description   = <<-DESCRIPT
IPLibrary
=========

顾名思义，这是一个ip库

Example
=======

本gem中已经带有ip库，默认是gem目录下doc/ip_libraries.txt
默认ip库的格式以IPLibrary::Configuration.separator分组
各组第一行为ip头（192.168.1.1的ip头为192）,其他行各列以英文逗号隔开
各列分别是：起始ip, 结束ip, 省份, 城市, 县区, 行政划分最小字段的拼音(如果有县区则为县区的拼音)

当然，您也可以有自己的ip库
设置ip库的path: IPLibrary::Configuration.file_path = '/home/doc/ip_libraries.txt'
而且，您也可以设置ip库中的列的含义，start_ip、end_ip两列必须有，且必须依次为1、2列
设置其他列：IPLibrary::Configuration.optional_columns = [:province, :city, :district, :pinyin]
除了1、2列，其他列一次为province、city、district、pinyin
然后会动态生成方法：
IPLibrary::Base#ip2province
IPLibrary::Base#ip2city
IPLibrary::Base#ip2district
IPLibrary::Base#ip2pinyin

=============================================

IPLibrary::Base 的方法有：

IPLibrary::Base.ip2province('123.132.254.134')
IPLibrary::Base.ip2province(2072313478)
#=> "山东"

IPLibrary::Base.ip2city('123.132.254.134')
IPLibrary::Base.ip2city(2072313478)
#=> "临沂"

IPLibrary::Base.ip2district('123.132.254.134')
IPLibrary::Base.ip2district(2072313478)
# => ""

IPLibrary::Base.ip2pinyin('123.132.254.134')
IPLibrary::Base.ip2pinyin(2072313478)
#=> "linyi"
  DESCRIPT
  gem.summary       = %q{IPLibrary是一个ip库的gem，它能通过类似ip2city等方法得到ip所在城市}
  gem.homepage      = ""

  #gem.files         = `git ls-files`.split($\)
  gem.files         = %w(Gemfile ip_library.gemspec LICENSE Rakefile README.md)
  gem.files        += Dir.glob("lib/**/*")
  gem.files        += Dir.glob("doc/**/*")
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ip_library"
  gem.require_paths = ["lib"]
  gem.version       = IPLibrary::VERSION
end
