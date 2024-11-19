require_relative './app/app'
require 'rack/deflater'

run App.new
use Rack::Deflater
