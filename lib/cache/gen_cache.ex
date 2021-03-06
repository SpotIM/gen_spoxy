defmodule GenSpoxy.Cache do
  @moduledoc """
  This behaviour is responsible for implementing a caching layer on top of the prerender
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      alias Spoxy.Cache
      alias GenSpoxy.Stores.Ets

      @behaviour Spoxy.Cache.Behaviour

      @store_module Keyword.get(opts, :store_module, Ets)
      @prerender_module Keyword.get(opts, :prerender_module)

      cache_module = __MODULE__
      tasks_executor_mod = String.to_atom("#{cache_module}.TasksExecutor")

      @tasks_executor_mod tasks_executor_mod

      config = Keyword.get(opts, :config, [])
      executor_opts = Keyword.merge(config, cache_module: __MODULE__)

      defmodule @tasks_executor_mod do
        use GenSpoxy.Prerender.PeriodicTasksExecutor, executor_opts
      end

      tasks_executor_sup_mod = String.to_atom("#{tasks_executor_mod}.Supervisor")

      defmodule tasks_executor_sup_mod do
        use GenSpoxy.Prerender.Supervisor, supervised_module: tasks_executor_mod
      end

      def async_get_or_fetch(req, opts \\ []) do
        req_key = calc_req_key(req)
        mods = {@prerender_module, @store_module, @tasks_executor_mod}

        Cache.async_get_or_fetch(mods, req, req_key, opts)
      end

      def get_or_fetch(req, opts \\ []) do
        req_key = calc_req_key(req)
        mods = {@prerender_module, @store_module, @tasks_executor_mod}

        Cache.get_or_fetch(mods, req, req_key, opts)
      end

      @doc """
      receives a request `req`, determines it's signature (a.k.a `req_key`),
      then it fetches the local cache. it returns `nil` in case there is nothing in cache

      if the cache is empty or the data is stale a background fetch task is issued
      """
      def get_and_trigger_async_fetch(req, opts \\ []) do
        req_key = calc_req_key(req)
        mods = {@prerender_module, @store_module, @tasks_executor_mod}

        Cache.get_and_trigger_async_fetch(mods, req, req_key, opts)
      end

      @doc """
      receives a request `req`, determines it's signature (a.k.a `req_key`),
      then it fetches the local cache. it returns `nil` in case there is nothing in cache,
      else returns the cached entry
      """
      def get(req, opts \\ []) do
        req_key = calc_req_key(req)
        Cache.get(@store_module, req_key, opts)
      end

      def refresh_req!(req, opts) do
        req_key = calc_req_key(req)
        mods = {@prerender_module, @store_module}
        Cache.refresh_req!(mods, req, req_key, opts)
      end

      def await(task) do
        {:ok, resp, total} = Task.await(task)
      end

      def do_req(req) do
        Cache.do_req(@prerender_module, req)
      end

      def store_req!(opts) do
        Cache.store_req!(@store_module, opts)
      end

      def lookup_req(table_name, req_key) do
        Cache.lookup_req(@store_module, table_name, req_key)
      end

      @impl true
      def should_invalidate?(req, resp, metadata) do
        Cache.should_invalidate?(req, resp, metadata)
      end

      # defoverridable [should_invalidate?: 3]

      defp calc_req_key(req) do
        apply(@prerender_module, :calc_req_key, [req])
      end
    end
  end
end
