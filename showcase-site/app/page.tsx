"use client";

import { useMemo, useState } from "react";

type Scenario = "baseline" | "hardened";

const scenarioData = {
  baseline: {
    eyebrow: "Scenario 01 · Baseline",
    title: "MFA succeeds. Session context changes.",
    result: "ALLOWED",
    resultClass: "result-warn",
    summary:
      "Ordinary MFA verifies the sign-in, while the resulting session still needs its own protections.",
    events: [
      ["00:00", "Authentication completed", "ordinary_mfa"],
      ["00:18", "Synthetic context transition", "fingerprint changed"],
      ["00:31", "Policy evaluation", "baseline allowed"],
      ["00:44", "SOC observation", "review queued"],
    ],
    eventId: "BASELINE_001",
    actor: "synthetic-baseline-user-01",
    device: "unmanaged",
    ca: "allowed",
    fingerprint: "sha256:a7f3…9c10",
  },
  hardened: {
    eyebrow: "Scenario 02 · Hardened",
    title: "The changed context is restricted.",
    result: "BLOCKED",
    resultClass: "result-good",
    summary:
      "Phishing-resistant authentication and an approved device condition stop the synthetic transition.",
    events: [
      ["00:00", "Authentication completed", "phishing_resistant"],
      ["00:16", "Device condition checked", "compliant"],
      ["00:25", "Synthetic context transition", "fingerprint changed"],
      ["00:29", "Policy evaluation", "restricted / blocked"],
    ],
    eventId: "HARDENED_001",
    actor: "synthetic-hardened-user-01",
    device: "compliant",
    ca: "blocked",
    fingerprint: "sha256:4d11…b820",
  },
} as const;

export default function Home() {
  const [scenario, setScenario] = useState<Scenario>("baseline");
  const [runCount, setRunCount] = useState(0);
  const active = scenarioData[scenario];
  const runLabel = runCount ? `Run ${String(runCount).padStart(2, "0")}` : "Ready";

  const eventPreview = useMemo(
    () => ({
      schema_version: "1.0",
      scenario_id: active.eventId,
      actor_alias: active.actor,
      display_ip: scenario === "baseline" ? "192.0.2.51" : "198.51.100.24",
      device_state: active.device,
      conditional_access_result: active.ca,
      session_fingerprint: active.fingerprint,
    }),
    [active, scenario],
  );

  function launch(nextScenario: Scenario) {
    setScenario(nextScenario);
    setRunCount((count) => count + 1);
  }

  return (
    <main>
      <header className="topbar">
        <a className="brand" href="#top" aria-label="Defensive showcase home">
          <span className="brand-mark">E</span>
          <span>ENTRA / SESSION LAB</span>
        </a>
        <div className="lab-badge"><span /> LAB ONLY · NO CREDENTIAL COLLECTION</div>
      </header>

      <section className="hero" id="top">
        <div className="hero-copy">
          <p className="kicker">DEFENSIVE SHOWCASE · SEPTEMBER 2026</p>
          <h1>Authentication passed.<br /><em>Is the session protected?</em></h1>
          <p className="lede">
            A controlled demonstration of why successful MFA and protection of
            the resulting session are different security properties.
          </p>
          <div className="hero-actions">
            <button className="button-primary" onClick={() => launch("baseline")}>
              Run baseline simulation
            </button>
            <button className="button-secondary" onClick={() => launch("hardened")}>
              Run hardened simulation
            </button>
          </div>
          <p className="microcopy">Synthetic identities · Documentation IPs · Sanitized metadata only</p>
        </div>
        <div className="signal-card" aria-label="Lab safety status">
          <div className="signal-head"><span>SAFETY ENVELOPE</span><b>ACTIVE</b></div>
          <dl>
            <div><dt>Public ingress</dt><dd>CLOSED</dd></div>
            <div><dt>Identity source</dt><dd>SYNTHETIC</dd></div>
            <div><dt>Raw auth material</dt><dd>FORBIDDEN</dd></div>
            <div><dt>Reset point</dt><dd>CLEAN SNAPSHOT</dd></div>
          </dl>
          <div className="pulse-line"><span /><i /><span /><i /><span /></div>
        </div>
      </section>

      <section className="scenario-shell" aria-labelledby="scenario-title">
        <div className="section-heading">
          <div>
            <p className="kicker">LIVE STORYBOARD</p>
            <h2 id="scenario-title">Before and after, on one timeline.</h2>
          </div>
          <span className="run-state">{runLabel}</span>
        </div>

        <div className="scenario-tabs" role="tablist" aria-label="Scenario selection">
          <button
            className={scenario === "baseline" ? "active" : ""}
            onClick={() => setScenario("baseline")}
            role="tab"
            aria-selected={scenario === "baseline"}
          >
            01 / Baseline
          </button>
          <button
            className={scenario === "hardened" ? "active" : ""}
            onClick={() => setScenario("hardened")}
            role="tab"
            aria-selected={scenario === "hardened"}
          >
            02 / Hardened
          </button>
        </div>

        <div className="scenario-grid">
          <article className="story-card">
            <p className="eyebrow">{active.eyebrow}</p>
            <div className="story-title-row">
              <h3>{active.title}</h3>
              <span className={`result-chip ${active.resultClass}`}>{active.result}</span>
            </div>
            <p className="story-summary">{active.summary}</p>
            <ol className="timeline">
              {active.events.map(([time, title, detail], index) => (
                <li key={`${scenario}-${time}`}>
                  <span className="timeline-index">{String(index + 1).padStart(2, "0")}</span>
                  <time>{time}</time>
                  <div><b>{title}</b><small>{detail}</small></div>
                </li>
              ))}
            </ol>
          </article>

          <aside className="evidence-card">
            <div className="evidence-head">
              <div><span className="status-dot" /> SANITIZED EVENT</div>
              <code>{active.eventId}</code>
            </div>
            <pre>{JSON.stringify(eventPreview, null, 2)}</pre>
            <div className="contract-note">
              <b>Schema-enforced allowlist</b>
              <span>Unknown or sensitive fields are rejected before storage.</span>
            </div>
          </aside>
        </div>
      </section>

      <section className="compare-section">
        <p className="kicker">CONTROL DIFFERENCE</p>
        <div className="compare-grid">
          <article>
            <span className="number">01</span>
            <h3>Baseline</h3>
            <p>Ordinary MFA · unmanaged device · limited session controls</p>
            <strong className="amber">OBSERVE THE GAP</strong>
          </article>
          <div className="versus">VS</div>
          <article>
            <span className="number">02</span>
            <h3>Hardened</h3>
            <p>Phishing-resistant auth · device condition · risk-aware policy</p>
            <strong className="green">RESTRICT THE CHANGE</strong>
          </article>
        </div>
      </section>

      <footer>
        <span>ENTRA AITM DEFENSIVE SHOWCASE</span>
        <span>LOCAL PREVIEW · NOT A SIGN-IN SERVICE</span>
      </footer>
    </main>
  );
}
