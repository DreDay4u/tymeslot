defmodule Tymeslot.Infrastructure.SiteContentCache do
  @moduledoc """
  ETS cache for content pulled from the business's public website.

  The Armstrong instance surfaces the site's newest blog posts on the
  scheduler's meeting end pages (cancel, cancel-confirmed, reschedule), so a
  client who has just acted on a booking link has a path back to the
  business. The post list is read from the site's `llms.txt` — a
  build-time-static markdown index that lists every post with its absolute
  URL — and cached for six hours. A fetch or parse failure is never cached:
  the next page render retries, and the caller falls back to a static list.
  """

  use Tymeslot.Infrastructure.CacheStore,
    table_name: :site_content_cache,
    default_ttl: :timer.hours(6),
    cleanup_interval: :timer.minutes(30)

  require Logger

  alias Tymeslot.Infrastructure.HTTPClient

  @llms_url "https://armstrongtaxconsulting.com/llms.txt"

  # A blog line of the site's llms.txt: `- [title](absolute /blog/ URL)`
  # optionally followed by `: excerpt`. The URL character class is strict on
  # purpose: only slugs the site itself published ever match, so a
  # compromised mirror page cannot smuggle an off-site href into the link.
  @article_line ~r/- \[([^\]]+)\]\((https:\/\/armstrongtaxconsulting\.com\/blog\/[a-z0-9-]+)\)/

  # Shown while (or instead of) a live fetch; kept to the three posts that
  # were newest when this list was written.
  @fallback_articles [
    %{
      title: "2026 Tax Changes: What Dallas-Fort Worth Residents Need to Know",
      url: "https://armstrongtaxconsulting.com/blog/2026-tax-changes"
    },
    %{
      title: "1099 vs. W-2: What It Means for Your Taxes (2026 Guide)",
      url: "https://armstrongtaxconsulting.com/blog/1099-vs-w2"
    },
    %{
      title: "How Much Does a Tax Preparer Cost? How to Compare Fees",
      url: "https://armstrongtaxconsulting.com/blog/how-much-does-a-tax-preparer-cost"
    }
  ]

  @doc """
  The site's three newest blog posts, `%{title, url}` maps.

  Served from cache; on a fetch or parse failure the static fallback list is
  returned (with a warning logged) and nothing is memoised, so the next
  render retries.
  """
  @spec recent_articles() :: [%{required(:title) => String.t(), required(:url) => String.t()}]
  def recent_articles do
    case get_or_compute(:recent_articles, &fetch_articles/0, @default_ttl, cache_errors: false) do
      {:ok, articles} ->
        articles

      {:error, reason} ->
        Logger.warning(
          "SiteContentCache: llms.txt unavailable, serving static article list",
          reason: inspect(reason)
        )

        @fallback_articles
    end
  end

  defp fetch_articles do
    with {:ok, %{status: 200, body: body}} when is_binary(body) <- HTTPClient.get(@llms_url),
         [_ | _] = articles <- parse(body) do
      {:ok, Enum.take(articles, 3)}
    else
      {:ok, %{status: status}} -> {:error, {:unexpected_status, status}}
      {:error, reason} -> {:error, reason}
      [] -> {:error, :no_articles_parsed}
    end
  end

  defp parse(body) do
    @article_line
    |> Regex.scan(body, capture: :all_but_first)
    |> Enum.map(fn [title, url] -> %{title: String.trim(title), url: url} end)
  end
end
