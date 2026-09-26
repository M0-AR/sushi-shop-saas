import "./globals.css";

export const metadata = { title: "Sushi SaaS Admin", description: "Multi-tenant restaurant control panel" };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>{children}</body>
    </html>
  );
}
