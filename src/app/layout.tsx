import type { Metadata, Viewport } from "next";
import { Cormorant_Garamond, Figtree } from "next/font/google";
import "./globals.css";
import { RegisterSW } from "@/components/pwa/RegisterSW";

const sans = Figtree({
  variable: "--font-sans",
  subsets: ["latin"],
  display: "swap",
});

const display = Cormorant_Garamond({
  variable: "--font-display",
  subsets: ["latin"],
  weight: ["500", "600"],
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "Kolam Kraze",
    template: "%s · Aarla Play",
  },
  description: "See it. Remember it. Draw it. A short-session kolam game from Aarla Play.",
  applicationName: "Kolam Kraze",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "Kolam Kraze",
  },
  formatDetection: { telephone: false },
  icons: {
    icon: [{ url: "/icons/icon.svg", type: "image/svg+xml" }],
    apple: "/icons/icon-192.png",
  },
};

export const viewport: Viewport = {
  themeColor: "#F4EFE6",
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  viewportFit: "cover",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" className={`${sans.variable} ${display.variable} h-full`}>
      <body className="grain min-h-full bg-ivory text-charcoal antialiased">
        <div className="mx-auto flex min-h-[100dvh] w-full max-w-lg flex-col shadow-[0_0_80px_rgba(31,27,22,0.04)]">
          {children}
        </div>
        <RegisterSW />
      </body>
    </html>
  );
}
