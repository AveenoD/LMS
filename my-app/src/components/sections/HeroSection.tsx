"use client";

import React from "react";
import Image from "next/image";
import { motion } from "framer-motion";
import { Play } from "lucide-react";
import Button from "@/components/ui/Button";
import TrustBadge from "@/components/ui/TrustBadge";
import { TRUST_BADGES } from "@/utils/constants";

export default function HeroSection() {
  return (
    <section className="relative bg-white flex flex-col min-h-[calc(100vh-120px)] justify-between">
      <div className="container-main flex-grow pt-4 pb-0 md:pt-6 md:pb-0">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Left Content */}
          <motion.div
            initial={{ opacity: 0, x: -40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6 }}
          >
            {/* Badge */}
            <div className="mb-6">
              <span className="badge-gold">
                <span className="w-2 h-2 rounded-full bg-brass-gold" />
                Trusted by 1000+ Coaching Institutes
              </span>
            </div>

            {/* Heading */}
            <h1 className="text-4xl sm:text-5xl font-display font-bold text-ink-green leading-[1.15] mb-5">
              One Platform.
              <br />
              Every Operation.
              <br />
              <span className="text-gradient-gold">For Every Institute.</span>
            </h1>

            {/* Subtext */}
            <p className="text-base sm:text-lg text-ink-green/70 font-body leading-relaxed mb-8 max-w-lg">
              Manage attendance, fees, live classes, tests, assignments and
              communication — all in one platform.
              <br />
              Save time. Improve results. Grow your institute.
            </p>

            {/* CTAs */}
            <div className="flex flex-wrap items-center gap-4">
              <Button variant="primary" size="lg" href="/demo" withArrow>
                Book a Free Demo
              </Button>
              <Button variant="secondary" size="lg">
                <Play className="w-4 h-4" />
                Watch How It Works
              </Button>
            </div>
          </motion.div>

          {/* Right — Dashboard Preview Placeholder */}
          <motion.div
            initial={{ opacity: 0, x: 40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="relative"
          >
            {/* Decorative Green Blob */}
            <div
              className="absolute top-1/2 left-1/2 -translate-x-[35%] -translate-y-[45%] w-[100%] h-[110%] bg-chalk-teal z-0"
              style={{ borderRadius: "43% 57% 65% 35% / 55% 45% 55% 45%" }}
            />

            {/* Dashboard Image */}
            <div className="relative z-10 w-full flex items-center justify-center max-w-[500px] lg:max-w-none mx-auto lg:scale-[1.05] lg:-translate-x-1">
              <Image
                src="/home.png"
                alt="Campus Dashboard Preview"
                width={1200}
                height={800}
                className="w-full h-auto object-contain drop-shadow-2xl rounded-lg"
                priority
              />
            </div>
          </motion.div>
        </div>
      </div>

      {/* Trust Bar */}
      <div className="border-t border-paper bg-white relative z-10">
        <div className="container-main py-4 md:py-5">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {TRUST_BADGES.map((badge) => (
              <TrustBadge
                key={badge.title}
                icon={badge.icon}
                title={badge.title}
                subtitle={badge.subtitle}
              />
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
