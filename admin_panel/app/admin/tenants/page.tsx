"use client";
import Link from "next/link";
import { useEffect, useState } from "react";
import Shell from "../../../components/Shell";

type Row = { slug: string; name: string; currency: string; plan: string };

export default function TenantsAdmin() {
  const [rows, setRows] = useState<Row[] | null>(null);
  const [error, setError] = useState("");
  const API = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3001";
  useEffect(() => {
    fetch(`${API}/api/tenants`).then(r => { if (!r.ok) throw 0; return r.json(); })
      .then(setRows).catch(() => setError("Failed to load tenants"));
  }, [API]);
  return (
    <Shell title="Outlets" sub="Multi-outlet visibility • plans & currencies">
      {error && <div className="errorbar"><span>{error}</span><button className="btn ghost" onClick={() => location.reload()}>Retry</button></div>}
      <div className="card">
        <div className="card__head">
          <div><h2>{rows ? `${rows.length} outlets` : "Outlets"}</h2><p>Each outlet gets isolated data + its own theme</p></div>
          <Link className="link" href="/">← Back to overview</Link>
        </div>
        <div className="table-wrap">
          <table className="grid">
            <thead><tr><th>Outlet</th><th>Slug</th><th>Currency</th><th>Plan</th></tr></thead>
            <tbody>
              {rows === null && !error && [0, 1].map(i => (
                <tr key={i}><td><span className="skel">Loading outlet</span></td><td><span className="skel">loading</span></td><td><span className="skel">···</span></td><td><span className="skel">···</span></td></tr>))}
              {rows?.map(r => (
                <tr key={r.slug}>
                  <td><strong>{r.name}</strong></td>
                  <td><code>{r.slug}</code></td>
                  <td>{r.currency}</td>
                  <td><span className="pill info">{r.plan}</span></td>
                </tr>))}
            </tbody>
          </table>
        </div>
      </div>
    </Shell>
  );
}
