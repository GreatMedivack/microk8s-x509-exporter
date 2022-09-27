require 'sinatra'
require 'socket'
require 'prometheus/client'
require 'prometheus/middleware/exporter'
require "rufus-scheduler"

ENV["NODE_NAME"] ||= "localhost"
CERTS_PATH = "./certs/"
CERTS_LIST = [ 
              "ca.crt",
              "front-proxy-ca.crt", 
              "front-proxy-client.crt", 
              "server.crt"
             ]

use Prometheus::Middleware::Exporter

scheduler = Rufus::Scheduler.new

prometheus = Prometheus::Client.registry
ssl_expire_gauge = prometheus.gauge(:microk8s_ssl_expire_time_seconds,
                                    docstring: 'Number of seconds since 1970 to the SSL Certificate expire.',
                                    labels: [:nodename,:certificate])


scheduler.every '1m' do
  collect_microk8s_ssl_expire_time_seconds(ssl_expire_gauge)
end

not_found do
  "Not The Droid You're Looking For"
end

def collect_microk8s_ssl_expire_time_seconds(metric)
  array = []
  CERTS_LIST.each do |cert|
    raw = File.read("#{CERTS_PATH}/#{cert}")
    certificate = OpenSSL::X509::Certificate.new(raw)
    metric.set(certificate.not_after.to_f, labels: { nodename: ENV["NODE_NAME"], certificate: cert})
  end
end


