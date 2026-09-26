"use client";
import Link from "next/link";
import { useEffect, useState } from "react";
import Shell from "../components/Shell";

const API = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3001";

type Order = { id: string; status: string; lines: number; created_at: string };

export default function OverviewPage() {
  const [menuCount, setMenuCount] = useState<number | null>(null);
  const [tenantCount, setTenantCount] = useState<number | null>(null);
  const [orders, setOrders] = useState<Order[] | null>(null);
  const [error, setError] = useState("");
  useEffect(() => {
    (async () => {
      try {
        const [m, o, t] = await Promise.all([
          fetch(`${API}/api/menu`).then(r => { if (!r.ok) throw 0; return r.json(); }),
          fetch(`${API}/api/orders`).then(r => { if (!r.ok) throw 0; return r.json(); }),
          fetch(`${API}/api/tenants`).then(r => { if (!r.ok) throw 0; return r.json(); }),
        ]);
        setMenuCount(m.length); setOrders(o); setTenantCount(t.length);
      } catch { setError("Couldn't reach the API. Is the backend running?"); }
    })();
  }, []);
  const placed = orders?.length ?? null;
  return (
    <Shell title="Overview" sub="Tokyo Main • live operational health">
      {error && <div className="errorbar"><span>{error}</span><button className="btn ghost" onClick={() => location.reload()}>Retry</button></div>}
      <div className="kpis">
        <Link className="kpi" href="/admin/orders">
          <div className="kpi__label">Open orders</div>
          <div className="kpi__value">{placed ?? <span className="skel">0</span>}</div>
          <div className="kpi__sub">live board • <b>view queue</b></div>
        </Link>
        <Link className="kpi" href="/admin/menu">
          <div className="kpi__label">Menu items</div>
          <div className="kpi__value">{menuCount ?? <span className="skel">0</span>}</div>
          <div className="kpi__sub">across sushi • rolls • popular</div>
        </Link>
        <Link className="kpi" href="/admin/tenants">
          <div className="kpi__label">Outlets</div>
          <div className="kpi__value">{tenantCount ?? <span className="skel">0</span>}</div>
          <div className="kpi__sub">tokyo-main + branches</div>
        </Link>
        <Link className="kpi" href="/admin/audit">
          <div className="kpi__label">Audit trail</div>
          <div className="kpi__value" style={{ fontSize: 22 }}>append-only</div>
          <div className="kpi__sub">who changed what • <b>inspect</b></div>
        </Link>
      </div>
      <div className="card">
        <div className="card__head">
          <div><h2>Recent orders</h2><p>Newest first • click through to the live board</p></div>
          <Link className="btn" href="/admin/orders">Open board</Link>
        </div>
        <div className="table-wrap">
          <table className="grid">
            <thead><tr><th>Order</th><th>Status</th><th className="num">Lines</th><th>Created</th></tr></thead>
            <tbody>
              {orders === null && !error && [0, 1, 2].map(i => (
                <tr key={i}><td><span className="skel">Loading order</span></td><td><span className="skel">Loading status</span></td><td className="num"><span className="skel">0</span></td><td><span className="skel">…</span></td></tr>))}
              {orders?.slice(0, 5).map(o => (
                <tr key={o.id}>
                  <td><strong>{o.id.slice(0, 8)}</strong></td>
                  <td><span className="pill ok">{o.status}</span></td>
                  <td className="num">{o.lines}</td>
                  <td>{new Date(o.created_at).toLocaleString()}</td>
                </tr>))}
            </tbody>
          </table>
          {orders?.length === 0 && <div className="empty"><div className="big">🧾</div><p>No orders yet — orders will appear here once a customer checks out.</p></div>}
        </div>
      </div>
      <div id="admin-health" style={{ display: "none" }}>Admin OK</div>
    </Shell>
  );
}
