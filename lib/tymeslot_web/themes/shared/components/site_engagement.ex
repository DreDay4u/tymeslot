defmodule TymeslotWeb.Themes.Shared.Components.SiteEngagement do
  @moduledoc """
  Armstrong engagement sections for the public meeting pages (cancel,
  cancel-confirmed, reschedule): a slim site header linking back to
  armstrongtaxconsulting.com, a "keep exploring" footer with the site's
  newest blog posts, and a CSS-only news ticker. The scheduler's meeting
  pages are otherwise dead ends; these give a client who has just acted on
  a booking link a path back to the business.

  `header_bar/1` carries the shared stylesheet for all three sections, so
  render it on any page that also renders the footer or ticker — the
  meeting pages always render the three together. Copy is plain English on
  purpose: this is single-business branding content, not translatable app
  UI.
  """

  use Phoenix.Component

  alias Tymeslot.Infrastructure.SiteContentCache

  @site_url "https://armstrongtaxconsulting.com"
  @phone_display "(469) 353-9934"
  @phone_href "tel:+14693539934"

  @nav [
    {"Services", "/services"},
    {"Pricing", "/pricing-process"},
    {"Blog", "/blog"},
    {"Tax News", "/resources/tax-news"},
    {"Contact", "/contact"}
  ]

  @doc """
  Slim full-width site header: navy band with the gold wordmark linking to
  the business site and the site's main nav. Renders the shared `<style>`
  for every `atc-*` section.
  """
  @spec header_bar(map()) :: Phoenix.LiveView.Rendered.t()
  def header_bar(assigns) do
    ~H"""
    <style type="text/css" phx-no-format><%= Phoenix.HTML.raw(engagement_css()) %></style>
    <nav class="atc-header" aria-label="ArmStrong Tax and Consulting">
      <a class="atc-header__wordmark" href={site_url()}>
        ArmStrong <span class="atc-header__amp">Tax &amp; Consulting</span>
      </a>
      <div class="atc-header__nav">
        <a :for={{label, path} <- nav_links()} class="atc-header__link" href={site_url() <> path}>
          {label}
        </a>
      </div>
    </nav>
    """
  end

  attr :booking_path, :string,
    default: "/",
    doc: "the organiser's booking page; carries the reschedule uid when the caller passes it"

  @doc """
  The bottom engagement section: the site's three newest articles, a CTA
  row back to the booking page and the business site, and the phone number.
  """
  @spec engagement_footer(map()) :: Phoenix.LiveView.Rendered.t()
  def engagement_footer(assigns) do
    assigns = assign(assigns, :articles, SiteContentCache.recent_articles())

    ~H"""
    <section class="atc-footer" aria-label="Keep exploring ArmStrong Tax and Consulting">
      <p class="atc-footer__eyebrow">While you're here</p>
      <h2 class="atc-footer__title">Latest from ArmStrong Tax &amp; Consulting</h2>
      <ul class="atc-footer__articles">
        <li :for={article <- @articles}>
          <a class="atc-footer__article" href={article.url} target="_blank" rel="noopener">
            {article.title}
            <span class="atc-footer__arrow" aria-hidden="true">&#8594;</span>
          </a>
        </li>
      </ul>
      <div class="atc-footer__actions">
        <a class="atc-btn atc-btn--gold" href={@booking_path}>Book a new time</a>
        <a class="atc-btn atc-btn--navy" href={site_url()}>Visit our website</a>
      </div>
      <p class="atc-footer__phone">
        Prefer to talk? <a href={phone_href()}>{phone_display()}</a>
      </p>
    </section>
    """
  end

  @doc """
  A CSS-only scrolling band of the newest article titles — pure motion and
  color, no scripts (public pages run under a strict CSP). Pauses on hover
  and under `prefers-reduced-motion`.
  """
  @spec news_ticker(map()) :: Phoenix.LiveView.Rendered.t()
  def news_ticker(assigns) do
    assigns = assign(assigns, :articles, SiteContentCache.recent_articles())

    ~H"""
    <div class="atc-ticker" aria-label="Latest articles">
      <span class="atc-ticker__label">Tax News</span>
      <div class="atc-ticker__viewport">
        <div class="atc-ticker__track">
          {ticker_items(@articles)}
          <div class="atc-ticker__group" aria-hidden="true">{ticker_items(@articles)}</div>
        </div>
      </div>
    </div>
    """
  end

  defp ticker_items(articles) do
    assigns = %{articles: articles}

    ~H"""
    <span :for={article <- @articles} class="atc-ticker__item">
      <a href={article.url} target="_blank" rel="noopener">{article.title}</a>
      <span class="atc-ticker__dot" aria-hidden="true">&#9670;</span>
    </span>
    """
  end

  # Module attributes are not reachable from HEEX (`@x` reads assigns
  # there), so each has a private reader used inside the templates.
  defp site_url, do: @site_url
  defp phone_display, do: @phone_display
  defp phone_href, do: @phone_href
  defp nav_links, do: @nav

  defp engagement_css do
    """
    .atc-header{display:flex;flex-wrap:wrap;align-items:center;justify-content:space-between;gap:6px 20px;background:#0a1f3c;padding:10px 18px;font-size:13.5px}
    .atc-header__wordmark{color:#f0e6d0;font-weight:800;letter-spacing:.01em;text-decoration:none;font-size:15px}
    .atc-header__wordmark .atc-header__amp{color:#b8923a}
    .atc-header__nav{display:flex;flex-wrap:wrap;gap:2px 16px}
    .atc-header__link{color:#f0e6d0;opacity:.85;text-decoration:none}
    .atc-header__link:hover{opacity:1;text-decoration:underline}
    .atc-footer{margin-top:28px;padding:18px 2px 4px;border-top:1px solid rgba(10,31,60,.14)}
    .atc-footer__eyebrow{margin:0 0 2px;color:#b8923a;font-size:11.5px;font-weight:700;letter-spacing:.14em;text-transform:uppercase}
    .atc-footer__title{margin:0 0 12px;color:#0a1f3c;font-size:17px;font-weight:800}
    .atc-footer__articles{list-style:none;margin:0 0 14px;padding:0;display:grid;gap:6px}
    .atc-footer__article{display:flex;justify-content:space-between;align-items:baseline;gap:10px;color:#1b3556;text-decoration:none;font-size:14px;font-weight:600;line-height:1.45}
    .atc-footer__article:hover{text-decoration:underline;color:#0a1f3c}
    .atc-footer__arrow{flex:none;color:#b8923a}
    .atc-footer__actions{display:flex;flex-wrap:wrap;gap:10px;margin:0 0 10px}
    .atc-btn{display:inline-block;padding:9px 16px;border-radius:8px;font-size:13.5px;font-weight:700;text-decoration:none}
    .atc-btn--gold{background:#b8923a;color:#fff}
    .atc-btn--gold:hover{background:#8e6828}
    .atc-btn--navy{background:#0a1f3c;color:#f0e6d0}
    .atc-btn--navy:hover{background:#1b3556}
    .atc-footer__phone{margin:0;color:rgba(10,31,60,.65);font-size:13px}
    .atc-footer__phone a{color:#0a1f3c;font-weight:700;text-decoration:none}
    .atc-footer__phone a:hover{text-decoration:underline}
    .atc-ticker{display:flex;align-items:stretch;gap:0;margin-top:18px;border-radius:8px;overflow:hidden;background:#f0e6d0}
    .atc-ticker__label{flex:none;display:flex;align-items:center;background:#b8923a;color:#fff;font-size:11.5px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;padding:0 12px}
    .atc-ticker__viewport{overflow:hidden;flex:1;display:flex;align-items:center}
    .atc-ticker__track{display:inline-flex;align-items:center;width:max-content;padding:8px 0;animation:atc-scroll 45s linear infinite}
    .atc-ticker:hover .atc-ticker__track{animation-play-state:paused}
    .atc-ticker__group{display:inline-flex;align-items:center}
    .atc-ticker__item{display:inline-flex;align-items:center;white-space:nowrap}
    .atc-ticker__item a{color:#0a1f3c;font-size:13px;font-weight:600;text-decoration:none;padding:0 6px}
    .atc-ticker__item a:hover{text-decoration:underline}
    .atc-ticker__dot{color:#b8923a;font-size:9px;padding:0 10px}
    @keyframes atc-scroll{from{transform:translateX(0)}to{transform:translateX(-50%)}}
    @media (prefers-reduced-motion: reduce){.atc-ticker__track{animation:none}}
    """
  end
end
