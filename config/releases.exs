import Config

config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true,
  backends: [{LoggerFileBackend, :logs}]

config :logger, :logs,
  format: "$date $time [$level] $message, $metadata\n",
  metadata: [:request_id, :user_id, :role, :pid, :application, :module, :function, :remote_ip],
  path: "/opt/adjust/task/logs/adjust_task.log",
  level: :debug