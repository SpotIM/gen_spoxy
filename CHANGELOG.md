## Changelog

## v0.0.14-beta.3
`GenCache` - adding a new method: `get_and_trigger_async_fetch`
this method lookups the cache and returns immediately.

in case there's a cache miss or stale data
it enqueues a refresh task in the backgrund before returning

## v0.0.14-beta.2
prerender periodic tasks executor optimization

## v0.0.14-beta.1
* renaming `Constants` to `Defaults`
* changing the defaults to suit most applications out-of-the-box
* `GenSpoxy.Cache` and `GenSpoxy.Prerender` expect configuations override under `config`

for example:
```elixir
  defmodule SamplePrerender do
    use GenSpoxy.Prerender,
        config: [prerender_timeout: 3000]

    @impl true
    def do_req(req) do
      # slow calculation of `req`
    end

    @impl true
    def calc_req_key(req) do
      Enum.join(req, "-")
    end
  end

  defmodule SampleCache do
    use GenSpoxy.Cache,
      store_module: Ets,
      prerender_module: SamplePrerender,
      config: [periodic_sampling_interval: 100]
  end
```

* `GenSpoxy.Prerender` settings are:
  * `prerender_timeout`           (defaults to `Defaults.prerender_timeout()`)
  * `prerender_total_partitions`  (defaults to `Defaults.total_partitions()`)
  * `prerender_sampling_interval` (defaults to `Defaults.prerender_sampling_interval()`)

* `GenSpoxy.Cache` settings for its underlying `TasksExecutor` are:
  * `periodic_sampling_interval`  (defaults to `Defaults.periodic_sampling_interval()`)
  * `periodic_total_partitions    (defaults to `Defaults.total_partitions()`)


## v0.0.12
first release
