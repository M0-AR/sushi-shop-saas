"use client";
import Link from "next/link";
import { useEffect, useState } from "react";
import Shell from "../../../components/Shell";

type Row = { id: string; name: string; price_cents: number; category: string; rating: string };

const CAT_PILL: Record<string, string> = { sushi: "ok", rolls: "info", popular: "warn", sets: "warn" };

export default function MenuAdmin() {
  const [rows, setRows] = useState<Row[] | null>(null);
  const [error, setError] = useState("");
  const API = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3001";
  useEffect(() => {
    fetch(`${API}/api/menu`).then(r => { if (!r.ok) throw 0; return r.json(); })
      .then(setRows).catch(() => setError("Failed to load menu"));
  }, [API]);
  return (
    <Shell title="Menu Items" sub="Tenant-aware catalogue • prices in USD">
      {error && <div className="errorbar"><span>{error}</span><button className="btn ghost" onClick={() => location.reload()}>Retry</button></div>}
      <div className="card">
        <div className="card__head">
          <div><h2>{rows ? `${rows.length} dishes` : "Dishes"}</h2><p>Availability controls pause items during service</p></div>
          <Link className="link" href="/">← Back to overview</Link>
        </div>
        <div className="table-wrap">
          <table className="grid">
            <thead><tr><th>Dish</th><th>Category</th><th className="num">Price</th><th className="num">Rating</th></tr></thead>
            <tbody>
              {rows === null && !error && [0, 1, 2].map(i => (
                <tr key={i}><td><span className="skel">Loading dish</span></td><td><span className="skel">category</span></td><td className="num"><span className="skel">$0.00</span></td><td className="num"><span className="skel">0.0</span></td></tr>))}
              {rows?.map(r => (
                <tr key={r.id}>
                  <td><strong>{r.name}</strong></td>
                  <td><span className={`pill ${CAT_PILL[r.category] || "info"}`}>{r.category}</span></td>
                  <td className="num">${(r.price_cents / 100).toFixed(2)}</td>
                  <td className="num">★ {r.rating}</td>
                </tr>))}
            </tbody>
          </table>
          {rows?.length === 0 && <div className="empty"><div className="big">🍣</div><p>No dishes in this outlet yet.</p></div>}
        </div>
      </div>
    </Shell>
  );
}
