"use client";

import React from "react";
import Image from "next/image";
import { motion } from "framer-motion";
import { MessageCircle } from "lucide-react";
import Button from "@/components/ui/Button";

interface CTABannerProps {
  title?: string;
  subtitle?: string;
  variant?: "dark" | "teal";
}

export default function CTABanner({
  title = "Ready to Transform Your Institute?",
  subtitle = "Join 1000+ coaching institutes already using EdTech OS to simplify operations and deliver better results.",
  variant = "teal",
}: CTABannerProps) {
  return (
    <section className="py-12">
      <div className="container-main">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className={`rounded-2xl p-8 md:p-12 ${
            variant === "dark" ? "bg-ink-green" : "bg-chalk-teal"
          }`}
        >
          <div className="flex flex-col md:flex-row items-center justify-between gap-6">
            <div className="flex items-center gap-4">
              {/* Logo */}
              <div className="hidden md:flex w-16 h-16 rounded-2xl bg-white items-center justify-center flex-shrink-0 overflow-hidden">
                <Image src="/main-logo.png" alt="EdTech OS Logo" width={48} height={48} className="object-contain" />
              </div>
              <div>
                <h3 className="text-xl md:text-2xl font-display font-bold text-white mb-1">
                  {title}
                </h3>
                <p className="text-sm text-white/70 font-body max-w-lg">
                  {subtitle}
                </p>
              </div>
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <Button variant="primary" size="md" href="/book-demo" withArrow>
                Book a Free Demo
              </Button>
              <Button
                variant="secondary"
                size="md"
                className="bg-white text-ink-green border-white hover:bg-gray-50 hover:text-ink-green"
              >
                <MessageCircle className="w-4 h-4" />
                Chat on WhatsApp
              </Button>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
