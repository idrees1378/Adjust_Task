import Config

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.

configs = Config.Reader.read!("/opt/adjust/task/configs_#{Mix.env()}.exs")

import_config "#{Mix.env()}.exs"