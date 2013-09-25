APP_PATH = "/rest/u/apps/shapado"

worker_processes (ENV['UNICORN_WORKERS'] || 2).to_i

working_directory APP_PATH + "/current"

listen (ENV['UNICORN_PORT'] || 3000).to_i, backlog: (ENV['UNICORN_BACKLOG'] || 100).to_i

timeout (ENV['UNICORN_TIMEOUT'] || 120).to_i

pid APP_PATH + "/shared/pids/unicorn.pid"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
  Redis.current.quit
end
