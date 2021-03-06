#!/usr/bin/env ruby
#
# Check RabbitMQ messages
# ===
#
# Copyright 2012 Evan Hazlett <ejhazlett@gmail.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'socket'
require 'carrot-top'

class CheckRabbitMQMessages < Sensu::Plugin::Check::CLI

  option :host,
    :description => "RabbitMQ management API host",
    :long => "--host HOST",
    :default => "localhost"

  option :port,
    :description => "RabbitMQ management API port",
    :long => "--port PORT",
    :proc => proc {|p| p.to_i},
    :default => 55672

  option :user,
    :description => "RabbitMQ management API user",
    :long => "--user USER",
    :default => "guest"

  option :password,
    :description => "RabbitMQ management API password",
    :long => "--password PASSWORD",
    :default => "guest"

  option :warn,
    :short => '-w NUM_MESSAGES',
    :long => '--warn NUM_MESSAGES',
    :description => 'WARNING message count threshold',
    :default => 250

  option :critical,
    :short => '-c NUM_MESSAGES',
    :long => '--critical NUM_MESSAGES',
    :description => 'CRITICAL message count threshold',
    :default => 500

  def get_rabbitmq_info
    begin
      rabbitmq_info = CarrotTop.new(
        :host => config[:host],
        :port => config[:port],
        :user => config[:user],
        :password => config[:password]
      )
    rescue
      warning "could not get rabbitmq info"
    end
    rabbitmq_info
  end

  def run
    rabbitmq = get_rabbitmq_info
    overview = rabbitmq.overview
    if overview['queue_totals'].is_a?(Hash) then total = overview['queue_totals']['messages'] else total = 0 end
    message "#{total}"
    critical if total > config[:critical].to_i
    warning if total > config[:warn].to_i
    ok
  end

end
