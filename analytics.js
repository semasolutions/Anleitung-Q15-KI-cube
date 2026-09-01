(() => {
  const MEASUREMENT_ID = "G-RRW0VGBY8F";
  const STORAGE_KEY = "kiddotronic_analytics_consent";

  const styles = `
    .cookie-banner{position:fixed;left:16px;right:16px;bottom:16px;z-index:99999;max-width:760px;margin:auto;padding:20px;background:#fffaf2;color:#111;border:4px solid #111;border-radius:22px;box-shadow:8px 8px 0 #111;font-family:"Baloo 2",Arial,sans-serif}
    .cookie-banner[hidden]{display:none}
    .cookie-banner strong{display:block;margin-bottom:6px;font-size:1.3rem}
    .cookie-banner p{margin:0 0 14px;line-height:1.4}
    .cookie-banner a{color:#111;font-weight:800}
    .cookie-actions{display:flex;flex-wrap:wrap;gap:10px}
    .cookie-actions button,.privacy-settings{min-height:44px;padding:9px 16px;border:3px solid #111;border-radius:999px;background:#ffec3d;color:#111;font:800 1rem "Baloo 2",Arial,sans-serif;cursor:pointer;box-shadow:3px 3px 0 #111}
    .cookie-actions .reject{background:#fff}
    .privacy-settings{position:fixed;left:12px;bottom:12px;z-index:9998;min-height:38px;padding:6px 12px;font-size:.85rem;background:#fff}
    @media(max-width:560px){.cookie-banner{left:10px;right:10px;bottom:10px}.cookie-actions button{width:100%}}
  `;

  const addStyles = () => {
    if (document.getElementById("kiddotronic-analytics-styles")) return;
    const style = document.createElement("style");
    style.id = "kiddotronic-analytics-styles";
    style.textContent = styles;
    document.head.appendChild(style);
  };

  const configureConsent = (state) => {
    window.dataLayer = window.dataLayer || [];
    window.gtag = window.gtag || function(){ window.dataLayer.push(arguments); };
    window.gtag("consent", "default", {
      analytics_storage: state === "granted" ? "granted" : "denied",
      ad_storage: "denied",
      ad_user_data: "denied",
      ad_personalization: "denied",
      wait_for_update: 500
    });
  };

  const loadAnalytics = () => {
    if (document.querySelector('script[data-kiddotronic-ga]')) return;
    configureConsent("granted");
    const script = document.createElement("script");
    script.async = true;
    script.src = "https://www.googletagmanager.com/gtag/js?id=" + MEASUREMENT_ID;
    script.dataset.kiddotronicGa = "true";
    document.head.appendChild(script);
    window.gtag("js", new Date());
    window.gtag("config", MEASUREMENT_ID, { anonymize_ip: true });

    document.addEventListener("click", (event) => {
      const link = event.target.closest('a[href*="amazon."]');
      if (!link) return;
      window.gtag("event", "amazon_click", {
        link_url: link.href,
        link_text: (link.textContent || "").trim(),
        page_location: location.href
      });
    });
  };

  const createControls = () => {
    addStyles();
    const banner = document.createElement("aside");
    banner.className = "cookie-banner";
    banner.setAttribute("aria-label", "Datenschutzeinstellungen");
    banner.innerHTML = `
      <strong>Besucherstatistik</strong>
      <p>Mit deiner Zustimmung verwenden wir Google Analytics, um Seitenaufrufe und Klicks auf Amazon zu messen. Ohne Zustimmung bleibt die Analyse deaktiviert. <a href="datenschutz.html">Mehr erfahren</a></p>
      <div class="cookie-actions">
        <button type="button" class="accept">Analyse erlauben</button>
        <button type="button" class="reject">Nur notwendige Funktionen</button>
      </div>`;
    document.body.appendChild(banner);

    const settings = document.createElement("button");
    settings.type = "button";
    settings.className = "privacy-settings";
    settings.textContent = "Datenschutz-Einstellungen";
    settings.hidden = true;
    document.body.appendChild(settings);

    const setChoice = (choice) => {
      localStorage.setItem(STORAGE_KEY, choice);
      banner.hidden = true;
      settings.hidden = false;
      if (choice === "granted") {
        loadAnalytics();
      } else {
        configureConsent("denied");
      }
    };

    banner.querySelector(".accept").addEventListener("click", () => setChoice("granted"));
    banner.querySelector(".reject").addEventListener("click", () => setChoice("denied"));
    settings.addEventListener("click", () => {
      banner.hidden = false;
      settings.hidden = true;
    });

    const choice = localStorage.getItem(STORAGE_KEY);
    if (choice === "granted") {
      banner.hidden = true;
      settings.hidden = false;
      loadAnalytics();
    } else if (choice === "denied") {
      banner.hidden = true;
      settings.hidden = false;
      configureConsent("denied");
    } else {
      configureConsent("denied");
    }
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", createControls);
  } else {
    createControls();
  }
})();