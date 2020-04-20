# AdjustTask

# Installation
This project is built on: 
- Elixir 1.9.0 (Erlang/OTP 22.0.3) 
- Scylla 3.3.0
- Postgresql 12.2

Before running this project:

1:- copy config/configs_dev.example, rename it as configs_dev.exs and configure for each enviorement and place all these files at "/opt/adjust/task/" of your system. the app reads the file as "/opt/adjust/task/configs_#{Mix.env()}.exs"

2:- For production and staging enviroment, create a folder "/opt/adjust/task/logs/" for application logs.

3:- install dependencies by running mix deps.get
4:- mix ecto.migrate to run postgres migrations
5:- connect to cqlsh command line
    a:- use {scylla database name}
    b: source this file: SOURCE './priv/1587276040_create_corbon_intensities.cql'

6:- finally you can run directly or make a release with "mix release"


