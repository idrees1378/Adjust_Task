defmodule AdjustTask.Worker do

    @moduledoc """
        The worker module is a Genserver. It will run daily at 12:01 AM to get all the date 
        of the previous day. We are hitting day API because it will reduce our number of requests per day and
        besides the day API is giving us the same granularity.
        This module starts with a default state defined in state.ex
        %State{date: _, url: _, retries: _, status: _}
        When the app starts it search for a start date in configs, if there the start date is not 
        defined in configs it starts by fetching yesterday's data.
        If a start date is defined, the worker starts fetching data from start date to yesterday(
        We can also it concurrent by spawing multiple process because this is a concurrent operation).
        After the first launch, when the application fetches all the data till yesterday, it schedules
        itself to run again at 12:01 next day, to fetch today's data.
        Max retries can be configured from configuration but if its not configured, the default is 3.
        If a request failes max_retries() times, the request is saved to db with status "failed" and 
        the application moves to next date if there is any.
    """

    use GenServer
    alias AdjustTask.Utils
    alias AdjustTask.Worker.State
    alias AdjustTask.Postgres.PostgresUtils
    alias AdjustTask.Scylla.Intensities
    
    require Logger

    @default_retries 3

    def start_link(_default) do
        state = get_default_state()        
        GenServer.start_link(__MODULE__, state, name: __MODULE__)
    end

    @impl true
    def init(state) do
        Logger.info("#{__MODULE__} started.")
        
        {:ok, state, {:continue, :start}}
    end

    @impl true
    def handle_continue(:start, state) do
        {:noreply, process_req(state)}
    end

    @impl true
    def handle_info(:next_scheduled, state) do
        {:noreply, process_req(state)}
    end

    @impl true
    def terminate(reason, %State{} = state) do
        save_req_state(state)

        Logger.info("#{__MODULE__} is exiting. Reason: #{inspect reason}")
    end

    # Processes new request for a date and if applicable, fetches request data.

    # ##parameters
    
    # - state: state is a struct from state.ex 
    #     Date: whose data needs to be fetched from api.
    #     retries: the try no.
    #     url: api url.
    #     status: status of request.

    def process_req(%State{date: date, retries: retry_no, url: url} = state) do
        
        with :try <- req_should_try(retry_no), 
            true <- Utils.is_past_date(date),
            {:ok, :done} <- get_intensity(url, date) do
            state
            |> save_next_state
            |> process_req
       
        else
            :stop ->
                state = %{state | retries: retry_no, status: "failed"}
                save_req_state(state) # update previous state

                state = %{state | date: Utils.next_date(date), status: "processing", retries: 1}
                save_req_state(state) # insert new request state in db
                
                process_req(state)

            false -> 
                schedule()
                state

            _ ->
                state = %{state | retries: retry_no + 1}
                process_req(state)
        end
    end

    defp get_intensity(url, date) do
        Logger.info(fn-> "Getting intensities for date: #{inspect date}" end)        
        url = url <> Date.to_string(date)

        case HTTPoison.get(url) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                intensities =
                    body
                    |> Poison.decode!
                
                Intensities.save(date, intensities["data"])
                Logger.info(fn -> "Successfully fetched data for date: #{inspect date}" end)
                
                {:ok, :done}

            {:ok, %HTTPoison.Response{status_code: 404}} ->
                {:ok, :done}
            
            {:ok, %HTTPoison.Response{status_code: status_code}} ->
                Logger.info(fn-> "Succeeded with status code code: #{inspect status_code}" end)

                {:error, :failed}
            
            {:error, %HTTPoison.Response{status_code: status_code}} ->
                Logger.info(fn-> "Failed with status code: #{inspect status_code}" end)
                {:error, :failed}
        end
    end

    defp schedule() do
        now = DateTime.utc_now
        unix_now = DateTime.to_unix(now, :millisecond)
        next_day_start = 
            now
            |> Utils.next_day
            |> Utils.day_start
        
        Logger.info(fn -> "Scheduling next routine." end)

        # schedule at 12:01 AM Next day
        after_duration = next_day_start - unix_now + 60_000 
        Process.send_after(self(), :next_scheduled, after_duration)
    end

    #    This methods updates the currently process request with status and retries in database.
    #    It also create the next date in database. 
        
        ## parameters
    #    - state: current state of the process

    defp save_next_state(%State{date: date} = state) do
        # mark current state status as success and save next state
        state = %{state | status: "success"}
        save_req_state(state) # update previous request state
        
        state = %{state | date: Utils.next_date(date), status: "processing", retries: 1}
        save_req_state(state) # insert new request state in db

        state
    end

    defp save_req_state(%{date: date, retries: retries, status: status}) do
        PostgresUtils.create_or_update_req_meta(%{req_date: date, tries: retries, status: status})
    end
    
#        Checks from the database if there is any date entry, if yes, it means that the applicaiton
#        has previously been run and it will continue from there.
#        if there is no entry in db, it means the application is running for the first time, and it
#        checks configurations for start date. if there is no start date mentioned in configurations
#        it reads yesterday date and return default state.
 
    defp get_default_state() do
        last_req = PostgresUtils.get_last_req_meta() || %{}
        retries = Map.get(last_req, :tries) || 1
        date = 
            Map.get(last_req, :req_date)  || get_start_date_from_config() || Utils.previous_date(Date.utc_today)  
        
        %State{date: date, retries: retries}
    end

    defp get_start_date_from_config() do
        with <<_y::bytes-size(4)>> <> _ = date <- Application.get_env(:adjust_task, :start_date),
            {:ok, date} <- Date.from_iso8601(date) do
            date
        else
            _ -> nil
        end
    end

    defp req_should_try(tries) do
        if tries <= max_retries(), do: :try, else: :stop
    end

    defp max_retries() do
        Application.get_env(:adjust_task, :max_retries) || @default_retries
    end
end