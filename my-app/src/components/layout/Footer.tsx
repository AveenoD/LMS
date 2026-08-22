import React from "react";
import Link from "next/link";
import Image from "next/image";
import { Phone, Clock, Mail, Tv, Camera, Share2, MessageCircle } from "lucide-react";
import { FOOTER_LINKS } from "@/utils/constants";

export default function Footer() {
  return (
    <footer className="bg-ink-green text-white">
      <div className="container-main py-12 md:py-16">
        <div className="flex flex-col lg:flex-row flex-wrap gap-10 lg:gap-6 justify-between">
          {/* Brand Column */}
          <div className="lg:max-w-[280px]">
            <Link href="/" className="flex items-center gap-2 mb-4">
              <div className="w-12 h-12 flex items-center justify-center shrink-0">
                <Image src="/footer-logo.png" alt="EdTech OS Logo" width={48} height={48} className="object-contain" />
              </div>
              <div className="flex flex-col">
                <span className="text-lg font-display font-bold leading-tight">
                  EdTech OS
                </span>
                <span className="text-[10px] text-white/50 font-body leading-none">
                  Run Your Institute. Delight Every Student.
                </span>
              </div>
            </Link>
            <div className="flex items-center gap-3 mt-6">
              {[Tv, Camera, Share2].map((Icon, i) => (
                <a
                  key={i}
                  href="#"
                  className="w-9 h-9 rounded-full border border-white/20 flex items-center justify-center hover:bg-brass-gold hover:border-brass-gold transition-colors text-white"
                >
                  <Icon className="w-4 h-4" />
                </a>
              ))}
            </div>
          </div>

          {/* Product */}
          <div>
            <h4 className="text-sm font-body font-semibold mb-4 text-white/80 uppercase tracking-wider">
              Product
            </h4>
            <ul className="space-y-2.5">
              {FOOTER_LINKS.product.map((link) => (
                <li key={link.label}>
                  <Link
                    href={link.href}
                    className="text-sm font-body text-white/60 hover:text-brass-gold transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Solutions */}
          <div>
            <h4 className="text-sm font-body font-semibold mb-4 text-white/80 uppercase tracking-wider">
              Solutions
            </h4>
            <ul className="space-y-2.5">
              {FOOTER_LINKS.solutions.map((link) => (
                <li key={link.label}>
                  <Link
                    href={link.href}
                    className="text-sm font-body text-white/60 hover:text-brass-gold transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Resources */}
          <div>
            <h4 className="text-sm font-body font-semibold mb-4 text-white/80 uppercase tracking-wider">
              Resources
            </h4>
            <ul className="space-y-2.5">
              {FOOTER_LINKS.resources.map((link) => (
                <li key={link.label}>
                  <Link
                    href={link.href}
                    className="text-sm font-body text-white/60 hover:text-brass-gold transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Company */}
          <div>
            <h4 className="text-sm font-body font-semibold mb-4 text-white/80 uppercase tracking-wider">
              Company
            </h4>
            <ul className="space-y-2.5">
              {FOOTER_LINKS.company.map((link) => (
                <li key={link.label}>
                  <Link
                    href={link.href}
                    className="text-sm font-body text-white/60 hover:text-brass-gold transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Talk to Expert */}
          <div>
            <h4 className="text-sm font-body font-semibold mb-4 text-white/80 uppercase tracking-wider">
              Talk to Expert
            </h4>
            <ul className="space-y-4">
              <li>
                <a
                  href="tel:+919876543210"
                  className="inline-flex items-center gap-3 px-4 py-2.5 border border-white/20 rounded-xl text-sm font-body text-white hover:bg-white/10 transition-colors"
                >
                  <MessageCircle className="w-5 h-5 flex-shrink-0" />
                  <span className="font-semibold">+91 98765 43210</span>
                </a>
              </li>
              <li className="flex items-center gap-3 text-sm font-body text-white/60">
                <Clock className="w-4 h-4 flex-shrink-0" />
                Mon – Sat: 10:00 AM - 7:00 PM
              </li>
              <li>
                <a
                  href="mailto:support@edtechos.com"
                  className="flex items-center gap-3 text-sm font-body text-white/60 hover:text-brass-gold transition-colors"
                >
                  <Mail className="w-4 h-4 flex-shrink-0" />
                  support@edtechos.com
                </a>
              </li>
            </ul>
          </div>
        </div>
      </div>

      {/* Bottom bar */}
      <div className="border-t border-white/10">
        <div className="container-main py-4">
          <p className="text-xs text-white/40 font-body text-center">
            © {new Date().getFullYear()} EdTech OS. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  );
}
