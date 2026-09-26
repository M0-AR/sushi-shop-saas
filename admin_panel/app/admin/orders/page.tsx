"use client";
import Link from "next/link";
import { useEffect, useState } from "react";
import Shell from "../../../components/Shell";

type Row = { id: string; status: string; created_at: string; lines: number };

export default function OrdersAdmin() {
  const [rows, setRows] = useState<Row[] | null>(null);
  const [error, setError] = useState("");
  const API = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3001";
  useEffect(() => {
    fetch(`${API}/api/orders`).then(r => { if (!r.ok) throw 0; return r.json(); })
      .then(setRows).catch(() => setError("Failed to load orders"));
  }, [API]);
  return (
    <Shell title="Live order board" sub="Current orders by stage • tenant-scoped">
      {error && <div className="errorbar"><span>{error}</span><button className="btn ghost" onClick={() => location.reload()}>Retry</button></div>}
      <div className="card">
        <div className="card__head">
          <div><h2>{rows ? `${rows.length} orders` : "Orders"}</h2><p>Refreshes on load • newest first</p></div>
          <Link className="link" href="/">← Back to overview</Link>
        </div>
        <div className="table-wrap">
          <table className="grid">
            <thead><tr><th>Order</th><th>Status</th><th className="num">Lines</th><th>Created</th></tr></thead>
            <tbody>
              {rows === null && !error && [0, 1].map(i => (
                <tr key={i}><td><span className="skel">Loading order</span></td><td><span className="skel">Loading status</span></td><td className="num"><span className="skel">0</span></td><td><span className="skel">…</span></td></tr>))}
              {rows?.map(r => (
                <tr key={r.id}>
                  <td><strong>{r.id.slice(0, 8)}</strong></td>
                  <td><span className="pill ok">{r.status}</span></td>
                  <td className="num">{r.lines}</td>
                  <td>{new Date(r.created_at).toLocaleString()}</td>
                </tr>))}
            </tbody>
          </table>
          {rows?.length === 0 && <div className="empty"><div className="big">🧾</div><p>No orders yet — orders will appear here once a customer checks out.</p></div>}
        </div>
      </div>
    </Shell>
  );
}
