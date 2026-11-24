// Turns on NocoDB's invite-only sign-up once the API answers, logging in as the super admin
// from NC_ADMIN_EMAIL / NC_ADMIN_PASSWORD. Set NC_INVITE_ONLY_SIGNUP=false to manage it in the UI.
const base = `http://127.0.0.1:${process.env.PORT || 8080}`;
const log = (m) => console.log(`[railway-nocodb] ${m}`);
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const call = async (path, opts = {}) => {
  const res = await fetch(base + path, { ...opts, signal: AbortSignal.timeout(15_000) });
  const text = await res.text();
  return { ok: res.ok, status: res.status, body: text ? JSON.parse(text) : {} };
};

for (let i = 0; i < 180; i++) {
  try {
    if ((await call("/api/v1/health")).ok) break;
  } catch {}
  await sleep(5000);
}
try {
  const signin = await call("/api/v1/auth/user/signin", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: process.env.NC_ADMIN_EMAIL, password: process.env.NC_ADMIN_PASSWORD }),
  });
  if (!signin.ok || !signin.body.token) throw new Error(`sign-in answered ${signin.status}`);
  const headers = { "Content-Type": "application/json", "xc-auth": signin.body.token };
  const current = await call("/api/v1/app-settings", { headers });
  if (current.body?.invite_only_signup === true) {
    log("invite-only sign-up already on");
  } else {
    const res = await call("/api/v1/app-settings", {
      method: "POST",
      headers,
      body: JSON.stringify({ ...(current.body || {}), invite_only_signup: true }),
    });
    log(res.ok ? "invite-only sign-up turned on" : `could not turn on invite-only sign-up (${res.status})`);
  }
} catch (err) {
  log(`could not turn on invite-only sign-up: ${err.message}`);
}
