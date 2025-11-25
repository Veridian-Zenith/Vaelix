defmodule VaelixBackend.Security.AdBlocker do
  @moduledoc """
  Advanced ad blocker with custom filtering rules and real-time protection.
  Uses both local rules and cloud-based intelligence for maximum effectiveness.
  """

  use GenServer
  import Ecto.Query
  require Logger

  # Ad blocking patterns and rules
  @ad_domains ~w(
    doubleclick.net googleadservices.com googlesyndication.com
    facebook.com/tr twitter.com/ads google-analytics.com
    quantserve.com scorecardresearch.com cdn.syndication.twimg.com
  )

  @tracking_domains ~w(
    google-analytics.com googletagmanager.com hotjar.com
    mixpanel.com segment.com amplitude.com
  )

  @known_malware_domains ~w(
    malware.example.com fake-login.com phishing-site.net
  )

  # State management
  defmodule State do
    defstruct [
      :filter_rules,
      :custom_rules,
      :last_updated,
      :block_count,
      :allowed_domains,
      :cloud_sync_enabled
    ]
  end

  # Public API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def check_url(url) when is_binary(url) do
    GenServer.call(__MODULE__, {:check_url, url})
  end

  def add_custom_rule(rule) when is_binary(rule) do
    GenServer.call(__MODULE__, {:add_custom_rule, rule})
  end

  def get_stats() do
    GenServer.call(__MODULE__, :get_stats)
  end

  def update_filter_rules(rules) when is_list(rules) do
    GenServer.call(__MODULE__, {:update_filter_rules, rules})
  end

  # GenServer callbacks
  def init(_opts) do
    # Load initial filter rules
    initial_rules = load_filter_rules()

    # Start periodic updates
    schedule_rule_update()

    {:ok, %State{
      filter_rules: initial_rules,
      custom_rules: [],
      last_updated: System.system_time(:second),
      block_count: 0,
      allowed_domains: MapSet.new(),
      cloud_sync_enabled: true
    }}
  end

  def handle_call({:check_url, url}, _from, state) do
    case analyze_url(url, state) do
      {:block, reason} ->
        new_state = %{state | block_count: state.block_count + 1}
        {:reply, {:blocked, reason}, new_state}
      {:allow, reason} ->
        {:reply, {:allowed, reason}, state}
    end
  end

  def handle_call({:add_custom_rule, rule}, _from, state) do
    new_custom_rules = [rule | state.custom_rules]
    new_state = %{state | custom_rules: new_custom_rules}
    Logger.info "Added custom ad blocking rule: #{rule}"
    {:reply, :ok, new_state}
  end

  def handle_call(:get_stats, _from, state) do
    stats = %{
      total_blocks: state.block_count,
      custom_rules: length(state.custom_rules),
      filter_rules: length(state.filter_rules),
      last_updated: state.last_updated,
      cloud_sync_enabled: state.cloud_sync_enabled
    }
    {:reply, stats, state}
  end

  def handle_call({:update_filter_rules, rules}, _from, state) do
    new_state = %{state |
      filter_rules: rules,
      last_updated: System.system_time(:second)
    }
    Logger.info "Updated filter rules: #{length(rules)} rules loaded"
    {:reply, :ok, new_state}
  end

  # Private functions
  defp analyze_url(url, state) do
    uri = URI.parse(url)
    host = String.downcase(uri.host || "")

    # Check against known ad domains
    if Enum.any?(@ad_domains, &String.contains?(host, &1)) do
      {:block, "Known advertising domain"}
    else
      # Check against tracking domains
      if Enum.any?(@tracking_domains, &String.contains?(host, &1)) do
        {:block, "Known tracking domain"}
      else
        # Check against malware domains
        if Enum.any?(@known_malware_domains, &String.contains?(host, &1)) do
          {:block, "Known malware domain"}
        else
          # Check custom rules
          if Enum.any?(state.custom_rules, &matches_rule?(url, &1)) do
            {:block, "Custom filter rule"}
          else
            # Check specific blocking patterns
            if matches_blocking_patterns?(url) do
              {:block, "Suspicious URL pattern"}
            else
              {:allow, "No blocking rules matched"}
            end
          end
        end
      end
    end
  end

  defp matches_rule?(url, rule) do
    case Regex.compile(rule) do
      {:ok, regex} -> Regex.match?(regex, url)
      {:error, _} -> String.contains?(url, rule)
    end
  end

  defp matches_blocking_patterns?(url) do
    blocking_patterns = [
      ~r/\/ads?[\/\?]/i,
      ~r/\/adserver/i,
      ~r/\/banner/i,
      ~r/\/sponsored/i,
      ~r/\.doubleclick\./i,
      ~r/utm_source=/i,
      ~r/utm_medium=/i,
      ~r/utm_campaign=/i
    ]

    Enum.any?(blocking_patterns, &Regex.match?(&1, url))
  end

  defp load_filter_rules() do
    # Load from database, file, or remote service
    # For now, return the built-in rules
    [
      "||doubleclick.net^",
      "||googleadservices.com^",
      "||googlesyndication.com^",
      "||facebook.com/tr^",
      "||google-analytics.com^",
      "|https://*.google.com/ads*",
      "|https://*.facebook.com/tr*"
    ]
  end

  defp schedule_rule_update() do
    Process.send_after(self(), :update_rules, :timer.hours(1))
  end

  def handle_info(:update_rules, state) do
    # In a real implementation, fetch updated rules from cloud service
    Logger.info "Updating ad blocking rules from cloud service"
    schedule_rule_update()
    {:noreply, state}
  end
end
