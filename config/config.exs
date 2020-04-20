import Config

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.

configs = Config.Reader.read!("/opt/adjust/task/configs_#{Mix.env()}.exs")

config :adjust_task,
  api_url: "https://api.carbonintensity.org.uk/intensity/date/",
  start_date: "2020-04-11",
  max_retries: 3

import_config "#{Mix.env()}.exs"