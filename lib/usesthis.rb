$:.unshift(__dir__)

require 'rubygems'
require 'bundler/setup'

require 'dimples'
require 'oj'
require 'redis'

require 'usesthis/api'
require 'usesthis/site'
require 'usesthis/interview'
require 'usesthis/link'
require 'usesthis/ware'

Oj.default_options = {mode: :compat}
Tilt.register Tilt::RedcarpetTemplate, 'interview'