require_relative 'lib/emmett'
require 'benchmark/ips'

path = File.expand_path('./.travis.yml', __dir__)

Benchmark.ips do |x|
  x.report('mtime') { File.mtime(path) }
  x.report('stat') { File.stat(path).mtime }
  x.report('new') { File.new(path).mtime }
  x.report('open') { File.open(path).mtime }
  x.report('read') { File.read(path) }

  x.compare!
end