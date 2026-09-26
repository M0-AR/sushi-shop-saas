"use client";
import Link from "next/link";
import { useEffect, useState } from "react";
import Shell from "../../../components/Shell";

type Row = { id: string; actor: string; action: string; entity_type: string; entity_id: string; created_at: string };

export default function AuditAdmin() {
  const [rows, setRows] = useState<Row[] | null>(null);
  const [error, setError] = useState("");
  const API = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3001";
  useEffect(() => {
    fetch(`${API}/api/audit`).then(r => { if (!r.ok) throw 0; return r.json(); })
      .then(setRows).catch(() => setError("Failed to load audit log"));
  }, [API]);
  return (
    <Shell title="Audit log" sub="Append-only • who changed what, when (superadmin)">
      {error && <div className="errorbar"><span>{error}</span><button className="btn ghost" onClick={() => location.reload()}>Retry</button></div>}
      <div className="card">
        <div className="card__head">
          <div><h2>{rows ? `${rows.length} events` : "Events"}</h2><p>Refunds, voids and role changes surface here first</p></div>
          <Link className="link" href="/">← Back to overview</Link>
        </div>
        <div className="table-wrap">
          <table className="grid">
            <thead><tr><th>When</th><th>Actor</th><th>Action</th><th>Entity</th></tr></thead>
            <tbody>
              {rows === null && !error && [0, 1].map(i => (
                <tr key={i}><td><span className="skel">…</span></td><td><span className="skel">···</span></td><td><span className="skel">Loading action</span></td><td><span className="skel">···</span></td></tr>))}
              {rows?.map(r => (
                <tr key={r.id}>
                  <td>{new Date(r.created_at).toLocaleString()}</td>
                  <td><code>{r.actor}</code></td>
                  <td><span className="pill warn">{r.action}</span></td>
                  <td>{r.entity_type}:<strong>{String(r.entity_id).slice(0, 8)}</strong></td>
                </tr>))}
            </tbody>
          </table>
          {rows?.length === 0 && <div className="empty"><div className="big">📜</div><p>No audit events yet — place an order to generate one.</p></div>}
        </div>
      </div>
    </Shell>
  );
}
