require 'rack/static'
require_relative './app/app'

use Rack::Static,
    urls: ["/openapi.yaml", "/AUTHORS"],
    root: File.expand_path('.'),
    header_rules: [
      ['/AUTHORS', { 'Cache-Control' => 'public, max-age=86400' }], # 24 Hours
      ['/openapi.yaml', { 'Cache-Control' => 'no-store' }]
    ]

use Rack::Deflater

run App.new
