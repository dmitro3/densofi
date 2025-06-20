import "./globals.css";
import { Inter } from "next/font/google";
import { Metadata } from "next";
import ClientLayout from "./client-layout";

// Use cache-busting technique for Inter font
const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: {
    default: "Denso.fi - Fractional Domain Tokenization Platform",
    template: "%s | Denso.fi"
  },
  description: "Transform domain names into tradeable tokens on the blockchain. Denso.fi enables fractional ownership, liquidity pools, and decentralized domain trading through innovative tokenization technology.",
  keywords: [
    "domain tokenization",
    "fractional domain ownership", 
    "blockchain domains",
    "domain trading",
    "NFT domains",
    "DeFi domains",
    "domain liquidity",
    "web3 domains",
    "domain investment",
    "decentralized domains"
  ],
  authors: [{ name: "Denso.fi Team" }],
  creator: "Denso.fi",
  publisher: "Denso.fi",
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  icons: {
    icon: [
      { url: "/dino.svg", type: "image/svg+xml" },
      { url: "/dino.png", sizes: "32x32", type: "image/png" },
      { url: "/dino-beefed-up.png", sizes: "192x192", type: "image/png" }
    ],
    shortcut: "/dino.svg",
    apple: "/dino-beefed-up.png",
  },
  manifest: "/manifest.json",
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "https://denso.fi",
    siteName: "Denso.fi",
    title: "Denso.fi - Fractional Domain Tokenization Platform",
    description: "Transform domain names into tradeable tokens on the blockchain. Enable fractional ownership, liquidity pools, and decentralized domain trading.",
    images: [
      {
        url: "/images/og-image.png", // You'll need to create this
        width: 1200,
        height: 630,
        alt: "Denso.fi - Fractional Domain Tokenization Platform",
        type: "image/png"
      }
    ],
  },
  twitter: {
    card: "summary_large_image",
    site: "@densofi", // Replace with your actual Twitter handle
    creator: "@densofi",
    title: "Denso.fi - Fractional Domain Tokenization Platform",
    description: "Transform domain names into tradeable tokens on the blockchain. Enable fractional ownership, liquidity pools, and decentralized domain trading.",
    images: ["/images/twitter-card.png"], // You'll need to create this
  },
  alternates: {
    canonical: "https://denso.fi",
  },
  category: "technology",
  classification: "Blockchain, DeFi, Domain Trading",
  other: {
    "apple-mobile-web-app-capable": "yes",
    "apple-mobile-web-app-status-bar-style": "black-translucent",
    "apple-mobile-web-app-title": "Denso.fi",
    "theme-color": "#1e293b",
    "msapplication-TileColor": "#1e293b",
    "msapplication-config": "/browserconfig.xml",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      {/* Add suppressHydrationWarning to body to ignore hydration mismatch on data-channel-name */}
      <body 
        suppressHydrationWarning={true}
        className={`${inter.className} antialiased bg-gradient-to-br from-slate-900 to-gray-900 min-h-screen`}
      >
        <ClientLayout>
          {children}
        </ClientLayout>
      </body>
    </html>
  );
}
