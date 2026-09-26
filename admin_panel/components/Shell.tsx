"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";

const NAV = [
  { sec: "Operate" },
  { href: "/", label: "Overview", ico: "◈" },
  { href: "/admin/menu", label: "Menu Items", ico: "🍣" },
  { href: "/admin/orders", label: "Orders", ico: "🧾" },
  { sec: "Manage" },
  { href: "/admin/tenants", label: "Tenants", ico: "🏬" },
  { href: "/admin/audit", label: "Audit Log", ico: "📜" },
];

export default function Shell({ title, sub, children }: { title: string; sub?: string; children: React.ReactNode }) {
  const path = usePathname();
  const [collapsed, setCollapsed] = useState(false);
  const [theme, setTheme] = useState<"light" | "dark">("light");
  useEffect(() => {
    setCollapsed(localStorage.getItem("sushi-nav") === "1");
    const t = localStorage.getItem("sushi-theme") as "light" | "dark" | null;
    const initial = t || (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
    setTheme(initial);
    document.documentElement.dataset.theme = initial;
  }, []);
  const toggleTheme = () => {
    const next = theme === "light" ? "dark" : "light";
    setTheme(next);
    document.documentElement.dataset.theme = next;
    localStorage.setItem("sushi-theme", next);
  };
  const toggleNav = () => {
    const next = !collapsed;
    setCollapsed(next);
    localStorage.setItem("sushi-nav", next ? "1" : "0");
  };
  return (
    <div className={`shell${collapsed ? " collapsed" : ""}`}>
      <aside className="shell__sidebar" aria-label="Primary">
        <div className="brand"><span className="brand__mark">🍣</span><span className="brand__txt">Sushi SaaS</span></div>
        <nav>
          {NAV.map((n, i) =>
            n.sec ? <div className="nav-sec" key={i}>{n.sec}</div> : (
              <Link key={n.href} href={n.href!} className={`nav-item${path === n.href ? " active" : ""}`}>
                <span className="ico" aria-hidden>{n.ico}</span><span className="lbl">{n.label}</span>
              </Link>
            ))}
        </nav>
        <div className="sidebar__foot"><span className="lbl">Tokyo Main • pro plan</span></div>
      </aside>
      <header className="shell__topbar">
        <button className="icon-btn" onClick={toggleNav} aria-label="Toggle navigation">☰</button>
        <div>
          <div className="topbar__title">{title}</div>
          {sub && <div style={{ fontSize: 12.5, color: "var(--muted)" }}>{sub}</div>}
        </div>
        <div style={{ marginLeft: "auto", display: "flex", gap: 10, alignItems: "center" }}>
          <span className="tenant-pill">● tokyo-main</span>
          <button className="icon-btn" onClick={toggleTheme} aria-label="Toggle color theme">
            {theme === "light" ? "🌙" : "☀️"}
          </button>
        </div>
      </header>
      <main className="shell__main">{children}</main>
    </div>
  );
}
