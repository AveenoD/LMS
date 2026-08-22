import React from "react";
import { Phone } from "lucide-react";

export default function Topbar() {
  return (
    <div className="bg-ink-green text-white text-xs font-body">
      <div className="container-main flex items-center justify-between py-2">
        <p className="hidden sm:block">All-in-one LMS for Coaching Institutes</p>
        <div className="flex items-center gap-4 ml-auto sm:ml-0">
          <a
            href="tel:+919876543210"
            className="flex items-center gap-1.5 hover:text-brass-gold transition-colors"
          >
            <Phone className="w-3 h-3" />
            <span>Talk to Expert: +91 98765 43210</span>
          </a>
          <a
            href="#"
            className="hidden md:inline hover:text-brass-gold transition-colors"
          >
            Support
          </a>
        </div>
      </div>
    </div>
  );
}
