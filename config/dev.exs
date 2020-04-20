import Config

config :logger, :console,
  format: "$date $time [$level] $message $metadata\n",
  metadata: [:error_code, :file]