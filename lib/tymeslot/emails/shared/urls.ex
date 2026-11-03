defmodule Tymeslot.Emails.Shared.Urls do
  @moduledoc """
  App URL building helpers for Tymeslot emails.
  """

  alias Tymeslot.Utils.UrlBuilder
  alias TymeslotWeb.Endpoint

  # Armstrong deployment patch (armstrong-1): brand links in outgoing email
  # (logo header, footer wordmark) must take clients to the business site,
  # never to this scheduler's root, which serves the staff login. Functional
  # links (reschedule, cancel, calendar) keep using get_app_url()/1 below.
  @business_site_url "https://armstrongtaxconsulting.com"

  @doc """
  Gets the application URL from configuration.
  """
  @spec get_app_url() :: String.t()
  def get_app_url do
    Endpoint.url()
  end

  @doc """
  The public business website — the target for brand links in email.
  """
  @spec get_site_url() :: String.t()
  def get_site_url do
    @business_site_url
  end

  @doc """
  Builds a full URL for a given path, adding the leading slash when the caller
  omitted it.

  Delegates to `Tymeslot.Utils.UrlBuilder.build_url/1` so email links and the
  rest of the application cannot drift apart on how a path is joined to the
  base URL.
  """
  @spec build_url(String.t()) :: String.t()
  defdelegate build_url(path), to: UrlBuilder
end
